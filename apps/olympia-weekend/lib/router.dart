import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/screens/app_shell.dart';
import 'package:olympia_weekend/screens/athletes_screen.dart';
import 'package:olympia_weekend/screens/now_screen.dart';
import 'package:olympia_weekend/screens/saved_screen.dart';
import 'package:olympia_weekend/screens/schedule_screen.dart';
import 'package:olympia_weekend/screens/venues_screen.dart';

/// Route names — keep in sync with `Analytics.viewNow`/etc callers.
abstract final class Routes {
  static const String now = 'now';
  static const String schedule = 'schedule';
  static const String athletes = 'athletes';
  static const String venues = 'venues';
  static const String saved = 'saved';
  static const String event = 'event';
  static const String athlete = 'athlete';
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: Routes.now,
                builder: (_, _) => const NowScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/schedule',
                name: Routes.schedule,
                builder: (_, _) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/athletes',
                name: Routes.athletes,
                builder: (_, _) => const AthletesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/venues',
                name: Routes.venues,
                builder: (_, _) => const VenuesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                name: Routes.saved,
                builder: (_, _) => const SavedScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

