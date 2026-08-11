/// Monto + código de moneda para UI (COP por defecto).
String formatMoney(
  num amount, {
  String currencyCode = 'COP',
  int fractionDigits = 0,
}) {
  return '${amount.toStringAsFixed(fractionDigits)} $currencyCode';
}
