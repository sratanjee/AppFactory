import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/router.dart';
import 'package:olympia_weekend/widgets/card.dart';

class AthletesScreen extends ConsumerStatefulWidget {
  const AthletesScreen({super.key});

  @override
  ConsumerState<AthletesScreen> createState() => _AthletesScreenState();
}

class _AthletesScreenState extends ConsumerState<AthletesScreen> {
  final _searchController = TextEditingController();
  String? _divisionId;
  String _query = '';
  bool _tracked = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final athletesAsync = ref.watch(athletesProvider);
    return ColoredBox(
      color: colors.background,
      child: AdaptiveScaffold(
        backgroundColor: colors.background,
        titleDisplay: TitleDisplay.none,
        body: SafeArea(
          bottom: false,
          child: athletesAsync.when(
            loading: () => const Center(child: AdaptiveLoading()),
            error: (_, __) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppStrings.errorLiveRefresh,
                style: TextStyle(color: colors.textMuted),
              ),
            ),
            data: (payload) {
              final divisionId = _divisionId ?? payload.divisions.first.id;
              if (!_tracked) {
                _tracked = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(mixpanelProvider).viewAthletes(divisionId);
                });
              }
              return _buildBody(payload, divisionId);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AthletesPayload payload, String divisionId) {
    final colors = context.olympiaColors;
    final athletes = payload.athletes
        .where((a) => a.divisionId == divisionId)
        .where((a) => _query.isEmpty ||
            a.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            AppStrings.athletesTitle,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: colors.text,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              for (final d in payload.divisions)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _DivisionChip(
                    label: d.name,
                    active: d.id == divisionId,
                    onTap: () {
                      setState(() => _divisionId = d.id);
                      ref.read(mixpanelProvider).viewAthletes(d.id);
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AdaptiveInput(
            controller: _searchController,
            placeholder: AppStrings.athletesSearchHint,
            onChanged: (v) {
              setState(() => _query = v);
              ref.read(mixpanelProvider).searchAthletes(v.length, 0);
            },
          ),
        ),
        const SizedBox(height: 12),
        if (athletes.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _query.isEmpty
                  ? AppStrings.athletesDivisionEmpty
                  : AppStrings.athletesSearchEmpty
                      .replaceAll('{query}', _query),
              style: TextStyle(color: colors.textMuted),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OlympiaCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < athletes.length; i++) ...[
                    _AthleteRow(
                      athlete: athletes[i],
                      onTap: () {
                        context.goNamed(Routes.athlete,
                            pathParameters: {'id': athletes[i].id});
                      },
                    ),
                    if (i != athletes.length - 1)
                      const OlympiaDivider(indent: 78),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _DivisionChip extends StatelessWidget {
  const _DivisionChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? colors.pillActiveBg : colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.surfaceBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? colors.pillActiveText : colors.text,
          ),
        ),
      ),
    );
  }
}

class _AthleteRow extends StatelessWidget {
  const _AthleteRow({required this.athlete, required this.onTap});
  final Athlete athlete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.avatarBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                athlete.initials,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.avatarText,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    athlete.name,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    athlete.tagline.isEmpty
                        ? (athlete.booth ?? AppStrings.athletesNoBooth)
                        : athlete.tagline,
                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
