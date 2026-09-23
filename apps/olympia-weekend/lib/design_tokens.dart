import 'package:flutter/widgets.dart';

/// Semantic color tokens from the Olympia artboards (`design/olympia-weekend`).
///
/// The adaptive layer picks light vs dark from [MediaQuery.platformBrightness].
/// One accent lives in `AdaptiveTheme.accent`; everything else is a pair here.
@immutable
class OlympiaColors {
  const OlympiaColors({
    required this.background,
    required this.surface,
    required this.surfaceBorder,
    required this.divider,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.chevron,
    required this.tagFreeBg,
    required this.tagFreeText,
    required this.tagTicketBg,
    required this.tagTicketText,
    required this.tagVipBg,
    required this.tagVipText,
    required this.badgeConfirmedBg,
    required this.badgeConfirmedText,
    required this.badgeReportedBg,
    required this.badgeReportedText,
    required this.pillInactive,
    required this.pillTextInactive,
    required this.pillActiveBg,
    required this.pillActiveText,
    required this.avatarBg,
    required this.avatarText,
  });

  static const OlympiaColors light = OlympiaColors(
    background: Color(0xFFF7F7F5),
    surface: Color(0xFFFFFFFF),
    surfaceBorder: Color(0xFFE6E6E2),
    divider: Color(0xFFEEEEEB),
    text: Color(0xFF141414),
    textMuted: Color(0xFF6B6B68),
    textFaint: Color(0xFF9A9A96),
    chevron: Color(0xFFC0C0BC),
    tagFreeBg: Color(0xFFDCF3EA),
    tagFreeText: Color(0xFF0F6E56),
    tagTicketBg: Color(0xFFEBEBE7),
    tagTicketText: Color(0xFF3D3D3A),
    tagVipBg: Color(0xFFECE6FB),
    tagVipText: Color(0xFF5B3FB8),
    badgeConfirmedBg: Color(0xFFDCF3EA),
    badgeConfirmedText: Color(0xFF0F6E56),
    badgeReportedBg: Color(0xFFF0F0ED),
    badgeReportedText: Color(0xFF6B6B68),
    pillInactive: Color(0xFFFFFFFF),
    pillTextInactive: Color(0xFF141414),
    pillActiveBg: Color(0xFF141414),
    pillActiveText: Color(0xFFFFFFFF),
    avatarBg: Color(0xFFEEEEEB),
    avatarText: Color(0xFF6B6B68),
  );

  static const OlympiaColors dark = OlympiaColors(
    background: Color(0xFF0E0E0E),
    surface: Color(0xFF222222),
    surfaceBorder: Color(0xFF2A2A2A),
    divider: Color(0xFF2E2E2E),
    text: Color(0xFFF5F5F3),
    textMuted: Color(0xFFA3A39E),
    textFaint: Color(0xFF7A7A76),
    chevron: Color(0xFF55554F),
    tagFreeBg: Color(0xFF123D2E),
    tagFreeText: Color(0xFF6FD3A5),
    tagTicketBg: Color(0xFF2A2A2A),
    tagTicketText: Color(0xFFD0D0CC),
    tagVipBg: Color(0xFF2A2542),
    tagVipText: Color(0xFFB9A6FF),
    badgeConfirmedBg: Color(0xFF123D2E),
    badgeConfirmedText: Color(0xFF6FD3A5),
    badgeReportedBg: Color(0xFF2A2A2A),
    badgeReportedText: Color(0xFFA3A39E),
    pillInactive: Color(0xFF222222),
    pillTextInactive: Color(0xFFF5F5F3),
    pillActiveBg: Color(0xFFF5F5F3),
    pillActiveText: Color(0xFF141414),
    avatarBg: Color(0xFF2A2A2A),
    avatarText: Color(0xFFA3A39E),
  );

  final Color background;
  final Color surface;
  final Color surfaceBorder;
  final Color divider;
  final Color text;
  final Color textMuted;
  final Color textFaint;
  final Color chevron;
  final Color tagFreeBg;
  final Color tagFreeText;
  final Color tagTicketBg;
  final Color tagTicketText;
  final Color tagVipBg;
  final Color tagVipText;
  final Color badgeConfirmedBg;
  final Color badgeConfirmedText;
  final Color badgeReportedBg;
  final Color badgeReportedText;
  final Color pillInactive;
  final Color pillTextInactive;
  final Color pillActiveBg;
  final Color pillActiveText;
  final Color avatarBg;
  final Color avatarText;
}

