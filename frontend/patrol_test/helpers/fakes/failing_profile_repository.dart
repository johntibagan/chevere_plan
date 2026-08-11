import 'package:chevere_plan/core/di/providers.dart';
import 'package:chevere_plan/features/auth/data/profile.dart';
import 'package:chevere_plan/features/auth/data/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Falla técnica deliberada (PostgREST-like) para validar regla 8.
class FailingProfileRepository extends ProfileRepository {
  FailingProfileRepository({super.client});

  @override
  Future<Profile?> fetchCurrent() async {
    throw StateError(
      'PostgrestException: relation "profiles" does not exist (42P01)',
    );
  }
}

/// Lazy: se crea al leer el provider (después de `Supabase.initialize`).
Override failingProfileRepositoryOverride() {
  return profileRepositoryProvider.overrideWith(
    (ref) => FailingProfileRepository(
      client: ref.watch(supabaseClientProvider),
    ),
  );
}
