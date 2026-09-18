import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/l10n/app_strings.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AdaptiveScaffold(
      title: Text(AppStrings.servicesTitle),
      body: Center(child: Text(AppStrings.servicesTitle)),
    );
  }
}
