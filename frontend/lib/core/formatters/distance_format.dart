import '../../l10n/app_localizations.dart';
import '../distance/distance_unit.dart';

/// Formatea una distancia ya en kilómetros (respuesta de búsqueda / ficha).
String formatDistanceFromKm(
  AppLocalizations l10n,
  DistanceUnit unit,
  num km, {
  int? fractionDigits,
}) {
  final digits = fractionDigits ?? unit.displayFractionDigits;
  final value = unit.kmToUnit(km);
  return l10n.formatDistanceValue(
    value.toStringAsFixed(digits),
    unit.symbol,
  );
}

/// Compat: etiqueta en km (preferí [formatDistanceFromKm] con la unidad del usuario).
String formatDistanceKmLabel(
  AppLocalizations l10n,
  num km, {
  int fractionDigits = 1,
}) {
  return formatDistanceFromKm(
    l10n,
    DistanceUnit.fallbackKm,
    km,
    fractionDigits: fractionDigits,
  );
}

/// Valor + símbolo (labels de campo / slider).
String formatDistanceRaw(DistanceUnit unit, num valueInUnit, {int? fractionDigits}) {
  final digits = fractionDigits ?? unit.displayFractionDigits;
  return '${valueInUnit.toStringAsFixed(digits)} ${unit.symbol}';
}
