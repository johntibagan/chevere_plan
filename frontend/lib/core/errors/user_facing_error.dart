import '../logging/app_log.dart';

/// Errores seguros para mostrar en UI (regla 8 del prompt MVP).
class AppUserError implements Exception {
  const AppUserError(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Mensaje genérico para capas sin [BuildContext] (auth, Result).
/// En UI con contexto, preferir `context.l10n.errorGeneric`.
const String kGenericAppError = 'Error en la app. Intenta de nuevo.';

/// Convierte cualquier excepción en mensaje de usuario.
/// - [AppUserError] → mensaje de negocio (o genérico si así se lanzó).
/// - Resto (PostgREST, red, config, etc.) → genérico; detalle solo en log seguro.
String userFacingError(Object error, {StackTrace? stackTrace, String? context}) {
  if (error is AppUserError) return error.message;

  AppLog.error(
    context ?? 'Error técnico',
    name: 'app',
    error: error,
    stackTrace: stackTrace,
  );
  return kGenericAppError;
}
