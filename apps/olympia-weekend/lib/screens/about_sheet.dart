import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/features/backstage.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/widgets/pressable.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the About sheet — tagline, links, version, plus the Backstage
/// access-code panel at the bottom. Reachable via a tap on the Now
/// header title.
Future<void> showAboutSheet(BuildContext context) {
  return AdaptiveSheet.show<void>(
    context,
    child: const _AboutSheet(),
  );
}

class _AboutSheet extends ConsumerStatefulWidget {
  const _AboutSheet();

  @override
  ConsumerState<_AboutSheet> createState() => _AboutSheetState();
}

class _AboutSheetState extends ConsumerState<_AboutSheet>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  late final AnimationController _shake;
  String? _inlineError;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final unlocked = ref.watch(backstageUnlockedProvider);

    return DefaultTextStyle(
      style: context.olympiaText.row.copyWith(fontWeight: FontWeight.w400),
      child: ColoredBox(
        color: colors.background,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(AppStrings.aboutTitle, style: context.olympiaText.title),
              const SizedBox(height: 8),
              Text(
                AppStrings.aboutTagline,
                style: context.olympiaText.row.copyWith(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              _linkRow(
                context,
                label: AppStrings.aboutTickets,
                url: 'https://mrolympia.com/tickets',
              ),
              _linkRow(
                context,
                label: AppStrings.aboutLivestream,
                url: 'https://mrolympia.com/live',
              ),
              _linkRow(
                context,
                label: AppStrings.aboutReport,
                url: 'mailto:sratanjee@gmail.com'
                    '?subject=Olympia%20Weekend%20fix',
              ),
              const SizedBox(height: 12),
              Text(
                '${AppStrings.aboutVersion} 1.0.0',
                style: context.olympiaText.caption,
              ),
              const SizedBox(height: 24),
              Container(height: 1, color: colors.surfaceBorder),
              const SizedBox(height: 20),
              Text(
                'Backstage',
                style: context.olympiaText.section.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 8),
              if (unlocked)
                _lockedState(context, colors)
              else
                _unlockForm(context, colors),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linkRow(BuildContext context,
      {required String label, required String url}) {
    final colors = context.olympiaColors;
    return OlympiaPressable(
      onTap: () => _openUrl(url),
      semanticsLabel: label,
      minSize: const Size(0, 44),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.olympiaText.row.copyWith(
                  color: colors.text,
                ),
              ),
            ),
            Text(
              '↗',
              style: context.olympiaText.row.copyWith(
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unlockForm(BuildContext context, OlympiaColors colors) {
    return AnimatedBuilder(
      animation: _shake,
      builder: (ctx, child) {
        final t = _shake.value;
        // Small horizontal sine shake — 3 cycles, ±8px amplitude.
        final dx = t == 0
            ? 0.0
            : 8 * (1 - t) * _sineWave(t * 3);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Staff and competitors: enter the access code to reveal athlete meetings, weigh-ins, and the judge's meeting.",
            style: context.olympiaText.caption.copyWith(height: 1.4),
          ),
          const SizedBox(height: 12),
          AdaptiveInput(
            controller: _codeController,
            placeholder: 'Access code',
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: context.olympiaText.row.copyWith(
              color: colors.text,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (_inlineError != null) ...[
            const SizedBox(height: 8),
            Text(
              _inlineError!,
              style: context.olympiaText.caption.copyWith(
                color: const Color(0xFFe2231a),
              ),
            ),
          ],
          const SizedBox(height: 12),
          AdaptivePrimaryButton(
            label: _submitting ? 'Checking…' : 'Unlock',
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _lockedState(BuildContext context, OlympiaColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You're in Backstage. Athlete meetings, weigh-ins, and the judge's meeting are now visible on Schedule and Now.",
          style: context.olympiaText.caption.copyWith(height: 1.4),
        ),
        const SizedBox(height: 12),
        AdaptiveSecondaryButton(
          label: 'Lock again',
          onPressed: () async {
            await ref.read(backstageUnlockedProvider.notifier).lock();
            if (!mounted) return;
            Navigator.of(context).maybePop();
          },
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _inlineError = null;
    });
    final ok = await ref
        .read(backstageUnlockedProvider.notifier)
        .tryUnlock(_codeController.text);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      _showToast(context, 'Backstage unlocked');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.of(context).maybePop();
    } else {
      setState(() => _inlineError = 'Not valid');
      _shake
        ..reset()
        ..forward();
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  double _sineWave(double t) {
    // Cheap sine approximation good enough for a UI shake.
    final x = (t * 2 - 1);
    return x - (x * x * x) / 6;
  }
}

void _showToast(BuildContext context, String message) {
  final colors = context.olympiaColors;
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      left: 24,
      right: 24,
      bottom: MediaQuery.of(ctx).padding.bottom + 24,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.surfaceBorder),
            ),
            child: Text(
              message,
              style: context.olympiaText.row.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.text,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), entry.remove);
}
