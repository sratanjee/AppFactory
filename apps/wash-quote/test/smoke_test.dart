import 'package:flutter_test/flutter_test.dart';
import 'package:wash_quote/app.dart';

void main() {
  testWidgets('WashQuoteApp mounts', (tester) async {
    await tester.pumpWidget(const WashQuoteApp());
    await tester.pump();
  });
}
