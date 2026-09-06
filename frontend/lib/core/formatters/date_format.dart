import 'package:intl/intl.dart';

import '../l10n/app_locale.dart';

/// Fecha visible: `dd/MMM/y` del locale (`es` → `25/ago/2026`).
/// Meses: CLDR vía `intl` (no una lista propia). UTC → local.
String formatDateDmY(DateTime value, {bool toLocal = true, String? locale}) {
  final d = toLocal ? value.toLocal() : value;
  return DateFormat('dd/MMM/y', locale ?? kAppLocale).format(d);
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

/// Solo la parte fecha (sin zona) para columnas `date` de Postgres.
String formatDateOnlyIso(DateTime value) {
  final d = DateTime(value.year, value.month, value.day);
  return DateFormat('yyyy-MM-dd').format(d);
}

/// Parsea `yyyy-MM-dd` (o ISO) a día civil local sin hora.
DateTime? parseDateOnly(Object? raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty) return null;
  final day = s.length >= 10 ? s.substring(0, 10) : s;
  final parsed = DateTime.tryParse(day);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

/// Rango de plan: `01/ene/2026 – 05/ene/2026` (uno o ambos).
String? formatPlanDateRange(DateTime? start, DateTime? end, {String? locale}) {
  if (start == null && end == null) return null;
  final a = start == null ? null : formatDateDmY(start, toLocal: false, locale: locale);
  final b = end == null ? null : formatDateDmY(end, toLocal: false, locale: locale);
  if (a != null && b != null) return '$a – $b';
  return a ?? b;
}
