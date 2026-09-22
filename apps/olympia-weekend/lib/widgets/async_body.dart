import 'package:flutter/widgets.dart';

/// Fades between the async states of a screen body so the switch from
/// spinner to data (or spinner to error) reads as intentional, not as
/// a white flash. 200 ms is short enough to feel instant, long enough
/// to hide a frame-boundary hitch on cold loads.
class OlympiaAsyncBody extends StatelessWidget {
  const OlympiaAsyncBody({
    required this.child,
    // `child`'s Key must change across states so AnimatedSwitcher
    // triggers the fade. Callers pass 'loading' / 'error' / 'data' or
    // similar via a keyed subtree.
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      child: child,
    );
  }
}
