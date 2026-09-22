import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Olympia Weekend'),
      body: const Center(
        child: Text('Scaffolded. Builder replaces this.'),
      ),
      primaryAction: AdaptivePrimaryButton(
        label: 'Get started',
        onPressed: () {},
      ),
    );
  }
}
