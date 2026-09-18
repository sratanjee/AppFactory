import 'dart:io' show File;

import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wash_quote/data/business_repo.dart';
import 'package:wash_quote/data/service_repo.dart';
import 'package:wash_quote/data/starter_services.dart';
import 'package:wash_quote/l10n/app_strings.dart';

/// Three-step onboarding + paywall handoff, per PLAN §6.
///
/// Answers persist as they're captured (`_state` below) so re-entering a
/// step never loses input. On step 3 completion:
///
/// 1. Write the `Business` row.
/// 2. Seed `Service` rows from `starterServices` — only when the table is
///    empty; the "seed only once" contract is enforced by
///    `hasSeenOnboarding`, which is checked in `_BootScreen`, but this
///    query defends against a hand-modified KV file too.
/// 3. Present the paywall at `after_onboarding`.
/// 4. Flip `hasSeenOnboarding`, route to `/home`.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingState {
  String businessName = '';
  String? logoPath;
  final Map<String, int> serviceCents = {
    for (final s in starterServices) s.name: s.defaultCents,
  };
  final Set<String> selectedServices = {
    for (final s in starterServices) s.name,
  };
  String payVia = '';
  int depositPct = 25;
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _state = _OnboardingState();

  @override
  Widget build(BuildContext context) {
    return OnboardingFlow(
      steps: [
        OnboardingStep(
          canAdvance: _state.businessName.trim().isNotEmpty,
          build: (context, sc) => _BusinessStep(
            state: _state,
            onChanged: (v) {
              _state.businessName = v;
              sc.setCanAdvance(canAdvance: v.trim().isNotEmpty);
            },
            onLogoChanged: () => setState(() {}),
          ),
        ),
        OnboardingStep(
          build: (context, sc) => _ServicesStep(state: _state, onChange: () {
            setState(() {});
          }),
        ),
        OnboardingStep(
          build: (context, sc) => _PayViaStep(
            state: _state,
            onChange: () => setState(() {}),
          ),
        ),
      ],
      onComplete: (_) async {
        await _finish(context);
      },
    );
  }

  Future<void> _finish(BuildContext context) async {
    final business = ref.read(businessRepoProvider);
    final services = ref.read(serviceRepoProvider);
    final kv = await ref.read(keyValueStoreProvider.future);

    await business.upsertSingleton(
      name: _state.businessName.trim(),
      logoPath: _state.logoPath,
      payVia: _state.payVia.trim(),
      defaultDepositPct: _state.depositPct,
    );

    final existing = await services.getAll();
    if (existing.isEmpty) {
      var i = 0;
      for (final s in starterServices) {
        if (!_state.selectedServices.contains(s.name)) continue;
        await services.add(
          name: s.name,
          unit: s.unit,
          unitPriceCents: _state.serviceCents[s.name] ?? s.defaultCents,
          sortOrder: i++,
        );
      }
    }

    if (!context.mounted) return;
    final paywall = ref.read(paywallProvider);
    await PaywallScreen.show(
      context,
      paywall: paywall,
      placement: 'after_onboarding',
    );

    await kv.setBool('hasSeenOnboarding', true);
    if (!context.mounted) return;
    context.go('/home');
  }
}

class _BusinessStep extends StatefulWidget {
  const _BusinessStep({
    required this.state,
    required this.onChanged,
    required this.onLogoChanged,
  });

  final _OnboardingState state;
  final ValueChanged<String> onChanged;
  final VoidCallback onLogoChanged;

  @override
  State<_BusinessStep> createState() => _BusinessStepState();
}

class _BusinessStepState extends State<_BusinessStep> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.state.businessName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    widget.state.logoPath = file.path;
    widget.onLogoChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final hasLogo = widget.state.logoPath != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: theme.spacing.xl),
        const Text(
          AppStrings.onboardingBusinessName,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: theme.spacing.xl),
        AdaptiveInput(
          controller: _controller,
          placeholder: AppStrings.onboardingBusinessNameHint,
          onChanged: widget.onChanged,
        ),
        SizedBox(height: theme.spacing.lg),
        if (hasLogo)
          Row(
            children: [
              _LogoPreview(path: widget.state.logoPath!),
              SizedBox(width: theme.spacing.md),
              Expanded(
                child: AdaptiveTextButton(
                  label: AppStrings.onboardingLogoChange,
                  onPressed: _pickLogo,
                ),
              ),
            ],
          )
        else
          AdaptiveTextButton(
            label: AppStrings.onboardingLogoPick,
            onPressed: _pickLogo,
          ),
      ],
    );
  }
}

