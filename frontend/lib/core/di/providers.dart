import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/admin/data/admin_models.dart';
import '../../features/admin/data/admin_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/profile_repository.dart';
import '../../features/moderation/data/moderation_repository.dart';
import '../../features/plans/data/plans_repository.dart';
import '../../features/proximity/data/geofence_sync_service.dart';
import '../../features/proximity/data/proximity_repository.dart';
import '../../features/routes/data/routes_repository.dart';
import '../../features/saves/data/draft_reminder_service.dart';
import '../../features/saves/data/place_geocoder.dart';
import '../../features/saves/data/saves_repository.dart';
import '../../features/search/data/search_repository.dart';

/// Cliente Supabase compartido (inyectable en tests).
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(client: ref.watch(supabaseClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(client: ref.watch(supabaseClientProvider));
});

final savesRepositoryProvider = Provider<SavesRepository>((ref) {
  return SavesRepository(client: ref.watch(supabaseClientProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(client: ref.watch(supabaseClientProvider));
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(client: ref.watch(supabaseClientProvider));
});

final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  return PlansRepository(client: ref.watch(supabaseClientProvider));
});

final routesRepositoryProvider = Provider<RoutesRepository>((ref) {
  return RoutesRepository(client: ref.watch(supabaseClientProvider));
});

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepository(client: ref.watch(supabaseClientProvider));
});

final proximityRepositoryProvider = Provider<ProximityRepository>((ref) {
  return ProximityRepository(client: ref.watch(supabaseClientProvider));
});

final geofenceSyncServiceProvider = Provider<GeofenceSyncService>((ref) {
  return GeofenceSyncService(
    profileRepository: ref.watch(profileRepositoryProvider),
    proximityRepository: ref.watch(proximityRepositoryProvider),
  );
});

final placeGeocoderProvider = Provider<PlaceGeocoder>((ref) {
  return PlaceGeocoder();
});

/// Servicios singleton existentes (R1: se exponen vía Riverpod sin reescribirlos).
final draftReminderServiceProvider = Provider<DraftReminderService>((ref) {
  return DraftReminderService.instance;
});

/// Cache en memoria de catálogo admin (R4: evita refetch por pantalla).
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchCategories();
});

final transportTypesProvider =
    FutureProvider<List<TransportType>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchTransportTypes();
});
