import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olympia_weekend/app_config.dart';
import 'package:olympia_weekend/data/exhibitors_repo.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:olympia_weekend/widgets/async_body.dart';
import 'package:olympia_weekend/widgets/card.dart';
import 'package:olympia_weekend/widgets/chip_strip.dart';
import 'package:olympia_weekend/widgets/filter_chip.dart';
import 'package:olympia_weekend/widgets/pressable.dart';
import 'package:url_launcher/url_launcher.dart';

/// First-class Expo hub — three segments (Exhibitors / Events / Floor
/// plan) rolled into one screen. Consolidates the old
/// `/expo/exhibitors` + `/expo/events` pair so the tab-bar entry hits
/// a single hub instead of splitting the flow.
///
/// [initialTab] lets the legacy URL aliases (`/expo/exhibitors`,
/// `/expo/events`) land on the right segment. Defaults to
/// [_ExpoSegment.exhibitors].
class ExpoScreen extends ConsumerStatefulWidget {
  const ExpoScreen({this.initialTab, super.key});

  /// Query-string `tab=` value forwarded from the redirect aliases.
  /// Accepts `exhibitors`, `events`, `floor` (or `floorplan`).
  final String? initialTab;

  @override
  ConsumerState<ExpoScreen> createState() => _ExpoScreenState();
}

enum _ExpoSegment { exhibitors, events, floorPlan }

