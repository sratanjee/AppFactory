import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/screens/app_shell.dart';
import 'package:olympia_weekend/screens/athlete_detail_screen.dart';
import 'package:olympia_weekend/screens/athletes_screen.dart';
import 'package:olympia_weekend/screens/event_detail_screen.dart';
import 'package:olympia_weekend/screens/expo_screen.dart';
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
  static const String expo = 'expo';
  static const String saved = 'saved';
  static const String event = 'event';
  static const String athlete = 'athlete';
}

/// Singleton GoRouter — exposed so incoming deep links (`olympia://schedule`)
/// can push routes from outside the widget tree via `app_links`.
final routerProvider = Provider<GoRouter>((_) => buildRouter());

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/e/:id',
        name: Routes.event,
        pageBuilder: (_, state) => _slidePage(
          state,
          EventDetailScreen(eventId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/a/:id',
        name: Routes.athlete,
        pageBuilder: (_, state) => _slidePage(
          state,
          AthleteDetailScreen(athleteId: state.pathParameters['id']!),
        ),
      ),
      // Saved lives outside the shell now — a heart action on the Now
      // header opens `/saved`. Keeping the URL means saved-links from
      // Mixpanel emails etc. still land somewhere useful.
      GoRoute(
        path: '/saved',
        name: Routes.saved,
        pageBuilder: (_, state) => _slidePage(state, const SavedScreen()),
      ),
      // Legacy aliases so old bookmarks / share sheets still work.
      // Both point at the new hub with a preselected segment.
      GoRoute(
        path: '/expo/exhibitors',
        redirect: (_, _) => '/expo?tab=exhibitors',
      ),
      GoRoute(
        path: '/expo/events',
        redirect: (_, _) => '/expo?tab=events',
      ),
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
                path: '/expo',
                name: Routes.expo,
                builder: (_, state) => ExpoScreen(
                  initialTab: state.uri.queryParameters['tab'],
                ),
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
        ],
      ),
    ],
  );
}

/// Consistent detail-push transition: slide-from-right with a fade,
/// 260 ms `easeOutCubic` in / 220 ms `easeInCubic` out. iOS default on
/// mobile, matched by our web build so tabs on desktop don't get the
/// jarring Material fade that ships with MaterialPage on Chrome.
CustomTransitionPage<T> _slidePage<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondary, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fade =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
