import 'package:factory_core/factory_core.dart';
import 'package:flutter/material.dart' show Icons, ReorderableListView;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/service_repo.dart';
import 'package:wash_quote/features/money_format.dart';
import 'package:wash_quote/l10n/app_strings.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    return AdaptiveScaffold(
      title: const Text(AppStrings.servicesTitle),
      body: servicesAsync.when(
        loading: () => const AdaptiveLoading(),
        error: (_, _) => AdaptiveError(
          message: AppStrings.servicesErrorSave,
          onRetry: () => ref.invalidate(servicesProvider),
        ),
        data: (services) {
          if (services.isEmpty) {
            return AdaptiveEmpty(
              message: AppStrings.servicesEmpty,
              primaryAction: AdaptivePrimaryButton(
                label: AppStrings.servicesAdd,
                onPressed: () => _showEditor(context, ref, existing: null),
              ),
            );
          }
          return _ServiceList(services: services);
        },
      ),
      primaryAction: AdaptivePrimaryButton(
        label: AppStrings.servicesAdd,
        onPressed: () => _showEditor(context, ref, existing: null),
      ),
    );
  }
}

Future<void> _showEditor(
  BuildContext context,
  WidgetRef ref, {
  required Service? existing,
}) async {
  await AdaptiveSheet.show<void>(
    context,
    child: ColoredBox(
      color: const Color(0xFFFFFFFF),
      child: _ServiceEditor(existing: existing),
    ),
  );
}

class _ServiceList extends ConsumerWidget {
  const _ServiceList({required this.services});

  final List<Service> services;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.adaptiveTheme;
    return ReorderableListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.lg,
        vertical: theme.spacing.md,
      ),
      itemCount: services.length,
      onReorderItem: (oldIndex, newIndex) async {
        final ordered = [...services];
        final moved = ordered.removeAt(oldIndex);
        ordered.insert(newIndex, moved);
        await ref
            .read(serviceRepoProvider)
            .reorder(ordered.map((s) => s.id).toList());
      },
      itemBuilder: (context, i) {
        final s = services[i];
        return _ServiceRow(
          key: ValueKey(s.id),
          service: s,
          onEdit: () => _showEditor(context, ref, existing: s),
          onDelete: () async {
            final confirm = await AdaptiveDialog.confirm<bool>(
              context,
              title: 'Remove ${s.name}?',
              actions: const [
                AdaptiveDialogAction(
                  label: AppStrings.cancel,
                  value: false,
                  isCancel: true,
                ),
                AdaptiveDialogAction(
                  label: AppStrings.remove,
                  value: true,
                  isDestructive: true,
                ),
              ],
            );
            if (confirm == true) {
              await ref.read(serviceRepoProvider).delete(s.id);
            }
          },
        );
      },
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.service,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Service service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final unit = ServiceUnitCode.fromCode(service.unit);
    return Container(
      margin: EdgeInsets.only(bottom: theme.spacing.sm),
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.lg,
        vertical: theme.spacing.md,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(theme.cornerRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name, style: const TextStyle(fontSize: 16)),
                  Text(
                    '${Money.formatCents(service.unitPriceCents)} '
                    '${_unitLabel(unit)}',
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: AdaptiveIcon(AdaptiveIconName.trash, size: 18),
            ),
          ),
          const Icon(Icons.drag_handle, color: Color(0xFF888888)),
        ],
      ),
    );
  }
}

class _ServiceEditor extends ConsumerStatefulWidget {
  const _ServiceEditor({required this.existing});

  final Service? existing;

  @override
  ConsumerState<_ServiceEditor> createState() => _ServiceEditorState();
}

class _ServiceEditorState extends ConsumerState<_ServiceEditor> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.existing == null
        ? ''
        : (widget.existing!.unitPriceCents / 100).toStringAsFixed(2),
  );
  late ServiceUnit _unit = widget.existing == null
      ? ServiceUnit.sqft
      : ServiceUnitCode.fromCode(widget.existing!.unit);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final priceText = _price.text.trim();
    final priceDouble = double.tryParse(priceText);
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    if (priceDouble == null || priceDouble <= 0) {
      setState(() => _error = 'Price must be positive');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final cents = (priceDouble * 100).round();
    final repo = ref.read(serviceRepoProvider);
    try {
      if (widget.existing == null) {
        await repo.add(name: name, unit: _unit, unitPriceCents: cents);
      } else {
        await repo.update(
          id: widget.existing!.id,
          name: name,
          unit: _unit,
          unitPriceCents: cents,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = AppStrings.servicesErrorSave;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Padding(
      padding: EdgeInsets.only(
        left: theme.spacing.lg,
        right: theme.spacing.lg,
        top: theme.spacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + theme.spacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null
                ? AppStrings.servicesAdd
                : widget.existing!.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: theme.spacing.lg),
          const Text(AppStrings.servicesName,
              style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
          SizedBox(height: theme.spacing.xs),
          AdaptiveInput(controller: _name, placeholder: 'Name'),
          SizedBox(height: theme.spacing.lg),
          const Text(AppStrings.servicesUnit,
              style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
          SizedBox(height: theme.spacing.sm),
          AdaptiveSegmentedControl<ServiceUnit>(
            segments: const [
              AdaptiveSegment(value: ServiceUnit.sqft, label: 'sq ft'),
              AdaptiveSegment(value: ServiceUnit.linft, label: 'lin ft'),
              AdaptiveSegment(value: ServiceUnit.flat, label: 'flat'),
              AdaptiveSegment(value: ServiceUnit.hour, label: 'hour'),
            ],
            selectedValue: _unit,
            onChanged: (v) => setState(() => _unit = v),
          ),
          SizedBox(height: theme.spacing.lg),
          const Text(AppStrings.servicesUnitPrice,
              style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
          SizedBox(height: theme.spacing.xs),
          AdaptiveInput(
            controller: _price,
            placeholder: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          if (_error != null) ...[
            SizedBox(height: theme.spacing.md),
            Text(_error!, style: const TextStyle(color: Color(0xFFB3261E))),
          ],
          SizedBox(height: theme.spacing.xl),
          AdaptivePrimaryButton(
            label: AppStrings.save,
            onPressed: _save,
            isLoading: _saving,
            enabled: !_saving,
          ),
        ],
      ),
    );
  }
}

String _unitLabel(ServiceUnit unit) {
  switch (unit) {
    case ServiceUnit.sqft:
      return AppStrings.servicesUnitSqft;
    case ServiceUnit.linft:
      return AppStrings.servicesUnitLinft;
    case ServiceUnit.flat:
      return AppStrings.servicesUnitFlat;
    case ServiceUnit.hour:
      return AppStrings.servicesUnitHour;
  }
}
