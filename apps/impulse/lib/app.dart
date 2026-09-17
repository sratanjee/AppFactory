import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:impulse/app_config.dart';
import 'package:impulse/router.dart';

class ImpulseApp extends StatelessWidget {
  const ImpulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      title: 'Impulse',
      theme: const AdaptiveTheme(
        accent: Color(0xFF1D9A6C),
        child: SizedBox.shrink(),
      ),
      router: buildRouter(),
      riverpodOverrides: [
        appSlugProvider.overrideWithValue('impulse'),
        analyticsConfigProvider.overrideWithValue(AppConfig.analyticsConfig),
        paywallConfigProvider.overrideWithValue(AppConfig.paywallConfig),
      ],
    );
  }
}
