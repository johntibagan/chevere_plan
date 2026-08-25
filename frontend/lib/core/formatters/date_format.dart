import 'package:intl/intl.dart';

/// Fecha visible: `dd/MMM/y` del locale (`es` → `25/ago/2026`).
/// Meses: CLDR vía `intl` (no una lista propia). UTC → local.
String formatDateDmY(DateTime value, {bool toLocal = true, String? locale}) {
  final d = toLocal ? value.toLocal() : value;
  return DateFormat('dd/MMM/y', locale ?? 'es').format(d);
}

/// Misma fecha (sin hora en UI).
String formatDateTimeShort(DateTime value, {bool toLocal = true, String? locale}) {
  return formatDateDmY(value, toLocal: toLocal, locale: locale);
}

/// Clave de cupo UTC `yyyyMMdd` (no es fecha de UI).
String formatUtcDayCompact([DateTime? now]) {
  return DateFormat('yyyyMMdd').format((now ?? DateTime.now()).toUtc());
}

/// Día civil local `yyyy-MM-dd`.
String formatLocalDayIso([DateTime? now]) {
  return DateFormat('yyyy-MM-dd').format(now ?? DateTime.now());
}
