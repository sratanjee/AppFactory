// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'factory_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FactoryLocalizationsEn extends FactoryLocalizations {
  FactoryLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonContinue => 'Continue';

  @override
  String get buttonGetStarted => 'Get started';

  @override
  String get buttonTryAgain => 'Try again';

  @override
  String get buttonRestorePurchases => 'Restore purchases';

  @override
  String get buttonStartFreeTrial => 'Start free trial';

  @override
  String get paywallErrorPurchaseFailed => 'Purchase failed. Try again.';

  @override
  String get paywallErrorRestoreFailed => 'Restore failed. Try again.';

  @override
  String get buttonTerms => 'Terms';

  @override
  String get buttonPrivacy => 'Privacy';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';
}
