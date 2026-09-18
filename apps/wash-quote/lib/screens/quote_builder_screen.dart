import 'dart:async';
import 'dart:io' show File;

import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_quote/data/app_database.dart';
import 'package:wash_quote/data/business_repo.dart';
import 'package:wash_quote/data/customer_repo.dart';
import 'package:wash_quote/data/job_repo.dart';
import 'package:wash_quote/data/service_repo.dart';
import 'package:wash_quote/features/money_format.dart';
import 'package:wash_quote/features/paywall_gate.dart';
import 'package:wash_quote/features/photo_capture.dart';
import 'package:wash_quote/l10n/app_strings.dart';

class _DraftLine {
  _DraftLine({
    required this.serviceId,
    required this.description,
    required this.qty,
    required this.unitPriceCents,
  });

  final int? serviceId;
  final String description;
  double qty;
  int unitPriceCents;

  int get totalCents => (qty * unitPriceCents).round();
}

class QuoteBuilderScreen extends ConsumerStatefulWidget {
  const QuoteBuilderScreen({super.key});

  @override
  ConsumerState<QuoteBuilderScreen> createState() => _QuoteBuilderScreenState();
}

class _QuoteBuilderScreenState extends ConsumerState<QuoteBuilderScreen> {
  Customer? _customer;
  final List<_DraftLine> _lines = [];
  final List<String> _photoPaths = [];
  int _depositPct = 25;
  String _payVia = '';
  bool _saving = false;
  String? _error;
  bool _initialized = false;

  int get _totalCents => _lines.fold<int>(0, (a, l) => a + l.totalCents);

  Future<void> _initFromBusiness() async {
    if (_initialized) return;
    _initialized = true;
    final biz = await ref.read(businessRepoProvider).get();
    if (!mounted || biz == null) return;
    setState(() {
      _payVia = biz.payVia;
      _depositPct = biz.defaultDepositPct;
    });
  }

  @override
  Widget build(BuildContext context) {
    unawaited(_initFromBusiness());
    final theme = context.adaptiveTheme;
    final servicesAsync = ref.watch(servicesProvider);

    return AdaptiveScaffold(
      title: const Text(AppStrings.builderTitle),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.lg,
            vertical: theme.spacing.md,
          ),
          children: [
            _CustomerField(
              customer: _customer,
              onPick: _pickCustomer,
            ),
            SizedBox(height: theme.spacing.xl),
            _sectionLabel(AppStrings.builderLines),
            SizedBox(height: theme.spacing.sm),
            if (_lines.isEmpty)
              servicesAsync.maybeWhen(
                data: (services) => services.isEmpty
                    ? _EmptyServicesRow(onOpen: _openServicesTab)
                    : _AddLineButton(onTap: () => _addLineFromList(services)),
                orElse: () => const SizedBox.shrink(),
              )
            else ...[
              for (var i = 0; i < _lines.length; i++)
                _LineRow(
                  line: _lines[i],
                  onChangeQty: (qty) {
                    setState(() => _lines[i].qty = qty);
                  },
                  onRemove: () => setState(() => _lines.removeAt(i)),
                ),
              SizedBox(height: theme.spacing.sm),
              servicesAsync.maybeWhen(
                data: (services) => _AddLineButton(
                  onTap: () => _addLineFromList(services),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
            SizedBox(height: theme.spacing.xl),
            _DepositRow(
              value: _depositPct,
              onChanged: (v) => setState(() => _depositPct = v),
            ),
            SizedBox(height: theme.spacing.lg),
            _PayViaRow(
              value: _payVia,
              onChanged: (v) => setState(() => _payVia = v),
            ),
            SizedBox(height: theme.spacing.xl),
            _sectionLabel(AppStrings.builderBeforePhotos),
            SizedBox(height: theme.spacing.sm),
            _PhotoStrip(
              paths: _photoPaths,
              onAdd: _addPhoto,
              onRemove: (i) => setState(() => _photoPaths.removeAt(i)),
            ),
            SizedBox(height: theme.spacing.xl),
            _TotalRow(cents: _totalCents),
            if (_error != null) ...[
              SizedBox(height: theme.spacing.md),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFB3261E)),
              ),
            ],
            SizedBox(height: theme.spacing.xxl),
          ],
        ),
      ),
      primaryAction: AdaptivePrimaryButton(
        label: AppStrings.builderSave,
        onPressed: _save,
        isLoading: _saving,
        enabled: !_saving && _lines.isNotEmpty,
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
      );

  Future<void> _pickCustomer() async {
    final picked = await AdaptiveSheet.show<Customer>(
      context,
      child: ColoredBox(
        color: const Color(0xFFFFFFFF),
        child: _CustomerPickSheet(),
      ),
    );
    if (picked != null) setState(() => _customer = picked);
  }

  Future<void> _addLineFromList(List<Service> services) async {
    final picked = await AdaptiveSheet.show<Service>(
      context,
      child: ColoredBox(
        color: const Color(0xFFFFFFFF),
        child: _ServicePickSheet(services: services),
      ),
    );
    if (picked == null) return;
    setState(() {
      _lines.add(
        _DraftLine(
          serviceId: picked.id,
          description: picked.name,
          qty: _defaultQty(ServiceUnitCode.fromCode(picked.unit)),
          unitPriceCents: picked.unitPriceCents,
        ),
      );
    });
  }

  double _defaultQty(ServiceUnit unit) {
    switch (unit) {
      case ServiceUnit.flat:
      case ServiceUnit.hour:
        return 1;
      case ServiceUnit.sqft:
        return 500;
      case ServiceUnit.linft:
        return 100;
    }
  }

  Future<void> _addPhoto() async {
    final path = await capturePhotoFromCamera(context);
    if (path == null) return;
    setState(() => _photoPaths.add(path));
  }

  void _openServicesTab() {
    // Popping the builder returns the user to the Jobs tab; the shell's
    // Services tab is one tap away, and this is the least surprising jump
    // without stashing extra state.
    context.pop();
  }

  Future<void> _save() async {
    if (_saving) return;
    final ok = await ensureProEntitlement(
      context,
      ref,
      placement: 'first_save',
    );
    if (!ok || !mounted) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final jobId = await ref.read(jobRepoProvider).createQuote(
            customerId: _customer?.id,
            depositPct: _depositPct,
            lines: _lines
                .map(
                  (l) => NewLineItem(
                    serviceId: l.serviceId,
                    description: l.description,
                    qty: l.qty,
                    unitPriceCents: l.unitPriceCents,
                  ),
                )
                .toList(),
            photos: _photoPaths
                .map(
                  (p) => (path: p, kind: PhotoKind.before, takenAt: now),
                )
                .toList(),
          );
      ref
          .read(analyticsProvider)
          .trackCoreAction(properties: {'action': 'save_quote'});
      if (!mounted) return;
      context.pushReplacement('/job/$jobId');
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = AppStrings.builderErrorSave;
        });
      }
    }
  }
}

