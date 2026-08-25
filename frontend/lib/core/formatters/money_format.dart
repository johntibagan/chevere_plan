import 'package:intl/intl.dart';

import '../l10n/app_locale.dart';

/// Código ISO por defecto cuando el modelo no trae moneda (perfil / DB).
const String kDefaultCurrencyCode = 'COP';

/// Formatea [amount] con el código de moneda del modelo.
String formatMoney(
  num amount, {
  String currencyCode = kDefaultCurrencyCode,
  int fractionDigits = 0,
  String? locale,
}) {
  return NumberFormat.currency(
    name: currencyCode,
    symbol: '$currencyCode ',
    decimalDigits: fractionDigits,
    locale: locale ?? kAppLocale,
  ).format(amount);
}

/// Prefijo/símbolo para campos numéricos de presupuesto.
String currencyInputPrefix(
  String currencyCode, {
  String? locale,
}) {
  return NumberFormat.simpleCurrency(
    name: currencyCode,
    locale: locale ?? kAppLocale,
  ).currencySymbol;
}

/// Sufijo visible en campos (código ISO).
String currencyInputSuffix(String currencyCode) => currencyCode;
