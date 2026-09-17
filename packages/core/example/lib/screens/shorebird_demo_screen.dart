import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShorebirdDemoScreen extends ConsumerWidget {
  const ShorebirdDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.read(shorebirdClientProvider);
    final patch = ref.watch(currentPatchProvider);

    return AdaptiveScaffold(
      title: const Text('Shorebird'),
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: AdaptiveIcon(AdaptiveIconName.chevronLeft, size: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('isAvailable: ${client.isAvailable}'),
            const SizedBox(height: 8),
            patch.when(
              data: (n) => Text('currentPatchNumber: ${n ?? "null"}'),
              loading: () => const Text('currentPatchNumber: loading...'),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            const Text(
              'The example overrides shorebirdClientProvider with '
              'ShorebirdClient.disabled(), so isAvailable is false and the '
              'patch number is null. Real values only appear in a build '
              'run via `shorebird preview` or `shorebird release`.',
            ),
          ],
        ),
      ),
      primaryAction: AdaptivePrimaryButton(
        label: 'Check for update',
        onPressed: client.checkAndUpdate,
      ),
    );
  }
}
