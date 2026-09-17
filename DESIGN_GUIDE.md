# Design Guide — Factory Apps

This is the standing design brief for every app the factory ships. It is loaded by the Builder, Native Builder, Tester and Reviewer. The spec's §8 overrides it only where it explicitly says so.

The bar: a user should not be able to tell the app was not built by a small, careful native team. On iPhone it should feel like an app Apple would feature. On Android it should feel like it came from Google. Never the same app wearing two skins.

---

## 1. Platform-adaptive, not cross-platform-looking

Flutter renders both platforms. It does not decide what they look like. The shared package exposes an adaptive layer; every screen is built against it.

| Concern | iOS | Android |
|---|---|---|
| Component set | Cupertino (latest Flutter release, which tracks iOS 26 styling) | Material 3 Expressive |
| Top-level navigation | Bottom tab bar; floating/translucent style on iOS 26, with the system search tab when the app has search | Navigation bar (3–5 destinations) or navigation rail on wide screens |
| Push navigation | Large-title nav bar collapsing on scroll; interactive swipe-back always enabled | Top app bar; predictive back gesture fully supported |
| Modals | Sheets with detents (`medium`, `large`); full-screen covers only for flows with their own nav | Bottom sheets (modal and standard); full-screen dialogs for multi-step forms |
| Confirmations | Action sheet / alert with Cancel on the left | Dialog with actions right-aligned, destructive last |
| Lists | Inset grouped lists; disclosure chevrons | Material lists with dividers or cards; no chevrons unless it navigates |
| Toggles / pickers | Cupertino switch, wheel picker, segmented control | Material switch, dropdown/menu, segmented buttons |
| Pull-to-refresh | Cupertino sliver refresh | Material indicator |
| Haptics | Selection, impact, notification patterns via `HapticFeedback` mapped to UIKit generators | Vibration effects via the platform channel; lighter and rarer than iOS |
| Typography | SF Pro / SF Rounded via system font; Dynamic Type respected | Roboto Flex / Google Sans via system font; font scale respected |
| Icons | SF Symbols through the native widget layer where possible; Cupertino icons in Flutter | Material Symbols (rounded) |
| Dark mode | Follow system; semantic colors only | Follow system; dynamic color (Material You) on by default, brand accent as fallback |

Hard rules:

- No Material components rendered on iOS, no Cupertino on Android. The adaptive layer picks; screens never import either directly.
- Edge-to-edge on both platforms. Content draws under system bars; safe areas handled by the adaptive scaffold, never by hand.
- Back gesture works everywhere: iOS swipe-back and Android predictive back must never be broken by a custom transition.
- Text scales. Every layout is tested at 130% and 200% text size. Nothing is clipped, nothing is ellipsised that matters.
- Reduced motion and reduced transparency are honored. Glass and blur fall back to solid surfaces.

## 2. The 2026 look: quiet, material, confident

What "clean, simple, leading" means in practice this year:

- **Surfaces do the work.** iOS 26 Liquid Glass bars and Material 3 Expressive containers already carry the personality. Do not add cards inside cards, gradient washes, or drop shadows under everything. One elevated surface per screen at most.
- **One accent.** Each app has exactly one accent color (spec §8). It is used for the primary action, the selected state, and the widget tint. Nowhere else. Everything else is semantic neutrals from the platform.
- **Type is the hierarchy.** Size and weight, not color or boxes, separate title from body. Use the platform type scale (Large Title / Title / Body / Footnote on iOS; Display / Headline / Body / Label on Android). Never more than three sizes on one screen.
- **Generous, consistent spacing.** 8-pt grid. Screen margins 16 on phones, 24 on tablets. Vertical rhythm from a single spacing scale (4, 8, 12, 16, 24, 32, 48).
- **Motion answers the user.** Transitions are the platform defaults. Custom animation only when it shows what changed (a counter ticking up, a ring filling, a card expanding). No entrance animations on load, no idle animation, no shimmer unless something is actually loading.
- **Big, honest primary action.** One full-width primary button per screen, bottom-anchored, above the safe area. Label says what happens: "Start counting", "Save quote", not "Continue".
- **Numbers are the hero when there is a number.** Counters, totals, streaks: set in a rounded or tabular display size, centered, with a small label beneath. This is the one place to be bold.

