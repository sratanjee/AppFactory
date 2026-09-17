import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _demos = [
    _Demo(
      route: 'adaptive',
      title: 'Adaptive UI',
      body: 'Scaffold, sheet, dialog, picker, list, switch, segmented, button.',
    ),
    _Demo(
      route: 'onboarding',
      title: 'Onboarding',
      body: 'Three-step flow with a permission-prompt card.',
    ),
    _Demo(
      route: 'paywall',
      title: 'Paywall',
      body: 'Full-screen paywall with two packages and a delayed close.',
    ),
    _Demo(
      route: 'storage',
      title: 'Storage',
      body: 'KeyValueStore round-trip and in-memory Drift database open.',
    ),
    _Demo(
      route: 'analytics',
      title: 'Analytics',
      body: 'Fire each of the five events; watch them appear in the buffer.',
    ),
    _Demo(
      route: 'widget-bridge',
      title: 'Widget bridge',
      body: 'Publish a counter payload and read it back.',
    ),
    _Demo(
      route: 'shorebird',
      title: 'Shorebird',
      body: 'Reports isAvailable and currentPatchNumber.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('factory_core'),
      body: AdaptiveList(
        sections: [
          AdaptiveListSection(
            header: 'Subsystems',
            items: [
              for (final demo in _demos)
                AdaptiveListItem(
                  title: demo.title,
                  subtitle: demo.body,
                  hasNavigation: true,
                  onTap: () => context.goNamed(demo.route),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Demo {
  const _Demo({
    required this.route,
    required this.title,
    required this.body,
  });

  final String route;
  final String title;
  final String body;
}
