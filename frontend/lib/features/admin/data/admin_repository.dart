import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_models.dart';

class AdminRepository {
  AdminRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Category>> fetchCategories() async {
    try {
      final rows = await _client
          .from('categories')
          .select(
            'id, parent_id, slug, name_i18n, is_active, age_restricted, '
            'sort_order, icon_key, color_hex, keywords',
          )
          .order('sort_order');
      return (rows as List)
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      // DB sin columna keywords aún (migración 10 pendiente).
      final rows = await _client
          .from('categories')
          .select(
            'id, parent_id, slug, name_i18n, is_active, age_restricted, '
            'sort_order, icon_key, color_hex',
          )
          .order('sort_order');
      return (rows as List)
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
  }

  Future<void> updateCategory(
    String id, {
    required String nameEs,
    required bool isActive,
    required bool ageRestricted,
    List<String> keywords = const [],
  }) async {
    await _client.from('categories').update({
      'name_i18n': {'es': nameEs},
      'is_active': isActive,
      'age_restricted': ageRestricted,
      'keywords': keywords,
    }).eq('id', id);
  }

  Future<List<TransportType>> fetchTransportTypes() async {
    final rows = await _client
        .from('transport_types')
        .select()
        .order('sort_order');
    return (rows as List)
        .map((e) => TransportType.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> updateTransportType(
    String id, {
    required String nameEs,
    required bool isActive,
    double? defaultMaxKm,
    bool clearMaxKm = false,
  }) async {
    await _client.from('transport_types').update({
      'name_i18n': {'es': nameEs},
      'is_active': isActive,
      'default_max_km': clearMaxKm ? null : defaultMaxKm,
    }).eq('id', id);
  }
}
