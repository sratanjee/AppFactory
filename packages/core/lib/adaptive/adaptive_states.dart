import 'package:factory_core/adaptive/theme.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/widgets.dart';

class AdaptiveLoading extends StatelessWidget {
  const AdaptiveLoading({this.size = 24, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoActivityIndicator(radius: size / 2),
    );
  }
}

class AdaptiveError extends StatelessWidget {
  const AdaptiveError({
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              SizedBox(height: theme.spacing.lg),
              GestureDetector(
                onTap: onRetry,
                child: Text(
                  retryLabel,
                  style: TextStyle(color: theme.accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdaptiveEmpty extends StatelessWidget {
  const AdaptiveEmpty({
    required this.message,
    required this.primaryAction,
    super.key,
  });

  final String message;
  final Widget primaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: theme.spacing.xl),
            primaryAction,
          ],
        ),
      ),
    );
  }
}
