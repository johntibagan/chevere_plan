import '../../l10n/app_localizations.dart';

/// Distancia en kilómetros para UI (`2.5 km`). Texto en `.arb` (`formatDistanceKm`).
String formatDistanceKmLabel(AppLocalizations l10n, num km, {int fractionDigits = 1}) {
  return l10n.formatDistanceKm(km.toStringAsFixed(fractionDigits));
}
