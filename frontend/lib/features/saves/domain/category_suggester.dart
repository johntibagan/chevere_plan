import '../../admin/data/admin_models.dart';

/// Resultado de sugerir categorías a partir de texto del sitio / Maps.
class CategorySuggestion {
  const CategorySuggestion({
    required this.categories,
    required this.usedDefault,
  });

  final List<Category> categories;
  final bool usedDefault;
}

/// Sugiere subcategorías por nombre, dirección o keywords; si no hay match → Otros.
abstract final class CategorySuggester {
  static const defaultParentSlug = 'otros';
  static const defaultChildSlug = 'otro';

  /// Puntuación mínima para aceptar un match (evita falsos positivos cortos).
  static const int minScore = 4;

  static Category? defaultCategory(List<Category> categories) {
    final active = categories.where((c) => c.isActive).toList();
    Category? parent;
    for (final c in active) {
      if (c.isRoot && c.slug == defaultParentSlug) {
        parent = c;
        break;
      }
    }
    if (parent != null) {
      for (final c in active) {
        if (c.parentId == parent.id && c.slug == defaultChildSlug) {
          return c;
        }
      }
      return parent;
    }
    for (final c in active) {
      if (c.slug == defaultChildSlug) return c;
    }
    for (final c in active) {
      if (c.slug == defaultParentSlug) return c;
    }
    return null;
  }

  static CategorySuggestion suggest({
    required List<Category> categories,
    required String haystack,
  }) {
    final active = categories.where((c) => c.isActive).toList();
    final text = normalize(haystack);
    if (text.isNotEmpty) {
      final scored = <({Category category, int score})>[];
      for (final c in active.where((c) => !c.isRoot)) {
        final score = scoreCategory(c, text);
        if (score >= minScore) {
          scored.add((category: c, score: score));
        }
      }
      scored.sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;
        return a.category.sortOrder.compareTo(b.category.sortOrder);
      });
      if (scored.isNotEmpty) {
        return CategorySuggestion(
          categories: [scored.first.category],
          usedDefault: false,
        );
      }
    }

    final fallback = defaultCategory(active);
    return CategorySuggestion(
      categories: fallback == null ? const [] : [fallback],
      usedDefault: true,
    );
  }

  static String normalize(String raw) {
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
    return buf.toString().replaceAll(RegExp(r'[^a-z0-9\s+/.-]'), ' ');
  }

  static int scoreCategory(Category c, String normalizedHaystack) {
    var score = 0;
    final name = normalize(c.nameEs);
    if (name.isNotEmpty && _containsTerm(normalizedHaystack, name)) {
      score += 12 + name.length.clamp(0, 20);
    }

    final slugTerms = c.slug.split('-').where((t) => t.length >= 3);
    for (final term in slugTerms) {
      if (_containsTerm(normalizedHaystack, term)) {
        score += 6 + term.length.clamp(0, 10);
      }
    }

    for (final rawKw in c.keywords) {
      final kw = normalize(rawKw);
      if (kw.isEmpty) continue;
      if (!_containsTerm(normalizedHaystack, kw)) continue;
      // Keywords cortas (bar, spa…) solo si son token completo.
      if (kw.length <= 3) {
        score += 5;
      } else {
        score += 8 + (kw.length ~/ 2).clamp(0, 12);
      }
    }
    return score;
  }

  static bool _containsTerm(String haystack, String term) {
    if (term.isEmpty || haystack.isEmpty) return false;
    if (term.length <= 3) {
      return RegExp(
        '(^|[^a-z0-9])${RegExp.escape(term)}([^a-z0-9]|\$)',
      ).hasMatch(haystack);
    }
    return haystack.contains(term);
  }
}
