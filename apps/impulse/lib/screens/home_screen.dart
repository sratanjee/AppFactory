import 'dart:io' show Platform;

import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/data/app_database.dart';
import 'package:impulse/data/items_repo.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedTotalMinorProvider);
    final waiting = ref.watch(waitingItemsProvider);
    final ready = ref.watch(readyItemsProvider);

    return AdaptiveScaffold(
      title: const Text('Impulse'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SavedTotal(minor: saved.value ?? 0),
          const SizedBox(height: 24),
          _Section(
            title: 'Ready',
            child: ready.when(
              data: (items) => items.isEmpty
                  ? const _EmptyRow(text: 'Nothing ready yet.')
                  : Column(
                      children: [
                        for (final item in items) _ReadyRow(item: item),
                      ],
                    ),
              loading: () => const AdaptiveLoading(),
              error: (e, _) => AdaptiveError(message: e.toString()),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Waiting',
            child: waiting.when(
              data: (items) => items.isEmpty
                  ? const _EmptyRow(text: 'Nothing waiting.')
                  : Column(
                      children: [
                        for (final item in items) _WaitingRow(item: item),
                      ],
                    ),
              loading: () => const AdaptiveLoading(),
              error: (e, _) => AdaptiveError(message: e.toString()),
            ),
          ),
        ],
      ),
      primaryAction: AdaptivePrimaryButton(
        label: 'Add something',
        onPressed: () async {
          await _showAddSheet(context, ref);
        },
      ),
    );
  }
}

class _SavedTotal extends StatelessWidget {
  const _SavedTotal({required this.minor});
  final int minor;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final formatted = _formatCurrency(minor / 100);
    return Column(
      children: [
        Text(
          formatted,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w700,
            color: theme.accent,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        const Text('Saved', style: TextStyle(fontSize: 14)),
      ],
    );
  }
}

String _formatCurrency(double amount) {
  final code = _localeCurrencyCode();
  return NumberFormat.simpleCurrency(name: code).format(amount);
}

String _localeCurrencyCode() {
  try {
    final locale = Platform.localeName;
    final format = NumberFormat.simpleCurrency(locale: locale);
    return format.currencyName ?? 'USD';
  } on Object {
    return 'USD';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        child,
      ],
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text, style: const TextStyle(color: Color(0xFF888888))),
    );
  }
}

class _WaitingRow extends StatelessWidget {
  const _WaitingRow({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    final remaining = item.decideAt - DateTime.now().millisecondsSinceEpoch;
    return _ItemRow(
      name: item.name,
      price: _priceString(item),
      trailing: Text(_formatRemaining(remaining),
          style: const TextStyle(color: Color(0xFF888888))),
    );
  }
}

class _ReadyRow extends ConsumerWidget {
  const _ReadyRow({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ItemRow(
      name: item.name,
      price: _priceString(item),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdaptiveTextButton(
            label: 'Bought',
            onPressed: () async {
              final ok = await AdaptiveDialog.confirm<bool>(
                context,
                title: 'Mark as bought?',
                actions: const [
                  AdaptiveDialogAction(
                      label: 'Cancel', value: false, isCancel: true),
                  AdaptiveDialogAction(label: 'Bought', value: true),
                ],
              );
              if (ok == true) {
                ref
                    .read(analyticsProvider)
                    .trackCoreAction(properties: {'action': 'bought'});
                await ref
                    .read(itemsRepoProvider)
                    .decide(item.id, ItemDecision.bought);
              }
            },
          ),
          const SizedBox(width: 8),
          AdaptiveTextButton(
            label: 'Skipped',
            onPressed: () async {
              final ok = await AdaptiveDialog.confirm<bool>(
                context,
                title: 'Mark as skipped?',
                actions: const [
                  AdaptiveDialogAction(
                      label: 'Cancel', value: false, isCancel: true),
                  AdaptiveDialogAction(label: 'Skipped', value: true),
                ],
              );
              if (ok == true) {
                ref
                    .read(analyticsProvider)
                    .trackCoreAction(properties: {'action': 'skipped'});
                await ref
                    .read(itemsRepoProvider)
                    .decide(item.id, ItemDecision.skipped);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.name,
    required this.price,
    required this.trailing,
  });

  final String name;
  final String price;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16)),
                Text(price, style: const TextStyle(color: Color(0xFF888888))),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

String _priceString(Item item) {
  final amount = item.priceMinor / 100;
  return NumberFormat.simpleCurrency(name: item.currency).format(amount);
}

String _formatRemaining(int ms) {
  if (ms <= 0) return 'Ready';
  final totalMinutes = (ms / 60000).ceil();
  if (totalMinutes < 60) return '${totalMinutes}m';
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours < 24) return '${hours}h ${minutes}m';
  final days = hours ~/ 24;
  final leftoverHours = hours % 24;
  return '${days}d ${leftoverHours}h';
}

Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
  await AdaptiveSheet.show<void>(
    context,
    child: _AddSheet(ref: ref),
  );
}

class _AddSheet extends StatefulWidget {
  const _AddSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  int _waitHours = 48;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();
    if (name.isEmpty || priceText.isEmpty) return;
    final priceDouble = double.tryParse(priceText);
    if (priceDouble == null || priceDouble <= 0) return;

    setState(() => _saving = true);
    AdaptiveHaptics.medium();
    final priceMinor = (priceDouble * 100).round();
    final currency = _localeCurrencyCode();

    await widget.ref.read(itemsRepoProvider).add(
          name: name,
          priceMinor: priceMinor,
          currency: currency,
          waitHours: _waitHours,
        );
    widget.ref.read(analyticsProvider).trackCoreAction(
        properties: {'action': 'add', 'wait_hours': _waitHours});
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Add something',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          const Text('Name',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
          const SizedBox(height: 4),
          AdaptiveInput(controller: _nameController, placeholder: 'What was it?'),
          const SizedBox(height: 16),
          const Text('Price',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
          const SizedBox(height: 4),
          AdaptiveInput(
            controller: _priceController,
            placeholder: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 24),
          const Text('Wait period',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
          const SizedBox(height: 8),
          AdaptiveSegmentedControl<int>(
            segments: const [
              AdaptiveSegment(value: 24, label: '24h'),
              AdaptiveSegment(value: 48, label: '48h'),
              AdaptiveSegment(value: 72, label: '72h'),
              AdaptiveSegment(value: 168, label: '7d'),
            ],
            selectedValue: _waitHours,
            onChanged: (v) => setState(() => _waitHours = v),
          ),
          const SizedBox(height: 24),
          AdaptivePrimaryButton(
            label: 'Save',
            onPressed: _save,
            isLoading: _saving,
            enabled: !_saving,
          ),
        ],
      ),
    );
  }
}
