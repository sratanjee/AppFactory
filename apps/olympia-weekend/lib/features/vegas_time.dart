import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// One-shot: call before Riverpod is up so `America/Los_Angeles` is
/// resolvable in `nowVegasProvider`.
void initVegasTimeZone() {
  tz_data.initializeTimeZones();
}

/// Vegas local time zone location.
tz.Location get vegasLocation => tz.getLocation('America/Los_Angeles');

/// Converts any [DateTime] (device local, UTC, etc.) to Vegas local.
tz.TZDateTime toVegas(DateTime raw) => tz.TZDateTime.from(raw, vegasLocation);

/// Riverpod stream tick every 30 s of Vegas-local "now".
///
/// Emits the current value immediately, then every 30 s. Consumers get
/// live updates without doing their own scheduling.
final nowVegasProvider = StreamProvider<tz.TZDateTime>((ref) async* {
  yield tz.TZDateTime.now(vegasLocation);
  final ticker = Stream.periodic(
    const Duration(seconds: 30),
    (_) => tz.TZDateTime.now(vegasLocation),
  );
  yield* ticker;
});

/// Test seam: override this to freeze time in unit tests without
/// depending on the ticker.
final vegasClockProvider = Provider<tz.TZDateTime Function()>(
  (ref) => () => tz.TZDateTime.now(vegasLocation),
);
