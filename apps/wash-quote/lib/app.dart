import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:wash_quote/app_config.dart';
import 'package:wash_quote/router.dart';

class WashQuoteApp extends StatelessWidget {
  const WashQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      title: 'Wash Quote & Invoice',
      theme: const AdaptiveTheme(
        accent: Color(0xFF0a6ea8),
        child: SizedBox.shrink(),
      ),
      router: buildRouter(),
      riverpodOverrides: [
        appSlugProvider.overrideWithValue('wash-quote'),
        analyticsConfigProvider.overrideWithValue(AppConfig.analyticsConfig),
        paywallConfigProvider.overrideWithValue(AppConfig.paywallConfig),
      ],
    );
  }
}
