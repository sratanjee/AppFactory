import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/l10n/app_strings.dart';

class QuoteBuilderScreen extends ConsumerWidget {
  const QuoteBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AdaptiveScaffold(
      title: Text(AppStrings.builderTitle),
      body: Center(child: Text(AppStrings.builderTitle)),
    );
  }
}
