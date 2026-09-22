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
import 'package:olympia_weekend/widgets/async_body.dart';
import 'package:olympia_weekend/widgets/card.dart';
import 'package:olympia_weekend/widgets/event_row.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  bool _tracked = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final scheduleAsync = ref.watch(scheduleProvider);
    final venuesById = ref.watch(venuesByIdProvider);
    final saved = ref.watch(savedEventsProvider);

    return ColoredBox(
      color: colors.background,
      child: AdaptiveScaffold(
        backgroundColor: colors.background,
        titleDisplay: TitleDisplay.none,
        body: SafeArea(
          bottom: false,
          child: OlympiaAsyncBody(
            child: scheduleAsync.when(
            loading: () => const Center(
              key: ValueKey('loading'),
              child: AdaptiveLoading(),
            ),
            error: (_, __) => Padding(
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
            data: (events) {
              final savedEvents =
                  events.where((e) => saved.contains(e.id)).toList()
                    ..sort((a, b) {
                      final byDate = a.date.compareTo(b.date);
                      if (byDate != 0) return byDate;
                      return (a.start ?? '99:99').compareTo(b.start ?? '99:99');
                    });

              if (!_tracked) {
                _tracked = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(mixpanelProvider).viewSaved(savedEvents.length);
                });
              }

              final grouped = <String, List<Event>>{};
              for (final e in savedEvents) {
                grouped.putIfAbsent(e.date, () => []).add(e);
              }

              return ListView(
                key: const ValueKey('data'),
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Text(
                      AppStrings.savedTitle,
                      style: context.olympiaText.title,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (savedEvents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        AppStrings.savedEmpty,
                        style: context.olympiaText.row.copyWith(
                          fontWeight: FontWeight.w400,
                          color: colors.textMuted,
                        ),
                      ),
                    )
                  else
                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Text(
                          _labelForDate(entry.key),
                          style: context.olympiaText.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: OlympiaCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < entry.value.length; i++) ...[
                                EventRow(
                                  event: entry.value[i],
                                  venueLabel: _venueLabel(
                                      venuesById[entry.value[i].venueId],
                                      entry.value[i]),
                                  timeLabel:
                                      _shortTime(entry.value[i].start),
                                  onTap: () {
                                    ref.read(mixpanelProvider).viewEvent(
                                          eventId: entry.value[i].id,
                                          access:
                                              entry.value[i].access.name,
                                          venue: entry.value[i].venueId,
                                          fromScreen: 'saved',
                                        );
                                    context.goNamed(Routes.event,
                                        pathParameters: {
                                          'id': entry.value[i].id
                                        });
                                  },
                                ),
                                if (i != entry.value.length - 1)
                                  const OlympiaDivider(indent: 86),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
          ),
        ),
      ),
    );
  }

  String _venueLabel(Venue? v, Event e) {
    if (v == null) return e.venueId;
    return e.room == null ? v.short : '${v.short} · ${e.room}';
  }

  String _labelForDate(String date) {
    const map = {
      '2026-09-23': 'Wednesday',
      '2026-09-24': 'Thursday',
      '2026-09-25': 'Friday',
      '2026-09-26': 'Saturday',
      '2026-09-27': 'Sunday',
    };
    return map[date] ?? date;
  }
}

String _shortTime(String? hhmm) {
  if (hhmm == null) return '';
  final parts = hhmm.split(':');
  if (parts.length < 2) return hhmm;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts[1];
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$h12:$m';
}
