---
name: widgetkit-bridge
description: How Dart pushes data to iOS WidgetKit and Android Glance widgets, and how native widgets read it. Use in packages/widgets_ios, packages/widgets_android, and any apps/<slug>/{ios,android} widget target.
---

# widgetkit-bridge

One contract for how factory apps feed data to native home-screen / lock-screen / Wear surfaces. If your widget doesn't render, this is the first place to look.

## The contract

Dart writes a JSON blob to a shared store. Native reads it, decodes into a Swift/Kotlin struct, renders. That's the whole system.

- **Payload**: JSON. Keys are snake_case. Values are `String`, `int`, `double`, `bool`, `List<String>`, or ISO-8601 `String` for dates.
- **Store name** (both platforms): `factory.widget.<slug>` — the app slug from spec §1.
- **Refresh trigger**: Dart writes → Dart calls `WidgetCenter.reloadAllTimelines()` on iOS, `WorkManager.enqueueUniqueWork()` on Android (both wrapped inside `core/widget_bridge`).

## Dart side (packages/core/lib/widget_bridge.dart)

```dart
class WidgetBridge {
  Future<void> publish(Map<String, Object?> payload);
  Future<Map<String, Object?>?> read();
}
```

Apps call `publish` on every state change that affects the widget. Never on a timer.

## iOS side

### App Group setup
- App Group ID: `group.<BUNDLE_PREFIX>.<slug>.widgets` (from `factory.config`).
- Both the main app target and every widget target are members.
- The scaffolder wires the entitlement — do not hand-edit `Runner.entitlements`.

### Reading in Swift

```swift
// packages/widgets_ios/Sources/WidgetStore.swift
struct WidgetStore {
  static let suiteName = "group.<BUNDLE_PREFIX>.<slug>.widgets"
  static func read() -> [String: Any]? {
    guard let defaults = UserDefaults(suiteName: suiteName),
          let data = defaults.data(forKey: "payload"),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }
    return json
  }
}
```

### Widget targets
- Live under `packages/widgets_ios/Sources/`.
- Each widget is a `Widget` conforming to `WidgetConfigurationIntent` if user-configurable, static otherwise.
- Use `containerBackground(for: .widget)` on the root view — this makes StandBy, tinted, and clear rendering work on iOS 26.
- Support tinted rendering: use `Image(systemName:)` and `Text` with `.widgetAccentable()` modifiers. Do not use custom UIKit colors.

### Live Activities
- `ActivityAttributes` per-app, `ActivityContent` per state.
- Dynamic Island compact and expanded views are designed **deliberately** — no default fall-through.
- Background updates via `Activity<...>.update(...)` from Dart, through the bridge.

## Android side

### DataStore setup
- File: `<applicationId>_widget.preferences_pb` (created by `core/widget_bridge`).
- Widget receivers read from a `PreferencesDataStore` scoped to the app.

### Reading in Kotlin

```kotlin
// packages/widgets_android/src/main/kotlin/factory/widgets/WidgetStore.kt
object WidgetStore {
  suspend fun read(context: Context, slug: String): JSONObject? {
    val dataStore = context.dataStore
    val payload = dataStore.data.map { it[stringPreferencesKey("payload")] }.first() ?: return null
    return JSONObject(payload)
  }
}
```

### Glance widgets
- Under `packages/widgets_android/src/main/kotlin/factory/widgets/glance/`.
- Every widget provides at least two sizes (`SizeMode.Responsive`).
- Dynamic color: use `GlanceTheme.colors` for surfaces; use `ColorProvider(day: accent, night: accent)` only for the primary action.
- Set `AppWidgetProviderInfo` `previewLayout` and `description` in `res/xml/<slug>_widget_info.xml`.

### Ongoing notifications
- Use `NotificationCompat.CallStyle` or `ProgressStyle` for in-progress activities.
- Android 16 live-update: `NotificationCompat.Builder(...).setStyle(Notification.ProgressStyle(...))` when API >= 36; fall back to progress bar below.

## Refresh cadence

- iOS timeline reload: **only** when Dart pushes new data. WidgetKit's automatic reloads are still respected (StandBy, low-power).
- Android: same. No `AlarmManager` polling. Widgets update reactively.

## Testing

- Dart unit test: `WidgetBridge` uses an in-memory store; verify `publish` → `read` round-trip.
- iOS: snapshot tests per widget size, per rendering mode (`.system`, `.accented`, `.vibrant`, `.fullColor`). Use `Xcode Previews`.
- Android: Glance snapshot tests per size and per `GlanceTheme` (light/dark). Use `androidx.glance.testing`.

## Common failures

- **Widget shows old data**: Dart forgot to call `publish` after state change, or `reloadAllTimelines()` isn't wired.
- **Widget crashes on install**: App Group membership missing on the widget target.
- **Widget shows nothing on lock screen (iOS)**: didn't provide `accessoryRectangular` / `accessoryCircular` families.
- **Tinted mode looks washed out**: used `Color(...)` instead of a system tint; move to SF Symbols with `.widgetAccentable()`.
