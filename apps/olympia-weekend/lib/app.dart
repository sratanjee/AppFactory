import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/app_config.dart';
import 'package:olympia_weekend/router.dart';

class OlympiaWeekendApp extends StatelessWidget {
  const OlympiaWeekendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      title: 'Olympia Weekend',
      theme: const AdaptiveTheme(
        accent: Color(0xFFe2231a),
        child: SizedBox.shrink(),
      ),
      router: buildRouter(),
      riverpodOverrides: [
        appSlugProvider.overrideWithValue('olympia-weekend'),
        analyticsConfigProvider.overrideWithValue(AppConfig.analyticsConfig),
        paywallConfigProvider.overrideWithValue(AppConfig.paywallConfig),
      ],
    );
  }
}
