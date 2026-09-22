import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olympia_weekend/app_config.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/features/directions.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/features/venue_map.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/widgets/card.dart';
import 'package:olympia_weekend/widgets/pressable.dart';

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
                style: context.olympiaText.row.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colors.textMuted,
                ),
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
                      style: context.olympiaText.title,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppStrings.venuesSubtitle,
                      style: context.olympiaText.caption.copyWith(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _VenueMapPanel(
                      venues: venues,
                      onPinTap: _open,
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
                      style: context.olympiaText.caption.copyWith(height: 1.5),
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

/// Rounded map surface with either the real Google Map or a text
/// fallback when the runtime key isn't available (dev / preview
/// builds without `--dart-define=GOOGLE_MAPS_WEB_KEY`).
class _VenueMapPanel extends StatelessWidget {
  const _VenueMapPanel({required this.venues, required this.onPinTap});

  final List<Venue> venues;
  final void Function(Venue venue) onPinTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    // On web the Embed API only fires when we have a key. On mobile,
    // google_maps_flutter reads the key from Info.plist / Manifest,
    // so we treat the platform-appropriate build-time key as the
    // enable flag.
    final key = kIsWeb
        ? AppConfig.googleMapsWebKey
        : (defaultTargetPlatform == TargetPlatform.iOS
            ? AppConfig.googleMapsIosKey
            : AppConfig.googleMapsAndroidKey);
    final hasKey = key.isNotEmpty && key != 'stub';
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.surfaceBorder),
          borderRadius: BorderRadius.circular(18),
        ),
        child: hasKey
            ? buildVenueMap(
                venues: venues,
                apiKey: key,
                onPinTap: onPinTap,
              )
            : Text(
                AppStrings.venuesMapFallback,
                style: context.olympiaText.row.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colors.textFaint,
                ),
              ),
      ),
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
    return OlympiaPressable(
      onTap: onTap,
      semanticsLabel: 'Open ${venue.name}, ${venue.role}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue.name,
              style: context.olympiaText.row.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              venue.role,
              style: context.olympiaText.caption,
            ),
            if (venue.driveFromPalmsMin != null) ...[
              const SizedBox(height: 2),
              Text(
                '${venue.driveFromPalmsMin} min from Palms'
                '${venue.shuttle ? ' · shuttle' : ''}',
                style: context.olympiaText.caption.copyWith(
                  color: colors.textFaint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
