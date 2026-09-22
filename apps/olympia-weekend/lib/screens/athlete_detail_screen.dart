import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/features/instagram.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/features/sightings_repo.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/router.dart';
import 'package:olympia_weekend/widgets/card.dart';

class AthleteDetailScreen extends ConsumerStatefulWidget {
  const AthleteDetailScreen({required this.athleteId, super.key});

  final String athleteId;

  @override
  ConsumerState<AthleteDetailScreen> createState() =>
      _AthleteDetailScreenState();
}

class _AthleteDetailScreenState extends ConsumerState<AthleteDetailScreen> {
  final Set<String> _optimisticallyConfirmed = {};
  String? _errorMsg;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final data = ref.watch(athletesProvider);
    return ColoredBox(
      color: colors.background,
      child: AdaptiveScaffold(
        backgroundColor: colors.background,
        titleDisplay: TitleDisplay.none,
        body: SafeArea(
          bottom: false,
          child: data.when(
            loading: () => const Center(child: AdaptiveLoading()),
            error: (_, __) => Center(
              child: Text(AppStrings.errorLiveRefresh,
                  style: TextStyle(color: colors.textMuted)),
            ),
            data: (payload) {
              final athlete = payload.athletes.firstWhere(
                (a) => a.id == widget.athleteId,
                orElse: () => Athlete(
                  id: widget.athleteId,
                  name: widget.athleteId,
                  divisionId: 'mens-open',
                  country: '',
                  tagline: '',
                  appearances: const [],
                ),
              );
              final division = payload.divisions.firstWhere(
                (d) => d.id == athlete.divisionId,
                orElse: () => Division(
                  id: athlete.divisionId,
                  name: athlete.divisionId,
                  prejudgingEventId: '',
                  finalsEventId: '',
                ),
              );
              ref.read(mixpanelProvider).viewAthlete(
                    athleteId: athlete.id,
                    division: division.id,
                    hasInstagram: athlete.instagram != null,
                    hasAppearance: athlete.appearances.isNotEmpty,
                  );
              return _buildBody(athlete, division);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Athlete athlete, Division division) {
    final colors = context.olympiaColors;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(Routes.athletes);
              }
            },
            child: Text('‹ ${AppStrings.athletesTitle}',
                style: TextStyle(fontSize: 15, color: colors.textMuted)),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            athlete.name,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: colors.text),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '${division.name}${athlete.country.isEmpty ? '' : ' · ${athlete.country}'}',
            style: TextStyle(fontSize: 15, color: colors.textMuted),
          ),
        ),
        if (athlete.instagram != null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OlympiaCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 14),
              child: GestureDetector(
                onTap: () {
                  ref.read(mixpanelProvider).openInstagram(athlete.id);
                  openInstagram(athlete.instagram!);
                },
                child: Row(
                  children: [
                    Text(
                      AppStrings.athleteInstagram,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.text),
                    ),
                    const Spacer(),
                    Text(
                      '@${athlete.instagram}',
                      style: TextStyle(
                          fontSize: 15, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (athlete.appearances.isNotEmpty) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppStrings.athleteAppearances,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: colors.text),
            ),
          ),
          const SizedBox(height: 10),
          for (final a in athlete.appearances) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: _AppearanceCard(
                athleteId: athlete.id,
                appearance: a,
                optimisticallyConfirmed: _optimisticallyConfirmed
                    .contains(a.appearanceKey(athlete.id)),
                onSaw: () => _handleSaw(athlete, a),
              ),
            ),
          ],
        ],
        if (_errorMsg != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMsg!,
              style: const TextStyle(fontSize: 13, color: Color(0xFFe2231a)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Future<void> _handleSaw(Athlete athlete, Appearance appearance) async {
    setState(() => _errorMsg = null);
    final repo = ref.read(sightingsRepoProvider);
    final result = await repo.confirm(
      athleteId: athlete.id,
      appearance: appearance,
    );
    if (!mounted) return;
    setState(() {
      switch (result) {
        case ConfirmSightingResult.inserted:
        case ConfirmSightingResult.duplicate:
        case ConfirmSightingResult.disabled:
          _optimisticallyConfirmed.add(appearance.appearanceKey(athlete.id));
        case ConfirmSightingResult.rateLimited:
          _errorMsg = AppStrings.athleteSightingRateLimited;
          ref.read(mixpanelProvider).error(
                where: 'confirm_sighting',
                message: 'rate_limited',
              );
        case ConfirmSightingResult.failed:
          _errorMsg = AppStrings.athleteSightingFailed;
          ref.read(mixpanelProvider).error(
                where: 'confirm_sighting',
                message: 'network',
              );
      }
    });
    if (result == ConfirmSightingResult.inserted) {
      ref.read(mixpanelProvider).confirmSighting(
            athleteId: athlete.id,
            booth: appearance.booth,
            resultingStatus: 'confirmed',
          );
    }
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({
    required this.athleteId,
    required this.appearance,
    required this.optimisticallyConfirmed,
    required this.onSaw,
  });

  final String athleteId;
  final Appearance appearance;
  final bool optimisticallyConfirmed;
  final VoidCallback onSaw;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final confirmed = optimisticallyConfirmed ||
        appearance.status == AppearanceStatus.confirmed;
    return OlympiaCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${appearance.start}  ·  ${appearance.booth}',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.text),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: confirmed
                      ? colors.badgeConfirmedBg
                      : colors.badgeReportedBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  confirmed
                      ? AppStrings.athleteConfirmed
                      : AppStrings.athleteReported,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: confirmed
                        ? colors.badgeConfirmedText
                        : colors.badgeReportedText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AdaptiveSecondaryButton(
            label: AppStrings.athleteISawThis,
            onPressed: onSaw,
          ),
        ],
      ),
    );
  }
}
