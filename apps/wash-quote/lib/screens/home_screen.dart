import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Wash Quote & Invoice'),
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
