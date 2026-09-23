import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_quote/screens/app_shell.dart';
import 'package:wash_quote/screens/job_detail_screen.dart';
import 'package:wash_quote/screens/onboarding_screen.dart';
import 'package:wash_quote/screens/quote_builder_screen.dart';

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
        builder: (_, _) => const AppShell(),
      ),
      GoRoute(
        path: '/quote/new',
        name: 'quote_new',
        builder: (_, _) => const QuoteBuilderScreen(),
      ),
      GoRoute(
        path: '/job/:id',
        name: 'job_detail',
        builder: (context, state) =>
            JobDetailScreen(jobId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
}

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
          if (!context.mounted) return;
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
