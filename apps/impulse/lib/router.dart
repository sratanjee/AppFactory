import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/screens/home_screen.dart';
import 'package:impulse/screens/onboarding_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/boot',
    routes: [
      GoRoute(
        path: '/boot',
        name: 'boot',
        builder: (_, _) => const _BootScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, _) => const HomeScreen(),
      ),
    ],
  );
}

/// Reads the persisted `hasSeenOnboarding` flag and routes accordingly.
class _BootScreen extends ConsumerWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _hasSeenOnboarding(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AdaptiveScaffold(body: AdaptiveLoading());
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(snapshot.data == true ? '/home' : '/onboarding');
        });
        return const AdaptiveScaffold(body: AdaptiveLoading());
      },
    );
  }

  Future<bool> _hasSeenOnboarding(WidgetRef ref) async {
    final kv = await ref.read(keyValueStoreProvider.future);
    return await kv.getBool('hasSeenOnboarding') ?? false;
  }
}
