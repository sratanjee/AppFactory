import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/design_tokens.dart';

/// Small pill next to an event row showing the access tier.
class AccessTag extends StatelessWidget {
  const AccessTag({required this.access, super.key});

  final EventAccess access;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    final (bg, fg, label) = switch (access) {
      EventAccess.free => (colors.tagFreeBg, colors.tagFreeText, 'Free'),
      EventAccess.ticket =>
        (colors.tagTicketBg, colors.tagTicketText, 'Ticket'),
      EventAccess.vip => (colors.tagVipBg, colors.tagVipText, 'VIP'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