class _CustomerField extends StatelessWidget {
  const _CustomerField({required this.customer, required this.onPick});

  final Customer? customer;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPick,
      child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.builderCustomer,
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                  ),
                  Text(
                    customer?.name ?? AppStrings.builderCustomerPick,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const AdaptiveIcon(AdaptiveIconName.chevronRight, size: 20),
          ],
        ),
      ),
    );
  }
}

class _EmptyServicesRow extends StatelessWidget {
  const _EmptyServicesRow({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Text(AppStrings.builderEmptyServices)),
        AdaptiveTextButton(
          label: AppStrings.builderEmptyServicesLink,
          onPressed: onOpen,
        ),
      ],
    );
  }
}

class _AddLineButton extends StatelessWidget {
  const _AddLineButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: theme.accent),
          borderRadius: BorderRadius.circular(theme.cornerRadius.md),
        ),
        child: Row(
          children: [
            AdaptiveIcon(AdaptiveIconName.plus, size: 16, color: theme.accent),
            SizedBox(width: theme.spacing.sm),
            Text(
              AppStrings.builderAddLine,
              style: TextStyle(color: theme.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.line,
    required this.onChangeQty,
    required this.onRemove,
  });

  final _DraftLine line;
  final ValueChanged<double> onChangeQty;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.description, style: const TextStyle(fontSize: 16)),
                Text(
                  '${Money.formatCents(line.unitPriceCents)} '
                  '× ${_qtyString(line.qty)} = ${Money.formatCents(line.totalCents)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          _QtyStepper(qty: line.qty, onChanged: onChangeQty),
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: AdaptiveIcon(AdaptiveIconName.trash, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

String _qtyString(double qty) {
  if (qty == qty.roundToDouble()) return qty.toInt().toString();
  return qty.toStringAsFixed(1);
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.qty, required this.onChanged});

  final double qty;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Row(
      children: [
        _StepBtn(
          label: '-',
          onTap: () {
            final step = qty > 100 ? 100.0 : (qty > 10 ? 10.0 : 1.0);
            onChanged((qty - step).clamp(0, double.infinity));
          },
        ),
        SizedBox(width: theme.spacing.xs),
        SizedBox(
          width: 48,
          child: Text(
            _qtyString(qty),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        SizedBox(width: theme.spacing.xs),
        _StepBtn(
          label: '+',
          onTap: () {
            final step = qty >= 100 ? 100.0 : (qty >= 10 ? 10.0 : 1.0);
            onChanged(qty + step);
          },
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: theme.accent),
          borderRadius: BorderRadius.circular(theme.cornerRadius.sm),
        ),
        child: Text(label, style: TextStyle(color: theme.accent, fontSize: 16)),
      ),
    );
  }
}

class _DepositRow extends StatelessWidget {
  const _DepositRow({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Text(AppStrings.builderDepositLabel)),
        _StepBtn(
          label: '-',
          onTap: () => onChanged((value - 5).clamp(0, 100)),
        ),
        SizedBox(
          width: 64,
          child: Text(
            '$value%',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        _StepBtn(
          label: '+',
          onTap: () => onChanged((value + 5).clamp(0, 100)),
        ),
      ],
    );
  }
}

class _PayViaRow extends StatefulWidget {
  const _PayViaRow({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_PayViaRow> createState() => _PayViaRowState();
}

class _PayViaRowState extends State<_PayViaRow> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(_PayViaRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 80,
          child: Text(AppStrings.builderPayVia),
        ),
        Expanded(
          child: AdaptiveInput(
            controller: _controller,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({
    required this.paths,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> paths;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length + 1,
        separatorBuilder: (_, _) => SizedBox(width: theme.spacing.sm),
        itemBuilder: (context, i) {
          if (i == paths.length) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAdd,
              child: Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.accent),
                  borderRadius: BorderRadius.circular(theme.cornerRadius.md),
                ),
                child: AdaptiveIcon(
                  AdaptiveIconName.cameraSymbol,
                  color: theme.accent,
                ),
              ),
            );
          }
          return GestureDetector(
            onLongPress: () => onRemove(i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.cornerRadius.md),
              child: SizedBox(
                width: 96,
                height: 96,
                child: Image.file(File(paths[i]), fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.cents});
  final int cents;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          AppStrings.builderTotalLabel,
          style: TextStyle(fontSize: 16),
        ),
        Text(
          Money.formatCents(cents),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: theme.accent,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _ServicePickSheet extends ConsumerWidget {
  const _ServicePickSheet({required this.services});
  final List<Service> services;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.adaptiveTheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: theme.spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
              child: const Text(
                AppStrings.builderAddLine,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: theme.spacing.md),
            for (final s in services)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(s),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.lg,
                    vertical: theme.spacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: const TextStyle(fontSize: 16)),
                            Text(
                              Money.formatCents(s.unitPriceCents),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const AdaptiveIcon(
                        AdaptiveIconName.chevronRight,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomerPickSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CustomerPickSheet> createState() => _CustomerPickSheetState();
}

class _CustomerPickSheetState extends ConsumerState<_CustomerPickSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final customersAsync = ref.watch(customersProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: theme.spacing.lg,
          right: theme.spacing.lg,
          top: theme.spacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + theme.spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              AppStrings.customerSheetTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: theme.spacing.md),
            customersAsync.maybeWhen(
              data: (list) => list.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          AppStrings.customerPickExisting,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                        for (final c in list)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(context).pop(c),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: theme.spacing.sm,
                              ),
                              child: Text(
                                c.name,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        SizedBox(height: theme.spacing.md),
                      ],
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
            const Text(
              AppStrings.customerAddNew,
              style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
            SizedBox(height: theme.spacing.sm),
            AdaptiveInput(
              controller: _name,
              placeholder: AppStrings.customerName,
            ),
            SizedBox(height: theme.spacing.sm),
            AdaptiveInput(
              controller: _phone,
              placeholder: AppStrings.customerPhone,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: theme.spacing.sm),
            AdaptiveInput(
              controller: _email,
              placeholder: AppStrings.customerEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: theme.spacing.sm),
            AdaptiveInput(
              controller: _address,
              placeholder: AppStrings.customerAddress,
            ),
            SizedBox(height: theme.spacing.lg),
            AdaptivePrimaryButton(
              label: AppStrings.customerSave,
              onPressed: _save,
              isLoading: _adding,
              enabled: !_adding,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _adding = true);
    final id = await ref.read(customerRepoProvider).add(
          name: name,
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        );
    final row = await ref.read(customerRepoProvider).byId(id);
    if (!mounted) return;
    Navigator.of(context).pop(row);
  }
}
