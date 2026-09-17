import 'package:factory_core/adaptive/platform.dart';
import 'package:factory_core/adaptive/theme.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoListSection, CupertinoListTile, CupertinoListTileChevron;
import 'package:flutter/material.dart' show Card, Divider, ListTile;
import 'package:flutter/widgets.dart';

class AdaptiveListSection {
  const AdaptiveListSection({
    required this.items,
    this.header,
    this.footer,
  });

  final List<AdaptiveListItem> items;
  final String? header;
  final String? footer;
}

class AdaptiveListItem {
  const AdaptiveListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.hasNavigation = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool hasNavigation;
}

class AdaptiveList extends StatelessWidget {
  const AdaptiveList({
    required this.sections,
    this.scrollable = true,
    super.key,
  });

  final List<AdaptiveListSection> sections;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOS) return _buildCupertino(context);
    return _buildMaterial(context);
  }

  Widget _buildCupertino(BuildContext context) {
    final children = <Widget>[
      for (final section in sections)
        CupertinoListSection.insetGrouped(
          header: section.header == null ? null : Text(section.header!),
          footer: section.footer == null ? null : Text(section.footer!),
          children: [
            for (final item in section.items)
              CupertinoListTile.notched(
                title: Text(item.title),
                subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                leading: item.leading,
                trailing: item.hasNavigation
                    ? const CupertinoListTileChevron()
                    : item.trailing,
                onTap: item.onTap,
              ),
          ],
        ),
    ];
    return scrollable ? ListView(children: children) : Column(children: children);
  }

  Widget _buildMaterial(BuildContext context) {
    final theme = context.adaptiveTheme;
    final children = <Widget>[];
    for (final section in sections) {
      if (section.header != null) {
        children.add(
          Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacing.lg,
              theme.spacing.xl,
              theme.spacing.lg,
              theme.spacing.sm,
            ),
            child: Text(
              section.header!,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        );
      }
      children.add(
        Card(
          margin: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
          child: Column(
            children: [
              for (var j = 0; j < section.items.length; j++) ...[
                ListTile(
                  title: Text(section.items[j].title),
                  subtitle: section.items[j].subtitle == null
                      ? null
                      : Text(section.items[j].subtitle!),
                  leading: section.items[j].leading,
                  trailing: section.items[j].trailing,
                  onTap: section.items[j].onTap,
                ),
                if (j < section.items.length - 1)
                  Divider(height: 1, indent: theme.spacing.lg),
              ],
            ],
          ),
        ),
      );
      if (section.footer != null) {
        children.add(
          Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacing.lg,
              theme.spacing.sm,
              theme.spacing.lg,
              theme.spacing.lg,
            ),
            child: Text(
              section.footer!,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        );
      }
    }
    return scrollable ? ListView(children: children) : Column(children: children);
  }
}
