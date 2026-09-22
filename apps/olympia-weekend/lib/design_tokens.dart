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
  OlympiaColors get olympiaColors =>
      MediaQuery.platformBrightnessOf(this) == Brightness.dark
          ? OlympiaColors.dark
          : OlympiaColors.light;
}