class _ExpoScreenState extends ConsumerState<ExpoScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ExhibitorCategory? _selectedCategory; // null == "All"
  late _ExpoSegment _segment = _segmentFor(widget.initialTab);

  static _ExpoSegment _segmentFor(String? raw) => switch (raw) {
        'events' => _ExpoSegment.events,
        'floor' || 'floorplan' || 'floor_plan' => _ExpoSegment.floorPlan,
        _ => _ExpoSegment.exhibitors,
      };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final exhibitorsAsync = ref.watch(exhibitorsProvider);
    final eventsAsync = ref.watch(expoEventsProvider);

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
                child: _buildBody(
                  exhibitors: exhibitors,
                  events: eventsAsync.value ?? const <ExpoEvent>[],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required List<Exhibitor> exhibitors,
    required List<ExpoEvent> events,
  }) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _header(context),
        const SizedBox(height: 16),
        _segmentControl(),
        const SizedBox(height: 20),
        if (_segment == _ExpoSegment.exhibitors)
          ..._exhibitorsSection(exhibitors)
        else if (_segment == _ExpoSegment.events)
          ..._eventsSection(events)
        else
          ..._floorPlanSection(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            AppStrings.expoFooter,
            style: context.olympiaText.caption.copyWith(height: 1.45),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ————— Header —————

  Widget _header(BuildContext context) {
    final colors = context.olympiaColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.expoTitle, style: context.olympiaText.title),
          const SizedBox(height: 6),
          Text(
            AppStrings.expoDates,
            style: context.olympiaText.caption
                .copyWith(fontSize: 14, color: colors.text),
          ),
          const SizedBox(height: 2),
          Text(
            AppStrings.expoSubtitle,
            style: context.olympiaText.caption.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ————— Segmented control —————

  Widget _segmentControl() {
    return HorizontalChipStrip(
      height: 48,
      children: [
        for (final s in _ExpoSegment.values) ...[
          OlympiaFilterChip(
            label: _segmentLabel(s),
            active: _segment == s,
            onTap: () => setState(() => _segment = s),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  String _segmentLabel(_ExpoSegment s) => switch (s) {
        _ExpoSegment.exhibitors => AppStrings.expoSegmentExhibitors,
        _ExpoSegment.events => AppStrings.expoSegmentEvents,
        _ExpoSegment.floorPlan => AppStrings.expoSegmentFloorPlan,
      };

  // ————— Exhibitors segment —————

  List<Widget> _exhibitorsSection(List<Exhibitor> all) {
    final colors = context.olympiaColors;
    final q = _query.trim().toLowerCase();
    final filtered = all.where((e) {
      final matchesCategory =
          _selectedCategory == null || e.category == _selectedCategory;
      if (!matchesCategory) return false;
      if (q.isEmpty) return true;
      return e.name.toLowerCase().contains(q);
    }).toList(growable: false);

    // Order the category chips by descending count so the busiest
    // segments (Supplements, Apparel) sit up front.
    final counts = <ExhibitorCategory, int>{};
    for (final e in all) {
      counts[e.category] = (counts[e.category] ?? 0) + 1;
    }
    final orderedCats = ExhibitorCategory.values
        .where((c) => (counts[c] ?? 0) > 0)
        .toList()
      ..sort((a, b) => (counts[b] ?? 0).compareTo(counts[a] ?? 0));

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AdaptiveInput(
          controller: _searchController,
          placeholder: AppStrings.expoSearchHint,
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      const SizedBox(height: 16),
      HorizontalChipStrip(
        children: [
          OlympiaFilterChip(
            label: AppStrings.expoFilterAll,
            active: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          const SizedBox(width: 8),
          for (final cat in orderedCats) ...[
            OlympiaFilterChip(
              label: cat.label,
              active: _selectedCategory == cat,
              onTap: () => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(width: 8),
          ],
        ],
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
    ];
  }

  // ————— Events segment —————

  List<Widget> _eventsSection(List<ExpoEvent> all) {
    final colors = context.olympiaColors;
    final fri = all.where((e) => e.date == '2026-09-25').toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final sat = all.where((e) => e.date == '2026-09-26').toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    if (fri.isEmpty && sat.isEmpty) {
      return [
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
      ];
    }

    return [
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
      ],
    ];
  }

  // ————— Floor plan segment —————

  List<Widget> _floorPlanSection() {
    final colors = context.olympiaColors;
    final domain = AppConfig.webDeployDomain;
    final hasImage = domain.isNotEmpty;
    return [
      // Primary: the bundled static floor plan (cached, offline-
      // friendly, matches the dark palette). Falls back to a
      // placeholder card until the PNG lands at
      // web/expo-floor-plan.png.
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: hasImage
              ? _FloorPlanImage(
                  url: 'https://$domain/expo-floor-plan.png',
                  fallback: _floorPlanFallback(colors),
                )
              : _floorPlanFallback(colors),
        ),
      ),
      const SizedBox(height: 12),
      // Fallback for users who want live booth search: link out to
      // a2z's own interactive map at fp37.a2zinc.net. Opens in the
      // system browser so we don't need webview_flutter.
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: OlympiaPressable(
          onTap: () async {
            final uri = Uri.parse(
              'https://fp37.a2zinc.net/clients/fpWeiderPub/'
              'JoeWeidersOlympia2026/Public/EventMap.aspx',
            );
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          semanticsLabel: AppStrings.expoInteractiveMapCta,
          minSize: const Size(0, 44),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.surfaceBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.expoInteractiveMapCta,
                  style: context.olympiaText.row.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '↗',
                  style: context.olympiaText.row.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          AppStrings.expoInteractiveMapNote,
          style: context.olympiaText.caption,
        ),
      ),
    ];
  }

  Widget _floorPlanFallback(OlympiaColors colors) {
    return Container(
      height: 240,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.surfaceBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        AppStrings.expoFloorPlanFallback,
        textAlign: TextAlign.center,
        style: context.olympiaText.row.copyWith(
          fontWeight: FontWeight.w400,
          color: colors.textFaint,
        ),
      ),
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
                  style: context.olympiaText.caption
                      .copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
        ],
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
                child: Text(exhibitor.name, style: context.olympiaText.row),
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

/// Network image with graceful fallback while loading or on error.
class _FloorPlanImage extends StatelessWidget {
  const _FloorPlanImage({required this.url, required this.fallback});

  final String url;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          height: 240,
          child: Center(
            child: AdaptiveLoading(),
          ),
        );
      },
      errorBuilder: (_, _, _) => fallback,
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
