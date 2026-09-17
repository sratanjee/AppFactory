import 'package:factory_core/adaptive/platform.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoNavigationBar,
        CupertinoPageScaffold,
        CupertinoSliverNavigationBar;
import 'package:flutter/material.dart' show AppBar, Scaffold;
import 'package:flutter/widgets.dart';

enum TitleDisplay { standard, large, none }

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.body,
    this.title,
    this.leading,
    this.trailing,
    this.primaryAction,
    this.tabBar,
    this.backgroundColor,
    this.titleDisplay = TitleDisplay.standard,
    super.key,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? trailing;
  final Widget body;
  final Widget? primaryAction;
  final Widget? tabBar;
  final Color? backgroundColor;
  final TitleDisplay titleDisplay;

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOS) return _buildCupertino();
    return _buildMaterial();
  }

  Widget _buildCupertino() {
    final title = this.title;
    final leading = this.leading;
    final trailing = this.trailing;
    final primaryAction = this.primaryAction;
    final tabBar = this.tabBar;
    final backgroundColor = this.backgroundColor;
    final body = this.body;

    Widget content;
    if (title != null && titleDisplay == TitleDisplay.large) {
      content = CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: title,
            leading: leading,
            trailing: trailing == null
                ? null
                : Row(mainAxisSize: MainAxisSize.min, children: trailing),
          ),
          SliverToBoxAdapter(child: body),
        ],
      );
    } else {
      // CupertinoPageScaffold lets body draw under the translucent nav
      // bar — per DESIGN_GUIDE §1 the scaffold, not the app, offsets by
      // the nav bar height so content isn't hidden.
      content = title != null
          ? SafeArea(top: true, bottom: false, child: body)
          : body;
    }

    final scaffold = CupertinoPageScaffold(
      navigationBar: (title != null && titleDisplay == TitleDisplay.standard)
          ? CupertinoNavigationBar(
              middle: title,
              leading: leading,
              trailing: trailing == null
                  ? null
                  : Row(mainAxisSize: MainAxisSize.min, children: trailing),
            )
          : null,
      backgroundColor: backgroundColor,
      child: primaryAction == null
          ? content
          : Stack(
              children: [
                Positioned.fill(child: content),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.only(bottom: 16),
                    child: primaryAction,
                  ),
                ),
              ],
            ),
    );

    if (tabBar == null) return scaffold;
    return Column(
      children: [
        Expanded(child: scaffold),
        tabBar,
      ],
    );
  }

  Widget _buildMaterial() {
    final title = this.title;
    final leading = this.leading;
    final trailing = this.trailing;
    final primaryAction = this.primaryAction;
    final tabBar = this.tabBar;
    final backgroundColor = this.backgroundColor;
    final body = this.body;

    Widget? actionBar;
    if (primaryAction != null) {
      actionBar = SafeArea(
        top: false,
        bottom: tabBar == null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: primaryAction,
        ),
      );
    }

    Widget? bottomBar;
    if (tabBar != null && actionBar == null) {
      bottomBar = tabBar;
    } else if (actionBar != null && tabBar == null) {
      bottomBar = actionBar;
    } else if (tabBar != null && actionBar != null) {
      bottomBar = Column(
        mainAxisSize: MainAxisSize.min,
        children: [actionBar, tabBar],
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: (title == null || titleDisplay == TitleDisplay.none)
          ? null
          : AppBar(
              title: title,
              leading: leading,
              actions: trailing,
            ),
      body: body,
      bottomNavigationBar: bottomBar,
    );
  }
}
