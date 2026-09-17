import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WidgetBridgeDemoScreen extends ConsumerStatefulWidget {
  const WidgetBridgeDemoScreen({super.key});

  @override
  ConsumerState<WidgetBridgeDemoScreen> createState() =>
      _WidgetBridgeDemoScreenState();
}

class _WidgetBridgeDemoScreenState
    extends ConsumerState<WidgetBridgeDemoScreen> {
  int _counter = 0;
  Map<String, Object?>? _lastRead;

  @override
  Widget build(BuildContext context) {
    final bridge = ref.read(widgetBridgeProvider);

    return AdaptiveScaffold(
      title: const Text('Widget bridge'),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Suite: ${bridge.suiteName}'),
            const SizedBox(height: 8),
            const Text(
              'Publishes a counter payload. On iOS/Android, a native widget '
              'target would read this from the shared store — no widget '
              'target is wired in the example runner, so use "Read back" to '
              'confirm the round-trip.',
            ),
            const SizedBox(height: 24),
            Text('Counter: $_counter'),
            if (_lastRead != null) Text('Last read: $_lastRead'),
            const SizedBox(height: 24),
            AdaptiveSecondaryButton(
              label: 'Publish (increment)',
              onPressed: () async {
                setState(() => _counter++);
                await bridge.publish({
                  'count': _counter,
                  'label': 'Drinks',
                  'updatedAt': DateTime.now(),
                });
              },
            ),
            const SizedBox(height: 12),
            AdaptiveSecondaryButton(
              label: 'Read back',
              onPressed: () async {
                final v = await bridge.read();
                setState(() => _lastRead = v);
              },
            ),
            const SizedBox(height: 12),
            AdaptiveDestructiveButton(
              label: 'Clear',
              onPressed: () async {
                await bridge.clear();
                setState(() {
                  _counter = 0;
                  _lastRead = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