class _LogoPreview extends StatelessWidget {
  const _LogoPreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Image.file(File(path), fit: BoxFit.cover),
    );
  }
}

class _ServicesStep extends StatelessWidget {
  const _ServicesStep({required this.state, required this.onChange});

  final _OnboardingState state;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: theme.spacing.xl),
        const Text(
          AppStrings.onboardingServices,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: theme.spacing.sm),
        const Text(AppStrings.onboardingServicesHint),
        SizedBox(height: theme.spacing.lg),
        Expanded(
          child: ListView.builder(
            itemCount: starterServices.length,
            itemBuilder: (context, i) {
              final s = starterServices[i];
              return _StarterRow(
                starter: s,
                selected: state.selectedServices.contains(s.name),
                cents: state.serviceCents[s.name] ?? s.defaultCents,
                onToggle: (v) {
                  if (v) {
                    state.selectedServices.add(s.name);
                  } else {
                    state.selectedServices.remove(s.name);
                  }
                  onChange();
                },
                onCents: (cents) {
                  state.serviceCents[s.name] = cents;
                  onChange();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StarterRow extends StatefulWidget {
  const _StarterRow({
    required this.starter,
    required this.selected,
    required this.cents,
    required this.onToggle,
    required this.onCents,
  });

  final StarterService starter;
  final bool selected;
  final int cents;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onCents;

  @override
  State<_StarterRow> createState() => _StarterRowState();
}

class _StarterRowState extends State<_StarterRow> {
  late final TextEditingController _controller =
      TextEditingController(text: (widget.cents / 100).toStringAsFixed(2));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.sm),
      child: Row(
        children: [
          AdaptiveSwitch(
            value: widget.selected,
            onChanged: widget.onToggle,
          ),
          SizedBox(width: theme.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.starter.name,
                    style: const TextStyle(fontSize: 16)),
                Text(
                  _unitLabel(widget.starter.unit),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            child: AdaptiveInput(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) {
                final d = double.tryParse(v);
                if (d != null && d >= 0) {
                  widget.onCents((d * 100).round());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PayViaStep extends StatefulWidget {
  const _PayViaStep({required this.state, required this.onChange});

  final _OnboardingState state;
  final VoidCallback onChange;

  @override
  State<_PayViaStep> createState() => _PayViaStepState();
}

class _PayViaStepState extends State<_PayViaStep> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.state.payVia);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: theme.spacing.xl),
        const Text(
          AppStrings.onboardingPayVia,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: theme.spacing.xl),
        AdaptiveInput(
          controller: _controller,
          placeholder: AppStrings.onboardingPayViaHint,
          onChanged: (v) {
            widget.state.payVia = v;
            widget.onChange();
          },
        ),
        SizedBox(height: theme.spacing.xl),
        const Text(
          AppStrings.onboardingDepositLabel,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: theme.spacing.sm),
        _DepositStepper(
          value: widget.state.depositPct,
          onChanged: (v) {
            widget.state.depositPct = v;
            widget.onChange();
          },
        ),
      ],
    );
  }
}

class _DepositStepper extends StatelessWidget {
  const _DepositStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Row(
      children: [
        _StepperButton(
          label: '-',
          onTap: () => onChanged((value - 5).clamp(0, 100)),
        ),
        SizedBox(width: theme.spacing.md),
        SizedBox(
          width: 64,
          child: Text(
            '$value%',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(width: theme.spacing.md),
        _StepperButton(
          label: '+',
          onTap: () => onChanged((value + 5).clamp(0, 100)),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: theme.accent),
          borderRadius: BorderRadius.circular(theme.cornerRadius.sm),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 20, color: theme.accent),
        ),
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
