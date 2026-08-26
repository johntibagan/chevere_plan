import 'notification_kind.dart';

/// Contenido estándar de tarjeta (estilo recuerdo: foto + nombre + lugar).
class AppNotificationCard {
  const AppNotificationCard({
    required this.kind,
    required this.id,
    required this.title,
    required this.placeLine,
    required this.contextLine,
    this.imageFilePath,
    this.notificationId,
  });

  final NotificationKind kind;
  /// Id de negocio (siteId, saveId, …) para payload / tap.
  final String id;
  /// Nombre del sitio (o título del resumen).
  final String title;
  /// `Departamento - Municipio` (puede ir vacío).
  final String placeLine;
  /// Frase de contexto: «Lugar cerca de ti», «Completa tu guardado», …
  final String contextLine;
  /// Ruta local a la portada (BigPicture). Null = solo texto.
  final String? imageFilePath;
  /// Id numérico de la notificación; si null, se deriva de [kind]+[id].
  final int? notificationId;

  String get payload => kind.payloadFor(id);

  int get resolvedNotificationId =>
      notificationId ?? (Object.hash(kind.name, id) & 0x7fffffff);
}
