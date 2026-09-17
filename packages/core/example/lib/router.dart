import 'package:factory_core_example/screens/adaptive_demo_screen.dart';
import 'package:factory_core_example/screens/analytics_demo_screen.dart';
import 'package:factory_core_example/screens/home_screen.dart';
import 'package:factory_core_example/screens/onboarding_demo_screen.dart';
import 'package:factory_core_example/screens/paywall_demo_screen.dart';
import 'package:factory_core_example/screens/shorebird_demo_screen.dart';
import 'package:factory_core_example/screens/storage_demo_screen.dart';
import 'package:factory_core_example/screens/widget_bridge_demo_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, _) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'adaptive',
            name: 'adaptive',
            builder: (_, _) => const AdaptiveDemoScreen(),
          ),
          GoRoute(
            path: 'onboarding',
            name: 'onboarding',
            builder: (_, _) => const OnboardingDemoScreen(),
          ),
          GoRoute(
            path: 'paywall',
            name: 'paywall',
            builder: (_, _) => const PaywallDemoScreen(),
          ),
          GoRoute(
            path: 'storage',
            name: 'storage',
            builder: (_, _) => const StorageDemoScreen(),
          ),
          GoRoute(
            path: 'analytics',
            name: 'analytics',
            builder: (_, _) => const AnalyticsDemoScreen(),
          ),
          GoRoute(
            path: 'widget-bridge',
            name: 'widget-bridge',
            builder: (_, _) => const WidgetBridgeDemoScreen(),
          ),
          GoRoute(
            path: 'shorebird',
            name: 'shorebird',
            builder: (_, _) => const ShorebirdDemoScreen(),
          ),
        ],
      ),
    ],
  );
}
