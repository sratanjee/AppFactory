import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_weekend/app.dart';

void main() {
  testWidgets('OlympiaWeekendApp mounts', (tester) async {
    await tester.pumpWidget(const OlympiaWeekendApp());
    await tester.pump();
  });
}
