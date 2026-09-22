import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/design_tokens.dart';

/// Bottom tab bar matching `design/olympia-weekend/*-main.html` — 84 px
/// tall, five outline icons, active state uses `colors.text` (never the
/// red accent). Reviewer round 1 blocker 5: no red pill, no tinted bar.
class OlympiaTabBar extends StatelessWidget {
  const OlympiaTabBar({
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<OlympiaTabDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.surfaceBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _OlympiaTabItem(
                      destination: destinations[i],
                      active: i == currentIndex,
                      onTap: () => onDestinationSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OlympiaTabDestination {
  const OlympiaTabDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final AdaptiveIconName icon;
  final AdaptiveIconName selectedIcon;
  final String label;
}

class _OlympiaTabItem extends StatelessWidget {
  const _OlympiaTabItem({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  final OlympiaTabDestination destination;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final tint = active ? colors.text : colors.textFaint;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdaptiveIcon(
            active ? destination.selectedIcon : destination.icon,
            size: 22,
            color: tint,
          ),
          const SizedBox(height: 4),
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.olympiaText.tab(active: active).copyWith(color: tint),
          ),
        ],
      ),
    );
  }
}
