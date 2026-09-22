import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';

void main() {
  test('stub instance exposes empty-safe super properties', () {
    final svc = MixpanelService.stub();
    expect(svc.superProperties, isNotEmpty);
    expect(svc.superProperties['platform'], 'test');
  });

  test('stub track is a no-op', () async {
    final svc = MixpanelService.stub();
    // Doesn't throw and returns a future that completes.
    await svc.track('view_now', {'now_event_id': 'sat-finals'});
    await svc.viewNow(nowEventId: 'sat-finals', nextEventId: null);
  });
}
