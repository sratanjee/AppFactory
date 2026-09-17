import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'factory_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FactoryLocalizations
/// returned by `FactoryLocalizations.of(context)`.
///
/// Applications need to include `FactoryLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/factory_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FactoryLocalizations.localizationsDelegates,
///   supportedLocales: FactoryLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the FactoryLocalizations.supportedLocales
/// property.
abstract class FactoryLocalizations {
  FactoryLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FactoryLocalizations of(BuildContext context) {
    return Localizations.of<FactoryLocalizations>(
      context,
      FactoryLocalizations,
    )!;
  }

  static const LocalizationsDelegate<FactoryLocalizations> delegate =
      _FactoryLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Sheet or dialog cancel action label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Onboarding step advance label (non-terminal step).
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get buttonContinue;

  /// Onboarding terminal step label.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get buttonGetStarted;

  /// Error state retry action label.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get buttonTryAgain;

  /// Paywall restore-purchases action label.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get buttonRestorePurchases;

  /// Paywall primary action when the selected package has a free trial.
  ///
  /// In en, this message translates to:
  /// **'Start free trial'**
  String get buttonStartFreeTrial;

  /// Inline error message under the primary paywall button when a purchase fails.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Try again.'**
  String get paywallErrorPurchaseFailed;

  /// Inline error message when a restore fails.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. Try again.'**
  String get paywallErrorRestoreFailed;

  /// Paywall footer link to Terms of Service.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get buttonTerms;

  /// Paywall footer link to Privacy Policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get buttonPrivacy;

  /// Default error message when no more specific one exists.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;
}

class _FactoryLocalizationsDelegate
    extends LocalizationsDelegate<FactoryLocalizations> {
  const _FactoryLocalizationsDelegate();

  @override
  Future<FactoryLocalizations> load(Locale locale) {
    return SynchronousFuture<FactoryLocalizations>(
      lookupFactoryLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_FactoryLocalizationsDelegate old) => false;
}

FactoryLocalizations lookupFactoryLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return FactoryLocalizationsEn();
  }

  throw FlutterError(
    'FactoryLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