extension OlympiaColorsFromContext on BuildContext {
  // Spec §8 Option B — the mrolympia.com black/red/white palette. Locked
  // to dark regardless of system preference; light tokens stay defined
  // above for future opt-in via a settings toggle.
  OlympiaColors get olympiaColors => OlympiaColors.dark;

  OlympiaText get olympiaText => OlympiaText(olympiaColors);
}

/// Type scale — spec §8 + `design/olympia-weekend/*.html` inline values.
///
/// Fonts: Barlow Condensed for the two headline slots (title, cardTitle) —
/// gives the front page that fight-night program feel — and Inter for
/// everything else (sections, rows, captions, time cells, chrome). Line
/// heights + letter-spacing mirror the artboard's CSS so rendered pixel
/// density matches the mockups instead of drifting on Flutter's defaults.
///
/// TODO(font): web loads these via <link> in web/index.html. Mobile still
/// falls back to system fonts until the release engineer wires in the
/// `google_fonts` pub package post-store-submission — we're deliberately
/// avoiding a pubspec bump before the current review round.
@immutable
class OlympiaText {
  const OlympiaText(this._c);
  final OlympiaColors _c;

  static const _monoNums = <FontFeature>[FontFeature.tabularFigures()];

  static const _display = 'Barlow Condensed';
  static const _body = 'Inter';

  /// Screen title "Olympia Weekend" / "Schedule" / "Athletes" / "Venues" /
  /// "Saved" — 32/700 / -0.5.
  TextStyle get title => TextStyle(
        fontFamily: _display,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.1,
        color: _c.text,
      );

  /// Section header — "Up next" / "All day" / "Morning" / "Afternoon and
  /// evening" — 17/600, high-contrast.
  TextStyle get section => TextStyle(
        fontFamily: _body,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: _c.text,
      );

  /// Row primary text — event title, athlete name — 15/500.
  TextStyle get row => TextStyle(
        fontFamily: _body,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: _c.text,
      );

  /// Row subtitle — venue name + relative time — 13/regular muted.
  TextStyle get caption => TextStyle(
        fontFamily: _body,
        fontSize: 13,
        height: 1.35,
        color: _c.textMuted,
      );

  /// Tabular time cell — "6:00" / "12:00" — 17/600 with tabular figures so
  /// digits align vertically in stacked rows.
  TextStyle get timeCell => TextStyle(
        fontFamily: _body,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        fontFeatures: _monoNums,
        color: _c.text,
      );

  /// Happening-now inner title — 22/700 / -0.3 / 1.15 line-height.
  TextStyle get cardTitle => TextStyle(
        fontFamily: _display,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.15,
        color: _c.text,
      );

  /// Access-tag ("Free" / "Ticket" / "VIP") — 12/600 pill.
  TextStyle get tag => const TextStyle(
        fontFamily: _body,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.0,
      );

  /// Day-pill label — 14/500 inactive, 14/600 active. Callers pass `active`.
  TextStyle pill({required bool active}) => TextStyle(
        fontFamily: _body,
        fontSize: 14,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        color: active ? _c.pillActiveText : _c.textMuted,
      );

  /// Tab-bar label — 10/500 inactive, 10/600 active. Callers pass `active`.
  TextStyle tab({required bool active}) => TextStyle(
        fontFamily: _body,
        fontSize: 10,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        color: active ? _c.text : _c.textFaint,
      );

  /// Full-day / See-all trailing link on section headers — 15/regular accent.
  TextStyle link({required Color accent}) => TextStyle(
        fontFamily: _body,
        fontSize: 15,
        color: accent,
      );

  /// Faint caption — 12/regular muted (e.g. "No booth listed").
  TextStyle get faint => TextStyle(
        fontFamily: _body,
        fontSize: 12,
        height: 1.35,
        color: _c.textFaint,
      );
}
