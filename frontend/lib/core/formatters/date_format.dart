import 'package:intl/intl.dart';

/// Formato de fecha corto para UI (`dd/MM/yyyy` en locale del dispositivo).
String formatDateDmY(DateTime value, {bool toLocal = true, String? locale}) {
  final d = toLocal ? value.toLocal() : value;
  return DateFormat.yMd(locale).format(d);
}

/// Fecha + hora corta (UTC → local).
String formatDateTimeShort(DateTime value, {bool toLocal = true, String? locale}) {
  final d = toLocal ? value.toLocal() : value;
  return DateFormat.yMd(locale).add_Hm().format(d);
}
