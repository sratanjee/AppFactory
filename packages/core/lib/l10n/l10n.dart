import 'package:factory_core/l10n/generated/factory_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:factory_core/l10n/generated/factory_localizations.dart'
    show FactoryLocalizations;

/// Ergonomic access to `FactoryLocalizations` from any widget context.
///
/// * `context.l10n` — non-null. Throws if `FactoryLocalizations` isn't in
///   scope (which shouldn't happen inside `AdaptiveApp`).
/// * `context.maybeL10n` — nullable. Use inside adaptive widgets that might
///   render in raw widget tests without a `Localizations` ancestor, so they
///   can fall back to a hardcoded English string.
extension FactoryLocalizationsContext on BuildContext {
  FactoryLocalizations get l10n => FactoryLocalizations.of(this);

  FactoryLocalizations? get maybeL10n =>
      Localizations.of<FactoryLocalizations>(this, FactoryLocalizations);
}
