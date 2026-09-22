import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/data/models.dart';

/// Fallback when neither dart:html nor dart:io is available (test env).
Widget createVenueMap({
  required List<Venue> venues,
  required String apiKey,
  required void Function(Venue venue) onPinTap,
}) =>
    const SizedBox.shrink();
