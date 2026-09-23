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
    this.transitionBetweenRoutes = false,
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

  /// iOS-only: forwards to the underlying `CupertinoNavigationBar`'s
  /// `transitionBetweenRoutes`.
  ///
  /// Defaults to `false` because the factory's common shape is a tab-shell
  /// with several `AdaptiveScaffold`s co-existing in an `IndexedStack`. All
  /// four of those Cupertino nav bars share the default hero tag, which the
  /// framework refuses to render (`multiple heroes with the same tag`).
  /// Opting out of the hero-based nav-bar transition is the standard fix
  /// and matches Apple's behaviour for tab-rooted screens. A single-screen
  /// pushed-route app can opt back in per-instance.
  final bool transitionBetweenRoutes;

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

    // When there's no title but the caller passes leading/trailing widgets
    // (an overflow menu, a Back arrow), still render a translucent nav bar
    // so those toolbar items appear. Previously an untitled screen dropped
    // trailing entirely — the seizure-log home screen hit this landmine.
    final hasBarItems =
        leading != null || (trailing != null && trailing.isNotEmpty);

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
            transitionBetweenRoutes: transitionBetweenRoutes,
          ),
          SliverToBoxAdapter(child: body),
        ],
      );
    } else {
      // CupertinoPageScaffold lets body draw under the translucent nav
      // bar — per DESIGN_GUIDE §1 the scaffold, not the app, offsets by
      // the nav bar height so content isn't hidden.
      content = (title != null || hasBarItems)
          ? SafeArea(bottom: false, child: body)
          : body;
    }

    final showStandardNavBar = titleDisplay == TitleDisplay.standard &&
        (title != null || hasBarItems);
    final scaffold = CupertinoPageScaffold(
      navigationBar: showStandardNavBar
          ? CupertinoNavigationBar(
              middle: title,
              leading: leading,
              trailing: trailing == null
                  ? null
                  : Row(mainAxisSize: MainAxisSize.min, children: trailing),
              transitionBetweenRoutes: transitionBetweenRoutes,
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
