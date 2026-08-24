import 'geo_models.dart';

/// Coincidencia difusa sobre el catálogo ya cacheado (sin red).
abstract final class GeoFuzzy {
  static String fold(String raw) {
    var s = raw.toLowerCase().trim();
    if (s.isEmpty) return '';
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    final buf = StringBuffer();
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      final i = from.indexOf(ch);
      buf.write(i >= 0 ? to[i] : ch);
    }
    return buf.toString().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static int score(String query, String name) {
    final q = fold(query);
    final n = fold(name);
    if (q.isEmpty || n.isEmpty) return 0;
    if (n == q) return 100;
    if (n.startsWith(q)) return 82 + (q.length.clamp(0, 12));
    if (n.contains(q)) return 58 + (q.length.clamp(0, 10));
    for (final token in n.split(' ')) {
      if (token == q) return 90;
      if (token.startsWith(q) && q.length >= 3) return 70;
    }
    if (q.length >= 4) {
      final d = _levenshtein(q, n);
      if (d == 1) return 74;
      if (d == 2 && q.length >= 6) return 62;
    }
    return 0;
  }

  static const minAccept = 58;

  static GeoDepartment? bestDepartment(
    GeoCatalog catalog,
    String query, {
    int minScore = minAccept,
  }) {
    GeoDepartment? best;
    var bestScore = 0;
    for (final d in catalog.activeDepartments) {
      final s = score(query, d.name);
      if (s > bestScore) {
        bestScore = s;
        best = d;
      }
    }
    if (bestScore < minScore) return null;
    return best;
  }

  static GeoCity? bestCity(
    List<GeoCity> cities,
    String query, {
    int minScore = minAccept,
  }) {
    GeoCity? best;
    var bestScore = 0;
    for (final c in cities) {
      final s = score(query, c.name);
      if (s > bestScore) {
        bestScore = s;
        best = c;
      }
    }
    if (bestScore < minScore) return null;
    return best;
  }

  /// Departamento primero; ciudad filtrada. Si el depto falla, infiere por ciudad.
  static ({GeoDepartment? department, GeoCity? city}) match({
    required GeoCatalog catalog,
    String? departmentHint,
    String? cityHint,
  }) {
    final deptHint = departmentHint?.trim() ?? '';
    final cityH = cityHint?.trim() ?? '';

    GeoDepartment? dept;
    if (deptHint.isNotEmpty) {
      dept = bestDepartment(catalog, deptHint);
    }

    GeoCity? city;
    if (dept != null && cityH.isNotEmpty) {
      city = bestCity(catalog.citiesIn(dept.id), cityH);
    }

    if (dept == null && cityH.isNotEmpty) {
      city = bestCity(catalog.cities, cityH);
      if (city != null) {
        dept = catalog.departmentById(city.departmentId);
      }
    }

    return (department: dept, city: city);
  }

  static List<T> filter<T>(
    List<T> items,
    String query,
    String Function(T) nameOf, {
    int limit = 12,
  }) {
    final q = query.trim();
    if (q.isEmpty) {
      final copy = [...items]..sort((a, b) => nameOf(a).compareTo(nameOf(b)));
      return copy.take(40).toList();
    }
    final scored = <({T item, int score})>[];
    for (final item in items) {
      final s = score(q, nameOf(item));
      if (s > 0) scored.add((item: item, score: s));
    }
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return nameOf(a.item).compareTo(nameOf(b.item));
    });
    return scored.take(limit).map((e) => e.item).toList();
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.length > 24 || b.length > 24) return 99;
    final m = a.length;
    final n = b.length;
    var prev = List<int>.generate(n + 1, (j) => j);
    for (var i = 1; i <= m; i++) {
      final cur = List<int>.filled(n + 1, 0);
      cur[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        cur[j] = [
          prev[j] + 1,
          cur[j - 1] + 1,
          prev[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      prev = cur;
    }
    return prev[n];
  }
}
