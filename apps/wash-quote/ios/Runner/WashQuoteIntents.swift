import AppIntents
import Foundation
import UIKit

/// Deep-link URL the intent opens. Flutter's built-in deep linking
/// (FlutterDeepLinkingEnabled=YES in Info.plist) routes this to
/// go_router's `/quote/new`, which arms the camera.
private let newQuoteURL = URL(string: "washquote:///quote/new")!

/// "New quote" App Intent — the single most common action from spec §5.
/// Opens the app and deep-links into the quote-builder camera-first flow.
@available(iOS 16.0, *)
struct NewQuoteIntent: AppIntent {
  static var title: LocalizedStringResource = "New quote"
  static var description = IntentDescription(
    "Start a new quote and open the camera to snap the surface."
  )

  /// Bring the app to the foreground; Flutter handles the actual deep link.
  static var openAppWhenRun: Bool = true

  @MainActor
  func perform() async throws -> some IntentResult {
    // Open the deep link once the app is foregrounded. UIApplication.open
    // dispatches on the main queue and returns immediately.
    await UIApplication.shared.open(newQuoteURL)
    return .result()
  }
}

/// App Shortcut so "New quote" appears in the Shortcuts app and Siri
/// suggestions without the operator having to build a shortcut by hand.
@available(iOS 16.0, *)
struct WashQuoteShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: NewQuoteIntent(),
      phrases: [
        "New quote in \(.applicationName)",
        "Start a new quote in \(.applicationName)",
        "Quote a job in \(.applicationName)"
      ],
      shortTitle: "New quote",
      systemImageName: "camera.viewfinder"
    )
  }
}

// Control Center control (iOS 18+) is deferred: it requires a separate
// WidgetKit extension target with its own bundle and entitlements,
// which is outside the scope of the v1 native surface build. The App
// Shortcut above is what spec §5 requires. Revisit when factory adds
// widgets_ios extension scaffolding.
