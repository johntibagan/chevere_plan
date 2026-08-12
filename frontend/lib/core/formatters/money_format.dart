import 'package:intl/intl.dart';

/// Formatea [amount] con el código de moneda del modelo (no asume COP en UI).
String formatMoney(
  num amount, {
  String currencyCode = 'COP',
  int fractionDigits = 0,
}) {
  return NumberFormat.currency(
    name: currencyCode,
    symbol: '$currencyCode ',
    decimalDigits: fractionDigits,
    locale: 'es',
  ).format(amount);
}
