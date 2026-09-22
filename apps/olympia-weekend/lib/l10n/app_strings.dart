/// Strings for Olympia Weekend, English only.
///
/// Grouped by screen. Copy is bound by DESIGN_GUIDE §6 (sentence case,
/// no exclamation marks, empty states name the next action).
abstract final class AppStrings {
  // App-level.
  static const String appTitle = 'Olympia Weekend';

  // Tabs.
  static const String tabNow = 'Now';
  static const String tabSchedule = 'Schedule';
  static const String tabAthletes = 'Athletes';
  static const String tabVenues = 'Venues';
  static const String tabSaved = 'Saved';

  // Now screen.
  static const String nowHappening = 'Happening now';
  static const String nowUpNext = 'Up next';
  static const String nowAllDay = 'All day';
  static const String nowFullDay = 'Full day';
  static const String nowEmpty =
      'Nothing on right now. Next up shows here.';
  static const String nowEmptyBeforeWeekend =
      'Weekend starts Wednesday. Tap Schedule to see it.';
  static const String nowEmptyAfterWeekend =
      'That\'s a wrap. See you in 2027.';
  static const String nowEmptyEndOfDay =
      'That\'s it for today. Full schedule is one tap away.';
  static const String nowInstallHint =
      'Unofficial fan guide. Add to your home screen for one-tap access.';
  static const String nowInstallHintCta = 'How';
  static const String nowInstallSheetIosTitle = 'Add to Home Screen';
  static const String nowInstallSheetIosBody =
      'Tap the Share button in Safari, then choose Add to Home Screen.';
  static const String nowInstallSheetAndroidBody =
      'Tap Install to add Olympia Weekend to your home screen.';
  static const String nowInstallSheetAndroidCta = 'Install';
  static const String nowInstallSheetDismiss = 'Got it';

  // Schedule screen.
  static const String scheduleTitle = 'Schedule';
  static const String scheduleFilterAll = 'All';
  static const String scheduleFilterFree = 'Free';
  static const String scheduleFilterTicket = 'Ticketed';
  static const String scheduleFilterPalms = 'At Palms';
  static const String scheduleMorning = 'Morning';
  static const String scheduleAfternoon = 'Afternoon and evening';
  static const String scheduleEmpty = 'No events match this filter.';
  static const String scheduleClearFilters = 'Clear filters';

  // Event detail.
  static const String eventDoors = 'Doors';
  static const String eventVipEntry = 'VIP entry';
  static const String eventVenue = 'Venue';
  static const String eventAccess = 'Access';
  static const String eventRunningOrder = 'Running order';
  static const String eventRunningOrderNote =
      'Order is confirmed. Times are estimates and update during the show.';
  static const String eventMeetGreets = 'Meet-and-greets today';
  static const String eventMeetGreetsAll = 'All athletes';
  static const String eventMeetGreetsFooter =
      'Confirmed means two people have tapped "I saw this" on the athlete\'s page.';
  static const String eventAfterward = 'Afterward';
  static const String eventGoodToKnow = 'Good to know';
  static const String eventSave = 'Save to my day';
  static const String eventUnsave = 'Saved';
  static const String eventDirections = 'Directions';
  static const String eventShare = 'Share';
  static const String eventBackToSchedule = 'Schedule';
  static const String eventBackToNow = 'Now';
  static const String eventShuttle = 'Shuttles run to this venue.';
  static const String eventDirectionsFailed = 'Couldn\'t open Directions. Copy the address?';
  static const String eventCopyAddress = 'Copy address';
  static const String eventAddressCopied = 'Address copied';

  // Athletes.
  static const String athletesTitle = 'Athletes';
  static const String athletesSearchHint = 'Search';
  static const String athletesNoBooth = 'No booth listed';
  static const String athletesMeetGreet = 'Meet & greet';
  static const String athletesSearchEmpty = 'No athletes match "{query}".';
  static const String athletesDivisionEmpty =
      'Roster still coming in from IFBB Pro. Check back Wednesday.';
  static const String athleteInstagram = 'Instagram';
  static const String athleteAppearances = 'Appearances';
  static const String athleteConfirmed = 'Confirmed';
  static const String athleteReported = 'Reported';
  static const String athleteISawThis = 'I saw this';
  static const String athleteReportBooth = 'Report a booth or time';
  static const String athleteFooter =
      'Booth and meet-and-greet times come from expo signage and athlete posts. If you see one, tap the athlete and confirm it for everyone.';
  static const String athleteSightingFailed =
      'Couldn\'t send that sighting. Try again in a moment.';
  static const String athleteSightingRateLimited =
      'Too many confirmations from this device. Try again in a bit.';

  // Venues.
  static const String venuesTitle = 'Venues';
  static const String venuesSubtitle =
      'Five places all weekend. Palms is home base. Tap any venue for directions.';
  static const String venuesShuttleNote =
      'Official shuttles run between the Palms, Orleans Arena, and the Expo on Friday and Saturday; the schedule is on the Olympia FAQ page. Allow 20 to 30 minutes by car in the afternoons.';
  static const String venuesMapFallback = 'Map couldn\'t load. Venue list still works.';

  // Directions sheet.
  static const String directionsAppleMaps = 'Apple Maps';
  static const String directionsGoogleMaps = 'Google Maps';
  static const String directionsCancel = 'Cancel';

  // Saved.
  static const String savedTitle = 'Saved';
  static const String savedEmpty = 'Nothing saved yet — tap the bookmark on any event.';

  // Error surface.
  static const String errorLiveRefresh =
      'Couldn\'t refresh live data. Showing the schedule that shipped with the app.';
  static const String errorRetry = 'Try again';

  // About.
  static const String aboutTitle = 'About';
  static const String aboutTagline = 'Unofficial fan guide.';
  static const String aboutTickets = 'Official tickets';
  static const String aboutLivestream = 'Official livestream';
  static const String aboutReport = 'Report a fix';
  static const String aboutVersion = 'Version';

  // Day pills — full labels for accessibility.
  static const List<String> dayShort = ['Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> dayLong = [
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
}
