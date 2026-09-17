import 'dart:async';

import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class StorageDemoScreen extends StatefulWidget {
  const StorageDemoScreen({super.key});

  @override
  State<StorageDemoScreen> createState() => _StorageDemoScreenState();
}

class _StorageDemoScreenState extends State<StorageDemoScreen> {
  final _kv = KeyValueStore.inMemory();
  int _counter = 0;
  int? _lastRead;

  @override
  void dispose() {
    unawaited(_kv.close());
    super.dispose();
  }

  Future<void> _increment() async {
    setState(() => _counter++);
    await _kv.setInt('counter', _counter);
  }

  Future<void> _readBack() async {
    final v = await _kv.getInt('counter');
    setState(() => _lastRead = v);
  }

  Future<void> _clear() async {
    await _kv.clear();
    setState(() {
      _counter = 0;
      _lastRead = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Storage'),
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
            const Text(
              'KeyValueStore.inMemory() lives for this screen only. Try the '
              'buttons, then leave the screen — the store disposes.',
            ),
            const SizedBox(height: 24),
            Text('Counter: $_counter'),
            if (_lastRead != null) Text('Last read: $_lastRead'),
            const SizedBox(height: 24),
            AdaptiveSecondaryButton(
              label: 'Increment + persist',
              onPressed: _increment,
            ),
            const SizedBox(height: 12),
            AdaptiveSecondaryButton(
              label: 'Read counter',
              onPressed: _readBack,
            ),
            const SizedBox(height: 12),
            AdaptiveDestructiveButton(
              label: 'Clear store',
              onPressed: _clear,
            ),
          ],
        ),
      ),
    );
  }
}
