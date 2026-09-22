import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/features/directions.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/widgets/card.dart';

class VenuesScreen extends ConsumerStatefulWidget {
  const VenuesScreen({super.key});

  @override
  ConsumerState<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends ConsumerState<VenuesScreen> {
  bool _tracked = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final venuesAsync = ref.watch(venuesProvider);
    return ColoredBox(
      color: colors.background,
      child: AdaptiveScaffold(
        backgroundColor: colors.background,
        titleDisplay: TitleDisplay.none,
        body: SafeArea(
          bottom: false,
          child: venuesAsync.when(
            loading: () => const Center(child: AdaptiveLoading()),
            error: (_, __) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppStrings.venuesMapFallback,
                style: TextStyle(color: colors.textMuted),
              ),
            ),
            data: (venues) {
              if (!_tracked) {
                _tracked = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(mixpanelProvider).viewVenues();
                });
              }
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Text(
                      AppStrings.venuesTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: colors.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppStrings.venuesSubtitle,
                      style: TextStyle(fontSize: 14, color: colors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Map placeholder / fallback. Real Google Maps widget
                  // ships in a follow-up (task 10 of PLAN §8) — the text
                  // list below already gives the user directions.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 160,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.surfaceBorder),
                      ),
                      child: Text(
                        AppStrings.venuesMapFallback,
                        style: TextStyle(color: colors.textFaint),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: OlympiaCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (var i = 0; i < venues.length; i++) ...[
                            _VenueRow(
                              venue: venues[i],
                              onTap: () => _open(venues[i]),
                            ),
                            if (i != venues.length - 1)
                              const OlympiaDivider(indent: 18),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppStrings.venuesShuttleNote,
                      style: TextStyle(
                          fontSize: 13,
                          color: colors.textMuted,
                          height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _open(Venue venue) async {
    ref.read(mixpanelProvider).viewVenue(venue.id);
    await openDirections(
      context: context,
      venue: venue,
      onTracked: (mapsApp) => ref
          .read(mixpanelProvider)
          .directionsTap(venueId: venue.id, mapsApp: mapsApp),
    );
  }
}

class _VenueRow extends StatelessWidget {
  const _VenueRow({required this.venue, required this.onTap});
  final Venue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              venue.role,
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            ),
            if (venue.driveFromPalmsMin != null) ...[
              const SizedBox(height: 2),
              Text(
                '${venue.driveFromPalmsMin} min from Palms'
                '${venue.shuttle ? ' · shuttle' : ''}',
                style: TextStyle(fontSize: 13, color: colors.textFaint),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
