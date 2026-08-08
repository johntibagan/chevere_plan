/// Hook para validación de horarios (§7.1).
/// Ciclo 5: siempre abierto; la validación real llega con fichas enriquecidas (§8.2).
class PlanHoursPolicy {
  const PlanHoursPolicy._();

  /// Retorna true si el sitio puede incluirse en la franja del plan.
  /// Sin horario cargado → incluir. Con horario futuro → filtrar aquí.
  static bool isOpenInWindow({
    required String siteId,
    DateTime? windowStart,
    DateTime? windowEnd,
  }) {
    // ignore: unused_local_variable — parámetros listos para C8+/ficha dueño
    final _ = (siteId, windowStart, windowEnd);
    return true;
  }
}
