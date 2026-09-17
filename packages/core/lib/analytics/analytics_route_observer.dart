import 'package:factory_core/analytics/analytics_client.dart';
import 'package:flutter/widgets.dart';

/// NavigatorObserver that fires `Analytics.screen(name: routeName)` on every
/// push and replace. Routes without a `settings.name` are skipped.
///
/// Wired in the scaffolder-generated app boilerplate by default; apps can
/// remove it if screen views aren't wanted.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final Analytics _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _fireScreen(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _fireScreen(newRoute);
  }

  void _fireScreen(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      _analytics.screen(name: name);
    }
  }
}
