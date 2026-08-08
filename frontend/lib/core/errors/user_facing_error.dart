import 'dart:developer' as developer;

/// Errores seguros para mostrar en UI (regla 8 del prompt MVP).
class AppUserError implements Exception {
  const AppUserError(this.message);

  final String message;

  @override
  String toString() => message;
}

const String kGenericAppError = 'Error en la app. Intenta de nuevo.';

/// Convierte cualquier excepción en mensaje de usuario.
/// - [AppUserError] → mensaje de negocio (o genérico si así se lanzó).
/// - Resto (PostgREST, red, config, etc.) → genérico; detalle solo en log.
String userFacingError(Object error, {StackTrace? stackTrace, String? context}) {
  if (error is AppUserError) return error.message;

  developer.log(
    context ?? 'Error técnico',
    name: 'app',
    error: error,
    stackTrace: stackTrace,
  );
  return kGenericAppError;
}
