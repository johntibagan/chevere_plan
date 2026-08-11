/// Formato de fecha corto para UI (sin dependencia intl todavía; R3).
String formatDateDmY(DateTime value, {bool toLocal = true}) {
  final d = toLocal ? value.toLocal() : value;
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return '$day/$month/${d.year}';
}
