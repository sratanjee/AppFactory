import 'package:factory_core/adaptive/adaptive_icon.dart';
import 'package:factory_core/adaptive/theme.dart';
import 'package:flutter/widgets.dart';

/// The "one-line explanation before the system prompt" pattern from
/// DESIGN_GUIDE §3. Drop into an `OnboardingStep.build` and wire the actual
/// permission request via `OnboardingStep.onPrimary`.
///
/// Renders a centered icon in the accent color, a large title, and a
/// one-line body. The bottom-anchored primary button (Allow, Enable
/// notifications, etc.) comes from the surrounding `OnboardingFlow`.
class PermissionPromptCard extends StatelessWidget {
  const PermissionPromptCard({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  final AdaptiveIconName icon;

  /// One-line title: what the user gets. Not the feature name.
  final String title;

  /// One-line body: what the app will do with the permission. Concrete.
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdaptiveIcon(icon, size: 48, color: theme.accent),
          SizedBox(height: theme.spacing.xl),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: theme.spacing.md),
          Text(body, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
