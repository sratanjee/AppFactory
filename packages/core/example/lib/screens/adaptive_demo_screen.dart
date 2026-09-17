import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';

class AdaptiveDemoScreen extends StatefulWidget {
  const AdaptiveDemoScreen({super.key});

  @override
  State<AdaptiveDemoScreen> createState() => _AdaptiveDemoScreenState();
}

class _AdaptiveDemoScreenState extends State<AdaptiveDemoScreen> {
  bool _switchValue = true;
  String _pickerValue = 'coffee';
  String _segmentValue = 'day';

  Future<void> _showSheet() async {
    await AdaptiveSheet.show<void>(
      context,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sheet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              'A CupertinoSheetRoute on iOS, a showModalBottomSheet on Android.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AdaptivePrimaryButton(
              label: 'Close',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDialog() async {
    final result = await AdaptiveDialog.confirm<bool>(
      context,
      title: 'Sure?',
      message: 'Confirms via an alert on both platforms; action sheet on iOS '
          'if there are 3+ actions.',
      actions: const [
        AdaptiveDialogAction(label: 'Cancel', value: false, isCancel: true),
        AdaptiveDialogAction(label: 'Confirm', value: true),
      ],
    );
    if (!mounted) return;
    if (result == true) {
      AdaptiveHaptics.success();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Adaptive UI'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveSecondaryButton(label: 'Show sheet', onPressed: _showSheet),
            const SizedBox(height: 12),
            AdaptiveSecondaryButton(
              label: 'Show dialog',
              onPressed: _showDialog,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Switch'),
                AdaptiveSwitch(
                  value: _switchValue,
                  onChanged: (v) => setState(() => _switchValue = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Picker'),
                AdaptivePicker<String>(
                  items: const [
                    AdaptivePickerItem(value: 'water', label: 'Water'),
                    AdaptivePickerItem(value: 'coffee', label: 'Coffee'),
                    AdaptivePickerItem(value: 'tea', label: 'Tea'),
                  ],
                  selectedValue: _pickerValue,
                  onSelected: (v) => setState(() => _pickerValue = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AdaptiveSegmentedControl<String>(
              segments: const [
                AdaptiveSegment(value: 'day', label: 'Day'),
                AdaptiveSegment(value: 'week', label: 'Week'),
                AdaptiveSegment(value: 'month', label: 'Month'),
              ],
              selectedValue: _segmentValue,
              onChanged: (v) => setState(() => _segmentValue = v),
            ),
            const SizedBox(height: 24),
            const AdaptiveList(
              scrollable: false,
              sections: [
                AdaptiveListSection(
                  header: 'Small list',
                  items: [
                    AdaptiveListItem(
                      title: 'First row',
                      subtitle: 'With a subtitle',
                    ),
                    AdaptiveListItem(
                      title: 'Second row',
                      hasNavigation: true,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      primaryAction: const AdaptivePrimaryButton(
        label: 'Primary action',
        onPressed: AdaptiveHaptics.light,
      ),
    );
  }
}
