/// Tipos de notificación local (canales + payload). Extensible para eventos / resumen.
enum NotificationKind {
  proximity,
  draft,
  /// Reserva: eventos de interés (aún no se emiten).
  eventInterest,
  /// Reserva: resumen mensual de planes/visitas (aún no se emiten).
  monthlySummary,
}

extension NotificationKindX on NotificationKind {
  String get channelId => switch (this) {
        NotificationKind.proximity => 'proximity_reminders',
        NotificationKind.draft => 'draft_reminders',
        NotificationKind.eventInterest => 'event_interest',
        NotificationKind.monthlySummary => 'monthly_summaries',
      };

  String get payloadPrefix => switch (this) {
        NotificationKind.proximity => 'proximity:',
        NotificationKind.draft => 'draft:',
        NotificationKind.eventInterest => 'event:',
        NotificationKind.monthlySummary => 'summary:',
      };

  String payloadFor(String id) => '$payloadPrefix$id';
}
