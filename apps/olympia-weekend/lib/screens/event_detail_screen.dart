import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/data/schedule_repo.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/features/saved_events.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/router.dart';
import 'package:olympia_weekend/widgets/access_tag.dart';
import 'package:olympia_weekend/widgets/card.dart';
import 'package:olympia_weekend/features/directions.dart';
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
      return _shell(context, child: Center(child: Text(
        eventId, style: TextStyle(color: colors.textFaint))));
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
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(Routes.now);
                    }
                  },
                  child: Text(
                    '‹ ${AppStrings.eventBackToNow}',
                    style: TextStyle(fontSize: 15, color: colors.textMuted),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    await ref.read(savedEventsProvider.notifier).toggle(eventId);
                    if (isSaved) {
                      ref.read(mixpanelProvider).unsaveEvent(eventId);
                    } else {
                      ref.read(mixpanelProvider).saveEvent(eventId);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSaved
                          ? const Color(0xFFe2231a)
                          : colors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colors.surfaceBorder),
                    ),
                    child: Text(
                      isSaved ? AppStrings.eventUnsave : AppStrings.eventSave,
                      style: TextStyle(
                        fontSize: 13,
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
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: colors.text,
                height: 1.15,
              ),
            ),
          ),
          if (event.divisions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                event.divisions.join(', '),
                style: TextStyle(fontSize: 15, color: colors.textMuted),
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
                      label:
                          event.vipEntry != null && event.vipEntry!.isNotEmpty
                              ? AppStrings.eventVipEntry
                              : AppStrings.eventDoors,
                      value: event.vipEntry ??
                          event.doorsEstimate ??
                          event.start ??
                          '—'),
                  _FactDivider(color: colors.divider),
                  _Fact(
                      label: AppStrings.eventVenue,
                      value: venue?.short ?? event.venueId),
                  _FactDivider(color: colors.divider),
                  _FactAccess(access: event.access),
                ],
              ),
            ),
          ),
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
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                  color: colors.text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                event.runningOrder[i].division,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: colors.text,
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
                        style:
                            TextStyle(fontSize: 13, color: colors.textFaint),
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
                style: TextStyle(
                    fontSize: 15, color: colors.textMuted, height: 1.5),
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
                final url = Uri.parse(
                    'https://olympiaweekend.app/e/${event.id}?utm_source=share');
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: context.olympiaColors.text,
          ),
        ),
      );

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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.text,
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
