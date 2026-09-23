import 'package:flutter/widgets.dart';

/// Small red-bordered "BACKSTAGE" pill shown next to headers and event
/// rows when the user is in Backstage mode. Read-only badge — the
/// toggle lives in the About sheet.
class BackstagePill extends StatelessWidget {
  const BackstagePill({this.dense = false, super.key});

  /// Shrinks paddings + font for use inside dense event-row layouts.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFe2231a);
    final fontSize = dense ? 9.0 : 10.0;
    final padH = dense ? 5.0 : 6.0;
    final padV = dense ? 1.0 : 2.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: const Color(0x00000000),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: accent, width: 1),
      ),
      child: Text(
        'BACKSTAGE',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: accent,
          height: 1.1,
        ),
      ),
    );
  }
}
