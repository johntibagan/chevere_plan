import 'user_facing_error.dart';

/// Resultado de data/domain: éxito o [Failure] (nunca stack traces a la UI).
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get valueOrNull => switch (this) {
        Ok(:final value) => value,
        Err() => null,
      };

  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) {
    return switch (this) {
      Ok(:final value) => ok(value),
      Err(:final failure) => err(failure),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// Fallo de capa data/domain. [userMessage] es lo único mostrable.
final class Failure {
  const Failure({
    this.userMessage = kGenericAppError,
    this.cause,
  });

  final String userMessage;
  final Object? cause;

  factory Failure.from(Object error, [StackTrace? stackTrace]) {
    if (error is AppUserError) {
      return Failure(userMessage: error.message, cause: error);
    }
    userFacingError(error, stackTrace: stackTrace);
    return Failure(cause: error);
  }
}

Future<Result<T>> guardAsync<T>(Future<T> Function() run) async {
  try {
    return Ok(await run());
  } catch (e, st) {
    return Err(Failure.from(e, st));
  }
}
