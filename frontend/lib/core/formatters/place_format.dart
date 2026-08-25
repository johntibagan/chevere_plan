/// Departamento y municipio para cards/listas (`Boyacá - Tunja`).
String formatDeptCity(String? department, String? city) {
  final d = (department ?? '').trim();
  final c = (city ?? '').trim();
  if (d.isEmpty) return c;
  if (c.isEmpty) return d;
  return '$d - $c';
}
