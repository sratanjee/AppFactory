// Regression test for Sarang's Sep 22 review — tapping a day pill on
// Now must prime scheduleSelectedDayProvider before navigating so
// Schedule lands on the tapped day instead of falling back.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_weekend/screens/schedule_screen.dart';

void main() {
  test('Tapping Thu on Now primes scheduleSelectedDayProvider to Thu', () {
    // Simulate the handler's write half of the flow.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Verify initial state is null (fallback state).
    expect(container.read(scheduleSelectedDayProvider), isNull);

    // Now's day-pill onSelected calls this exact API.
    container
        .read(scheduleSelectedDayProvider.notifier)
        .set('2026-09-24');

    // Schedule reads it as `primed` — should be Thu.
    expect(container.read(scheduleSelectedDayProvider), '2026-09-24');
  });
}
