import 'package:supabase_flutter/supabase_flutter.dart';

import 'geo_models.dart';

class GeoRepository {
  GeoRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Una sola descarga: ~33 deptos + ~1100 municipios. PostgREST default=1000.
  Future<GeoCatalog> fetchCatalog({String countryCode = 'CO'}) async {
    final deptRows = await _client
        .from('departments')
        .select('id, country_code, code, name, name_norm')
        .eq('country_code', countryCode)
        .eq('is_active', true)
        .order('name')
        .limit(200);

    final departments = (deptRows as List)
        .map((e) => GeoDepartment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    if (departments.isEmpty) {
      return GeoCatalog(
        countryCode: countryCode,
        departments: const [],
        cities: const [],
      );
    }

    final cityRows = await _client
        .from('cities')
        .select('id, department_id, code, name, name_norm, kind')
        .eq('is_active', true)
        .inFilter('department_id', departments.map((d) => d.id).toList())
        .order('name')
        .limit(5000);

    final cities = (cityRows as List)
        .map((e) => GeoCity.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return GeoCatalog(
      countryCode: countryCode,
      departments: departments,
      cities: cities,
    );
  }
}