Things that mark an app as generated or templated, and are banned:

- Hairline dividers between every list row on iOS (use inset grouped lists instead)
- All-caps section labels with tracked letter-spacing
- Emoji as icons
- Purple-to-blue gradient buttons
- A "Welcome to {App}!" first screen
- Identical rounded cards with the same shadow for unrelated content
- Illustration packs from the same stock set across sibling apps
- Placeholder avatars, sample names, "John Doe"

## 3. Onboarding and paywall (where the money is)

- Two to four screens. Each asks one question or makes one promise. Answers personalize the first screen of the app.
- Progress indicator is a thin bar at the top, not dots.
- Permission prompts (notifications, camera, health) are asked in context, after a one-line explanation screen, never on launch.
- The paywall is a native-feeling full-screen view: benefit list (three lines, user's words), plan picker with annual pre-selected and the saving shown, one primary button ("Start free trial" or "Continue"), restore and terms as small text. Close control appears after 2 seconds on iOS (Apple requires it be reachable) and is a top-left X.
- Pricing text is exact and localized. No "only", no strikethrough fake prices.
- The paywall is fed by RevenueCat offerings so pricing and copy can change without a release.

## 4. Widgets, Live Activities and glances

These are native code and they are the growth surface. Treat them as first-class.

**iOS**
- WidgetKit: small, medium, and lock-screen (accessory circular / rectangular / inline) for any app with a number or a countdown. Use `containerBackground` so widgets look right in StandBy and on the tinted home screen. Support tinted and clear rendering modes on iOS 26.
- Live Activities for anything in progress (timer, contraction, session). Dynamic Island compact and expanded views designed, not defaulted.
- Control Center controls and App Shortcuts (App Intents) for the app's single most common action ("Log a drink", "Start timer").
- Watch complication if the app's number is glanceable.

**Android**
- Glance widgets in at least two sizes, using dynamic color with the accent as fallback. Widget preview and description set for the picker.
- Ongoing notification with a live chip for in-progress activity; use the Android 16 live-update style where the device supports it.
- Wear tile if the iOS app gets a complication.
- Quick Settings tile for the single most common action.

Widget content rules: one number or one line, plus the accent. If it needs a legend, it's not a widget.

## 5. Icon

- One simple glyph on a flat or subtly graded background in the accent. No text, no gradients across the whole icon, no photo.
- iOS: provide the layered icon so iOS 26 can render light, dark, clear and tinted variants. Android: adaptive icon with foreground/background layers, themed monochrome layer provided.
- Sibling apps in the same category must not share a glyph family closely enough to look like a series.

## 6. Copy

- Sentence case everywhere. No exclamation marks in UI.
- Buttons name the outcome. Toasts confirm in the same word ("Saved").
- Empty states tell the user what to do next, in one line, with the primary action right there.
- Errors say what happened and what to do; they do not apologize.
- No feature names in user-facing copy. "Get a reminder every evening" not "Enable notifications".

## 7. Accessibility floor

Not optional, and checked by the Reviewer:

- Every interactive element has a label; every image that carries meaning has a description.
- Minimum touch target 44×44 pt iOS, 48×48 dp Android.
- Contrast 4.5:1 for text, 3:1 for large text and icons, in both light and dark.
- VoiceOver and TalkBack can complete onboarding, purchase, and the app's core action.
- Dynamic Type / font scale, reduced motion, and reduced transparency respected.

## 8. Quality loop

The Tester screenshots every screen on iPhone 17 Pro, iPhone SE-class small device, iPad, Pixel 10, and a small Android phone, in light and dark, at default and 200% text. The Reviewer looks at the screenshots against this guide before reading the code. Visual problems block sign-off exactly the same as failing tests.

Before sign-off, remove one thing from every screen. If nothing can be removed, the screen is done.
