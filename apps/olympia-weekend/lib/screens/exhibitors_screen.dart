import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/data/exhibitors_repo.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/widgets/async_body.dart';
import 'package:olympia_weekend/widgets/card.dart';
import 'package:olympia_weekend/widgets/pressable.dart';

/// Searchable list of the 154 World Fitness Expo booths.
///
/// Mirrors the Athletes-screen scaffolding — title + subtitle caption +
/// AdaptiveInput + one card-of-rows. Booth rows themselves are not
/// tappable in v1 (no booth-detail page), but the "See stage events"
/// chip up top jumps to `/expo/events`.
class ExhibitorsScreen extends ConsumerStatefulWidget {
  const ExhibitorsScreen({super.key});

  @override
  ConsumerState<ExhibitorsScreen> createState() => _ExhibitorsScreenState();
}

class _ExhibitorsScreenState extends ConsumerState<ExhibitorsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final exhibitorsAsync = ref.watch(exhibitorsProvider);
    return ColoredBox(
      color: colors.background,
      child: AdaptiveScaffold(
        backgroundColor: colors.background,
        titleDisplay: TitleDisplay.none,
        body: SafeArea(
          bottom: false,
          child: OlympiaAsyncBody(
            child: exhibitorsAsync.when(
              loading: () => const Center(
                key: ValueKey('loading'),
                child: AdaptiveLoading(),
              ),
              error: (_, _) => Padding(
                key: const ValueKey('error'),
                padding: const EdgeInsets.all(24),
                child: Text(
                  AppStrings.errorLiveRefresh,
                  style: context.olympiaText.row.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.textMuted,
                  ),
                ),
              ),
              data: (exhibitors) => KeyedSubtree(
                key: const ValueKey('data'),
                child: _buildBody(exhibitors),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<Exhibitor> all) {
    final colors = context.olympiaColors;
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((e) => e.name.toLowerCase().contains(q)).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            AppStrings.expoTitle,
            style: context.olympiaText.title,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            AppStrings.expoSubtitle,
            style: context.olympiaText.caption.copyWith(fontSize: 14),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _StageEventsChip(
              onTap: () => context.go('/expo/events'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AdaptiveInput(
            controller: _searchController,
            placeholder: AppStrings.expoSearchHint,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppStrings.expoSearchEmpty.replaceAll('{query}', _query),
              style: context.olympiaText.row.copyWith(
                fontWeight: FontWeight.w400,
                color: colors.textMuted,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OlympiaCard(
              padding: EdgeInsets.zero,
              // stretch — same fix as venues_screen; without it the inner
              // Column centers each row to its intrinsic width and short
              // booth rows (e.g. "GNC · 1461") slide right of the long
              // ones. Rows are Row(children) so they lay out at full card
              // width once stretched.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < filtered.length; i++) ...[
                    _ExhibitorRow(exhibitor: filtered[i]),
                    if (i != filtered.length - 1) const OlympiaDivider(),
                  ],
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          child: Text(
            AppStrings.expoFooter,
            style: context.olympiaText.caption.copyWith(height: 1.45),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _StageEventsChip extends StatelessWidget {
  const _StageEventsChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return OlympiaPressable(
      onTap: onTap,
      semanticsLabel: AppStrings.expoStageChip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.surfaceBorder),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.expoStageChip,
              style: context.olympiaText.row.copyWith(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              '→',
              style: context.olympiaText.row.copyWith(
                fontSize: 14,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExhibitorRow extends StatelessWidget {
  const _ExhibitorRow({required this.exhibitor});

  final Exhibitor exhibitor;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    // No detail page in v1 — mark as non-button so screen readers don't
    // announce it as tappable.
    return Semantics(
      button: false,
      label: '${exhibitor.name}, booth ${exhibitor.booth}',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  exhibitor.name,
                  style: context.olympiaText.row,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                exhibitor.booth,
                style: context.olympiaText.faint.copyWith(
                  color: colors.textMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
