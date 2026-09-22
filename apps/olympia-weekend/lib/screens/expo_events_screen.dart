import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olympia_weekend/data/exhibitors_repo.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/widgets/async_body.dart';
import 'package:olympia_weekend/widgets/card.dart';

/// Expo-floor stage sessions + meet-and-greets, grouped by date.
///
/// Reached from `/expo/exhibitors` via the "See stage events" chip, or
/// deep-linked at `/expo/events`.
class ExpoEventsScreen extends ConsumerWidget {
  const ExpoEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.olympiaColors;
    final eventsAsync = ref.watch(expoEventsProvider);
    return ColoredBox(
      color: colors.background,
      child: AdaptiveScaffold(
        backgroundColor: colors.background,
        titleDisplay: TitleDisplay.none,
        body: SafeArea(
          bottom: false,
          child: OlympiaAsyncBody(
            child: eventsAsync.when(
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
              data: (events) => KeyedSubtree(
                key: const ValueKey('data'),
                child: _buildBody(context, events),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<ExpoEvent> all) {
    final colors = context.olympiaColors;
    final fri = all.where((e) => e.date == '2026-09-25').toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final sat = all.where((e) => e.date == '2026-09-26').toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            AppStrings.expoEventsTitle,
            style: context.olympiaText.title.copyWith(fontSize: 28),
          ),
        ),
        const SizedBox(height: 20),
        if (fri.isEmpty && sat.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppStrings.expoEventsEmpty,
              style: context.olympiaText.row.copyWith(
                fontWeight: FontWeight.w400,
                color: colors.textMuted,
              ),
            ),
          ),
        if (fri.isNotEmpty) ...[
          const _DayHeader(label: AppStrings.expoEventsFri),
          const SizedBox(height: 10),
          _EventsCard(events: fri),
          const SizedBox(height: 24),
        ],
        if (sat.isNotEmpty) ...[
          const _DayHeader(label: AppStrings.expoEventsSat),
          const SizedBox(height: 10),
          _EventsCard(events: sat),
          const SizedBox(height: 24),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Text(
            AppStrings.expoFooter,
            style: context.olympiaText.caption.copyWith(height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(label, style: context.olympiaText.section),
      );
}

class _EventsCard extends StatelessWidget {
  const _EventsCard({required this.events});
  final List<ExpoEvent> events;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: OlympiaCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < events.length; i++) ...[
                _ExpoEventRow(event: events[i]),
                if (i != events.length - 1) const OlympiaDivider(indent: 82),
              ],
            ],
          ),
        ),
      );
}

class _ExpoEventRow extends StatelessWidget {
  const _ExpoEventRow({required this.event});
  final ExpoEvent event;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              _shortTime(event.start),
              style: context.olympiaText.timeCell,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: context.olympiaText.row),
                const SizedBox(height: 2),
                Text(
                  event.boothOrStage,
                  style: context.olympiaText.caption.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _shortTime(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length < 2) return hhmm;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts[1];
  final suffix = h >= 12 ? 'PM' : 'AM';
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return m == '00' ? '$h12 $suffix' : '$h12:$m $suffix';
}
