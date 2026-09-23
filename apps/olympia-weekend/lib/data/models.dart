import 'package:flutter/foundation.dart';

/// Access tier for an event. Maps to the `access` field in
/// `assets/data/schedule.json`.
enum EventAccess { free, ticket, vip }

EventAccess parseAccess(String? raw) {
  switch (raw) {
    case 'free':
      return EventAccess.free;
    case 'vip':
      return EventAccess.vip;
    case 'ticket':
    default:
      return EventAccess.ticket;
  }
}

/// A single running-order row inside a finals event.
class RunningOrderRow {
  const RunningOrderRow({required this.division, required this.estimate});

  factory RunningOrderRow.fromJson(Map<String, dynamic> json) =>
      RunningOrderRow(
        division: json['division'] as String,
        estimate: json['estimate'] as String,
      );

  final String division;
  final String estimate;
}

/// One row in `assets/data/schedule.json` -> `events[]`.
class Event {
  const Event({
    required this.id,
    required this.date,
    required this.title,
    required this.venueId,
    required this.access,
    required this.divisions,
    required this.runningOrder,
    required this.shuttle,
    required this.amateur,
    required this.endEstimate,
    this.internal = false,
    this.start,
    this.end,
    this.room,
    this.plus,
    this.presentedBy,
    this.featuring,
    this.vipEntry,
    this.generalEntry,
    this.notes,
    this.runningOrderNote,
    this.doorsEstimate,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final runningOrderRaw = json['runningOrder'] as List<dynamic>?;
    return Event(
      id: json['id'] as String,
      date: json['date'] as String,
      start: json['start'] as String?,
      end: json['end'] as String?,
      title: json['title'] as String,
      venueId: json['venue'] as String,
      room: json['room'] as String?,
      access: parseAccess(json['access'] as String?),
      divisions: (json['divisions'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toList(growable: false),
      plus: json['plus'] as String?,
      presentedBy: json['presentedBy'] as String?,
      featuring: json['featuring'] as String?,
      vipEntry: json['vipEntry'] as String?,
      generalEntry: json['generalEntry'] as String?,
      shuttle: json['shuttle'] as bool? ?? false,
      amateur: json['amateur'] as bool? ?? false,
      notes: json['notes'] as String?,
      runningOrder: runningOrderRaw == null
          ? const []
          : runningOrderRaw
              .cast<Map<String, dynamic>>()
              .map(RunningOrderRow.fromJson)
              .toList(growable: false),
      runningOrderNote: json['runningOrderNote'] as String?,
      endEstimate: json['endEstimate'] as bool? ?? false,
      doorsEstimate: json['doorsEstimate'] as String?,
      internal: json['internal'] as bool? ?? false,
    );
  }

  final String id;
  final String date; // yyyy-MM-dd Vegas local
  final String? start; // HH:mm 24h, or null for "time TBD"
  final String? end;
  final String title;
  final String venueId;
  final String? room;
  final EventAccess access;
  final List<String> divisions;
  final String? plus;
  final String? presentedBy;
  final String? featuring;
  final String? vipEntry;
  final String? generalEntry;
  final bool shuttle;
  final bool amateur;
  final String? notes;
  final List<RunningOrderRow> runningOrder;
  final String? runningOrderNote;
  final bool endEstimate;
  final String? doorsEstimate;

  /// Staff-only events (athlete meetings, weigh-ins, judge's meeting,
  /// amateur registration). Hidden from the public schedule; only shown
  /// when the user has unlocked Backstage mode via the About sheet.
  final bool internal;

  bool get isExpo => id.contains('expo') || title.toLowerCase().contains('expo');
  bool get isAllDay => start != null && end != null;
}

/// `assets/data/venues.json` -> `venues[]`.
class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.short,
    required this.address,
    required this.lat,
    required this.lng,
    required this.placeId,
    required this.role,
    required this.shuttle,
    required this.rooms,
    this.driveFromPalmsMin,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'] as String,
        name: json['name'] as String,
        short: json['short'] as String,
        address: json['address'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        placeId: json['placeId'] as String,
        role: json['role'] as String,
        shuttle: json['shuttle'] as bool? ?? false,
        driveFromPalmsMin: (json['driveFromPalmsMin'] as num?)?.toInt(),
        rooms: (json['rooms'] as List<dynamic>? ?? const [])
            .cast<String>()
            .toList(growable: false),
      );

  final String id;
  final String name;
  final String short;
  final String address;
  final double lat;
  final double lng;
  final String placeId;
  final String role;
  final bool shuttle;
  final int? driveFromPalmsMin;
  final List<String> rooms;
}

/// `athletes.json` -> `divisions[]`.
class Division {
  const Division({
    required this.id,
    required this.name,
    required this.prejudgingEventId,
    required this.finalsEventId,
    this.prize,
  });

  factory Division.fromJson(Map<String, dynamic> json) => Division(
        id: json['id'] as String,
        name: json['name'] as String,
        prejudgingEventId: json['prejudging'] as String,
        finalsEventId: json['finals'] as String,
        prize: json['prize'] as String?,
      );

  final String id;
  final String name;
  final String prejudgingEventId;
  final String finalsEventId;
  final String? prize;
}

enum AppearanceStatus { reported, confirmed }

AppearanceStatus parseAppearanceStatus(String? raw) {
  if (raw == 'confirmed') return AppearanceStatus.confirmed;
  return AppearanceStatus.reported;
}

class Appearance {
  const Appearance({
    required this.date,
    required this.start,
    required this.venueId,
    required this.booth,
    required this.status,
    required this.confirmations,
    required this.source,
    this.end,
    this.sponsor,
  });

  factory Appearance.fromJson(Map<String, dynamic> json) => Appearance(
        date: json['date'] as String,
        start: json['start'] as String,
        end: json['end'] as String?,
        venueId: json['venue'] as String,
        booth: json['booth'] as String,
        sponsor: json['sponsor'] as String?,
        status: parseAppearanceStatus(json['status'] as String?),
        confirmations: (json['confirmations'] as num?)?.toInt() ?? 0,
        source: json['source'] as String? ?? 'signage',
      );

  final String date;
  final String start;
  final String? end;
  final String venueId;
  final String booth;
  final String? sponsor;
  final AppearanceStatus status;
  final int confirmations;
  final String source;

  /// Stable composite key used by the sightings table.
  String appearanceKey(String athleteId) =>
      '$athleteId|$date|$start|$venueId|$booth';

  Appearance copyWith({
    AppearanceStatus? status,
    int? confirmations,
  }) =>
      Appearance(
        date: date,
        start: start,
        end: end,
        venueId: venueId,
        booth: booth,
        sponsor: sponsor,
        status: status ?? this.status,
        confirmations: confirmations ?? this.confirmations,
        source: source,
      );
}

/// Verified social channels shown on the athlete "baseball card" hero.
///
/// Sourced from official channels only (`ifbbpro.com`, athlete's own
/// verified site, Wikipedia when licensed) — never scraped Instagram or
/// fan-run wikis. Empty is fine; the UI renders a "no links yet" state.
enum SocialPlatform { instagram, tiktok, youtube, twitter, website }

@immutable
class SocialLink {
  const SocialLink({required this.platform, required this.handleOrUrl});

  factory SocialLink.fromJson(Map<String, dynamic> j) => SocialLink(
        platform: SocialPlatform.values.firstWhere(
          (p) => p.name == j['platform'],
          orElse: () => SocialPlatform.website,
        ),
        handleOrUrl: j['handleOrUrl'] as String,
      );

  final SocialPlatform platform;

  /// Either a bare handle ("chrisbumstead") or a full https URL. The
  /// screen normalises this at tap time — instagram/tiktok handles get
  /// prefixed with their standard web URL; youtube/twitter/website are
  /// assumed to be full URLs already.
  final String handleOrUrl;
}

class Athlete {
  const Athlete({
    required this.id,
    required this.name,
    required this.divisionId,
    required this.country,
    required this.tagline,
    required this.appearances,
    this.instagram,
    this.booth,
    this.photoUrl,
    this.socials = const <SocialLink>[],
  });

  factory Athlete.fromJson(Map<String, dynamic> json) => Athlete(
        id: json['id'] as String,
        name: json['name'] as String,
        // The seed roster JSON uses `divisionId`; keep the older
        // `division` key working too so upstream refreshes don't break.
        divisionId: (json['divisionId'] ?? json['division']) as String,
        country: json['country'] as String? ?? '',
        tagline: json['tagline'] as String? ?? '',
        instagram: json['instagram'] as String?,
        booth: json['booth'] as String?,
        photoUrl: json['photoUrl'] as String?,
        socials: (json['socials'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(SocialLink.fromJson)
                .toList(growable: false) ??
            const <SocialLink>[],
        appearances: (json['appearances'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(Appearance.fromJson)
            .toList(growable: false),
      );

  final String id;
  final String name;
  final String divisionId;
  final String country;
  final String tagline;
  final String? instagram;
  final String? booth;

  /// Absolute HTTPS URL to a public / official physique photo. Null
  /// means the UI falls back to the initials avatar.
  final String? photoUrl;

  /// Verified social links; never null. Empty renders a quiet state.
  final List<SocialLink> socials;

  final List<Appearance> appearances;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Athlete copyWith({List<Appearance>? appearances}) => Athlete(
        id: id,
        name: name,
        divisionId: divisionId,
        country: country,
        tagline: tagline,
        instagram: instagram,
        booth: booth,
        photoUrl: photoUrl,
        socials: socials,
        appearances: appearances ?? this.appearances,
      );
}

/// Coarse taxonomy for the 154 booths on the World Fitness Expo floor.
///
/// Assigned per-row in `assets/data/exhibitors.json` and used to drive
/// the category chip strip on the Expo hub screen. Kept intentionally
/// short so every chip fits on one horizontal scroll pass; anything
/// that doesn't obviously slot maps to [other].
enum ExhibitorCategory {
  supplements,
  energyDrinks,
  apparel,
  equipment,
  foodSnacks,
  peptidesHormones,
  contentMedia,
  militaryRecruiting,
  techWearables,
  servicesWellness,
  trainingGyms,
  bikiniPrep,
  other,
}

/// Human-friendly labels for [ExhibitorCategory] — surfaced on filter
/// chips. Kept adjacent to the enum so a new category can't ship
/// without a matching label.
extension ExhibitorCategoryLabel on ExhibitorCategory {
  String get label => switch (this) {
        ExhibitorCategory.supplements => 'Supplements',
        ExhibitorCategory.energyDrinks => 'Energy drinks',
        ExhibitorCategory.apparel => 'Apparel',
        ExhibitorCategory.equipment => 'Equipment',
        ExhibitorCategory.foodSnacks => 'Food & snacks',
        ExhibitorCategory.peptidesHormones => 'Peptides / hormones',
        ExhibitorCategory.contentMedia => 'Content / media',
        ExhibitorCategory.militaryRecruiting => 'Military',
        ExhibitorCategory.techWearables => 'Tech & wearables',
        ExhibitorCategory.servicesWellness => 'Services / wellness',
        ExhibitorCategory.trainingGyms => 'Training / gyms',
        ExhibitorCategory.bikiniPrep => 'Bikini prep',
        ExhibitorCategory.other => 'Other',
      };

  /// JSON serialisation key — snake_case to match the source data file.
  String get jsonKey => switch (this) {
        ExhibitorCategory.supplements => 'supplements',
        ExhibitorCategory.energyDrinks => 'energy_drinks',
        ExhibitorCategory.apparel => 'apparel',
        ExhibitorCategory.equipment => 'equipment',
        ExhibitorCategory.foodSnacks => 'food_snacks',
        ExhibitorCategory.peptidesHormones => 'peptides_hormones',
        ExhibitorCategory.contentMedia => 'content_media',
        ExhibitorCategory.militaryRecruiting => 'military_recruiting',
        ExhibitorCategory.techWearables => 'tech_wearables',
        ExhibitorCategory.servicesWellness => 'services_wellness',
        ExhibitorCategory.trainingGyms => 'training_gyms',
        ExhibitorCategory.bikiniPrep => 'bikini_prep',
        ExhibitorCategory.other => 'other',
      };
}

ExhibitorCategory _parseExhibitorCategory(String? raw) {
  if (raw == null) return ExhibitorCategory.other;
  for (final c in ExhibitorCategory.values) {
    if (c.jsonKey == raw) return c;
  }
  return ExhibitorCategory.other;
}

/// One entry in `assets/data/exhibitors.json` -> `exhibitors[]`.
///
/// The 154-booth expo floor at LVCC South Hall on Fri 9/25 and Sat 9/26.
/// [keywords] is reserved for future search-boost tokens (e.g. category
/// aliases) — v1 ships empty and searches only on [name].
class Exhibitor {
  const Exhibitor({
    required this.id,
    required this.name,
    required this.booth,
    required this.category,
    required this.keywords,
  });

  factory Exhibitor.fromJson(Map<String, dynamic> json) => Exhibitor(
        id: json['id'] as String,
        name: json['name'] as String,
        booth: json['booth'] as String,
        category: _parseExhibitorCategory(json['category'] as String?),
        keywords: (json['keywords'] as List<dynamic>? ?? const [])
            .cast<String>()
            .toList(growable: false),
      );

  final String id;
  final String name;
  final String booth;
  final ExhibitorCategory category;
  final List<String> keywords;
}

/// One entry in `assets/data/expo_events.json` -> `events[]`.
///
/// Expo-floor stage sessions and meet-and-greets sourced from
/// mrolympia.com/content/world-fitness-expo-events plus the official
/// weekend schedule. Fri/Sat only.
class ExpoEvent {
  const ExpoEvent({
    required this.id,
    required this.date,
    required this.start,
    required this.end,
    required this.title,
    required this.boothOrStage,
    this.url,
  });

  factory ExpoEvent.fromJson(Map<String, dynamic> json) => ExpoEvent(
        id: json['id'] as String,
        date: json['date'] as String,
        start: json['start'] as String,
        end: json['end'] as String,
        title: json['title'] as String,
        boothOrStage: json['boothOrStage'] as String,
        url: json['url'] as String?,
      );

  final String id;
  final String date; // yyyy-MM-dd Vegas local
  final String start; // HH:mm 24h
  final String end; // HH:mm 24h
  final String title;
  final String boothOrStage;
  final String? url;
}
