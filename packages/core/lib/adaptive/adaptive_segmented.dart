import 'package:factory_core/adaptive/platform.dart';
import 'package:flutter/cupertino.dart' show CupertinoSlidingSegmentedControl;
import 'package:flutter/material.dart' show ButtonSegment, SegmentedButton;
import 'package:flutter/widgets.dart';

class AdaptiveSegment<T> {
  const AdaptiveSegment({required this.value, required this.label});

  final T value;
  final String label;
}

class AdaptiveSegmentedControl<T extends Object> extends StatelessWidget {
  const AdaptiveSegmentedControl({
    required this.segments,
    required this.selectedValue,
    required this.onChanged,
    super.key,
  });

  final List<AdaptiveSegment<T>> segments;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOS) {
      return CupertinoSlidingSegmentedControl<T>(
        groupValue: selectedValue,
        onValueChanged: (v) {
          if (v != null) onChanged(v);
        },
        children: {
          for (final s in segments)
            s.value: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(s.label),
            ),
        },
      );
    }
    return SegmentedButton<T>(
      segments: [
        for (final s in segments)
          ButtonSegment<T>(value: s.value, label: Text(s.label)),
      ],
      selected: {selectedValue},
      onSelectionChanged: (set) {
        if (set.isNotEmpty) onChanged(set.first);
      },
    );
  }
}
