import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/design_tokens.dart';
import 'package:olympia_weekend/widgets/access_tag.dart';

/// One row inside an event list card. Shows the time column (or a
/// blank when the row is all-day), the title, the venue + access tag,
/// and a chevron.
class EventRow extends StatelessWidget {
  const EventRow({
    required this.event,
    required this.venueLabel,
    required this.timeLabel,
    required this.onTap,
    this.trailing,
    this.showChevron = true,
    super.key,
  });

  final Event event;
  final String venueLabel;

  /// Left-column time, or empty string for all-day rows.
  final String timeLabel;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return Semantics(
      button: true,
      label: '${event.title}, $venueLabel',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (timeLabel.isNotEmpty)
                SizedBox(
                  width: 52,
                  child: Text(
                    timeLabel,
                    style: context.olympiaText.timeCell.copyWith(
                      fontSize: 15,
                    ),
                  ),
                ),
              if (timeLabel.isNotEmpty) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: context.olympiaText.row,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            venueLabel,
                            overflow: TextOverflow.ellipsis,
                            style: context.olympiaText.caption,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AccessTag(access: event.access),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (showChevron)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CustomPaint(
                      painter: ChevronPainter(color: colors.chevron),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders the same `M9 18l6-6-6-6` chevron from the design HTML.
class ChevronPainter extends CustomPainter {
  const ChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.375, h * 0.25)
      ..lineTo(w * 0.625, h * 0.5)
      ..lineTo(w * 0.375, h * 0.75);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ChevronPainter old) => old.color != color;
}
