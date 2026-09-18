import 'dart:io' show Platform;

/// Locale-derived currency helpers. Shared by every screen that displays a
/// dollar (or equivalent) amount so the currency symbol is always in
/// agreement across Jobs, Money, and the PDF renderer.
class Money {
  Money._();

  static String formatCents(int cents) {
    final symbol = _symbol();
    final dollars = cents / 100;
    return '$symbol${dollars.toStringAsFixed(2)}';
  }

  static String currencyCode() {
    try {
      final locale = Platform.localeName;
      final parts = locale.split(RegExp(r'[_\-]'));
      final region = parts.length > 1 ? parts.last.toUpperCase() : 'US';
      return _regionToCode[region] ?? 'USD';
    } on Object {
      return 'USD';
    }
  }

  static String _symbol() {
    return _codeToSymbol[currencyCode()] ?? r'$';
  }

  static const _regionToCode = {
    'US': 'USD',
    'CA': 'CAD',
    'GB': 'GBP',
    'UK': 'GBP',
    'IE': 'EUR',
    'DE': 'EUR',
    'FR': 'EUR',
    'ES': 'EUR',
    'IT': 'EUR',
    'NL': 'EUR',
    'JP': 'JPY',
    'IN': 'INR',
    'AU': 'AUD',
  };

  static const _codeToSymbol = {
    'USD': r'$',
    'CAD': r'CA$',
    'GBP': '£',
    'EUR': '€',
    'JPY': '¥',
    'INR': '₹',
    'AUD': r'AU$',
  };
}
