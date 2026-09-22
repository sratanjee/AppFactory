import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/app_config.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/features/directions.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/features/saved_events.dart';
import 'package:olympia_weekend/features/venue_map.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/router.dart';
import 'package:olympia_weekend/widgets/access_tag.dart';
import 'package:olympia_weekend/widgets/card.dart';
import 'package:olympia_weekend/widgets/pressable.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.olympiaColors;
    final eventsById = ref.watch(eventsByIdProvider);
    final venuesById = ref.watch(venuesByIdProvider);
    final saved = ref.watch(savedEventsProvider);

    final event = eventsById[eventId];
    if (event == null) {
      return _shell(
        context,
        child: Center(
          child: Text(
            eventId,
            style: context.olympiaText.row.copyWith(
              fontWeight: FontWeight.w400,
              color: colors.textFaint,
            ),
          ),
        ),
      );
    }
    final venue = venuesById[event.venueId];
    final isSaved = saved.contains(eventId);

    return _shell(
      context,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(height: 6, color: const Color(0xFFe2231a)),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                OlympiaPressable(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(Routes.now);
                    }
                  },
                  semanticsLabel: 'Back',
                  minSize: const Size(48, 44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Text(
                      '‹ ${AppStrings.eventBackToNow}',
                      style: context.olympiaText.row.copyWith(
                        fontWeight: FontWeight.w400,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                OlympiaPressable(
                  onTap: () async {
                    await ref.read(savedEventsProvider.notifier).toggle(eventId);
                    if (isSaved) {
                      ref.read(mixpanelProvider).unsaveEvent(eventId);
                    } else {
                      ref.read(mixpanelProvider).saveEvent(eventId);
                    }
                  },
                  semanticsLabel:
                      isSaved ? AppStrings.eventUnsave : AppStrings.eventSave,
                  semanticsSelected: isSaved,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSaved
                          ? const Color(0xFFe2231a)
                          : colors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colors.surfaceBorder),
                    ),
                    child: Text(
                      isSaved ? AppStrings.eventUnsave : AppStrings.eventSave,
                      style: context.olympiaText.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSaved
                            ? const Color(0xFFFFFFFF)
                            : colors.text,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              event.title,
              style: context.olympiaText.title.copyWith(
                fontSize: 28,
                letterSpacing: -0.4,
                height: 1.15,
              ),
            ),
          ),
          if (event.presentedBy != null &&
              event.presentedBy!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '${AppStrings.eventPresentedBy} ${event.presentedBy}',
                style: context.olympiaText.caption.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colors.textMuted,
                ),
              ),
            ),
          ],
          if (event.featuring != null && event.featuring!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                event.featuring!,
                style: context.olympiaText.caption.copyWith(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: colors.textMuted,
                ),
              ),
            ),
          ],
          if (event.divisions.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle(context, AppStrings.eventDivisionsOrder),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OlympiaCard(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < event.divisions.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${i + 1}',
                                style: context.olympiaText.timeCell.copyWith(
                                  color: colors.textFaint,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                event.divisions[i],
                                style: context.olympiaText.row,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OlympiaCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _Fact(
                      label: _timeFactLabel(event),
                      value: _timeFactValue(event)),
                  _FactDivider(color: colors.divider),
                  _Fact(
                      label: AppStrings.eventVenue,
                      value: [
                        venue?.short ?? event.venueId,
                        if (event.room != null && event.room!.isNotEmpty)
                          event.room!,
                      ].join(' · ')),
                  _FactDivider(color: colors.divider),
                  _FactAccess(access: event.access),
                ],
              ),
            ),
          ),
          if (venue != null) ...[
            const SizedBox(height: 24),
            _sectionTitle(context, AppStrings.eventLocation),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _LocationCard(venue: venue, room: event.room),
            ),
          ],
          if ((event.vipEntry != null && event.vipEntry!.isNotEmpty) ||
              (event.generalEntry != null &&
                  event.generalEntry!.isNotEmpty)) ...[
            const SizedBox(height: 24),
            _sectionTitle(context, AppStrings.eventEntry),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OlympiaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.vipEntry != null &&
                        event.vipEntry!.isNotEmpty)
                      _EntryRow(
                        label: AppStrings.eventEntryVip,
                        time: event.vipEntry!,
                      ),
                    if (event.vipEntry != null &&
                        event.vipEntry!.isNotEmpty &&
                        event.generalEntry != null &&
                        event.generalEntry!.isNotEmpty)
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: colors.divider,
                      ),
                    if (event.generalEntry != null &&
                        event.generalEntry!.isNotEmpty)
                      _EntryRow(
                        label: AppStrings.eventEntryGeneral,
                        time: event.generalEntry!,
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (event.runningOrder.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle(context, AppStrings.eventRunningOrder),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OlympiaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < event.runningOrder.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 62,
                              child: Text(
                                event.runningOrder[i].estimate,
                                style: context.olympiaText.timeCell,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                event.runningOrder[i].division,
                                style: context.olympiaText.row.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (event.runningOrderNote != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.runningOrderNote!,
                        style: context.olympiaText.caption.copyWith(
                          color: colors.textFaint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          if (event.notes != null) ...[
            const SizedBox(height: 24),
            _sectionTitle(context, AppStrings.eventGoodToKnow),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                event.notes!,
                style: context.olympiaText.row.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colors.textMuted,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AdaptivePrimaryButton(
              label: AppStrings.eventDirections,
              onPressed: () async {
                if (venue == null) return;
                await openDirections(
                  context: context,
                  venue: venue,
                  onTracked: (mapsApp) => ref
                      .read(mixpanelProvider)
                      .directionsTap(venueId: venue.id, mapsApp: mapsApp),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AdaptiveSecondaryButton(
              label: AppStrings.eventShare,
              onPressed: () async {
                // Build from the live deploy domain (--dart-define
                // WEB_DEPLOY_DOMAIN), falling back to the current
                // Vercel URL if no custom domain is wired.
                final host = AppConfig.webDeployDomain.isNotEmpty
                    ? AppConfig.webDeployDomain
                    : 'olympia-weekend.vercel.app';
                final url = Uri.parse(
                    'https://$host/e/${event.id}?utm_source=share');
                await launchUrl(url, mode: LaunchMode.externalApplication);
                ref
                    .read(mixpanelProvider)
                    .shareTap(screen: 'event', eventId: event.id);
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(label, style: context.olympiaText.section),
      );

  /// Label for the first fact card. If the event has both a start and
  /// an end we show "Hours" (open-window venues like the pop-up gym and
  /// the Expo). Otherwise we show "VIP entry" when a VIP entry time is
  /// present, or "Doors" as a fallback.
  static String _timeFactLabel(Event event) {
    if (event.start != null && event.end != null) {
      return AppStrings.eventHours;
    }
    if (event.vipEntry != null && event.vipEntry!.isNotEmpty) {
      return AppStrings.eventVipEntry;
    }
    return AppStrings.eventDoors;
  }

  /// Value for the first fact card. All-day rows get a "start–end"
  /// range (with an "(est)" suffix when endEstimate is set). Point
  /// events fall back to vipEntry, then doorsEstimate, then start.
  static String _timeFactValue(Event event) {
    if (event.start != null && event.end != null) {
      final range = '${event.start}–${event.end}';
      return event.endEstimate
          ? '$range (${AppStrings.eventEstimate})'
          : range;
    }
    if (event.vipEntry != null && event.vipEntry!.isNotEmpty) {
      return event.vipEntry!;
    }
    if (event.doorsEstimate != null && event.doorsEstimate!.isNotEmpty) {
      return '${event.doorsEstimate} (${AppStrings.eventEstimate})';
    }
    return event.start ?? '—';
  }

  Widget _shell(BuildContext context, {required Widget child}) {
    final colors = context.olympiaColors;
    return ColoredBox(
      color: colors.background,
      child: AdaptiveScaffold(
        backgroundColor: colors.background,
        titleDisplay: TitleDisplay.none,
        body: SafeArea(bottom: false, child: child),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: colors.textFaint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.olympiaText.row.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactDivider extends StatelessWidget {
  const _FactDivider({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 32,
        color: color,
        margin: const EdgeInsets.symmetric(horizontal: 14),
      );
}

class _FactAccess extends StatelessWidget {
  const _FactAccess({required this.access});
  final EventAccess access;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.eventAccess,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: context.olympiaColors.textFaint,
            ),
          ),
          const SizedBox(height: 4),
          AccessTag(access: access),
        ],
      ),
    );
  }
}

/// Location card — venue name, sub-room (Pearl Theater etc), address,
/// mini map, drive-from-Palms subtitle. Sits between the fact strip and
/// the entry / running-order sections so users see "where + how far"
/// before they read the schedule details.
class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.venue, required this.room});

  final Venue venue;
  final String? room;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final key = kIsWeb
        ? AppConfig.googleMapsWebKey
        : (defaultTargetPlatform == TargetPlatform.iOS
            ? AppConfig.googleMapsIosKey
            : AppConfig.googleMapsAndroidKey);
    final hasKey = key.isNotEmpty && key != 'stub';
    return OlympiaCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasKey)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: SizedBox(
                height: 180,
                child: buildVenueMap(
                  venues: [venue],
                  apiKey: key,
                  onPinTap: (_) {},
                  // Pass the sub-room so a Palms event opens on
                  // "Palms Casino Resort Pearl Theater" rather than
                  // the resort's main entrance.
                  query: (room != null && room!.isNotEmpty)
                      ? '${venue.name} ${room!}'
                      : null,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  style: context.olympiaText.row.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (room != null && room!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    room!,
                    style: context.olympiaText.caption.copyWith(
                      color: colors.text,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(venue.address, style: context.olympiaText.caption),
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
        ],
      ),
    );
  }
}

/// One line in the "Entry" section — "VIP · 11:30am".
class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.label, required this.time});
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.olympiaText.row.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.text,
              ),
            ),
          ),
          Text(
            time,
            style: context.olympiaText.row.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
