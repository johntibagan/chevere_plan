import 'package:flutter/services.dart';

/// Reglas del handle público (@username).
///
/// - Prefijo `@` solo en UI (no se guarda).
/// - Minúsculas en tiempo real; tildes → ASCII.
/// - Solo `a-z`, `0-9`, `_`, `.`
/// - Longitud 3–20.
abstract final class UsernameRules {
  static const int minLength = 3;
  static const int maxLength = 20;

  static final RegExp allowedChars = RegExp(r'[a-z0-9._]');
  static final RegExp validFull = RegExp(r'^[a-z0-9._]{3,20}$');

  static const Set<String> reserved = {
    'admin',
    'root',
    'support',
    'soporte',
    'help',
    'ayuda',
    'chevere',
    'chevereplan',
    'oficial',
    'official',
    'null',
    'undefined',
    'system',
    'sistema',
    'staff',
    'mod',
    'moderator',
  };

  /// Normaliza para guardar / comparar (sin `@`, minúsculas, sin tildes).
  static String? normalize(String? raw) {
    if (raw == null) return null;
    var s = raw.trim().toLowerCase();
    if (s.startsWith('@')) s = s.replaceFirst(RegExp(r'^@+'), '');
    s = _stripAccents(s);
    final buf = StringBuffer();
    for (final r in s.runes) {
      final ch = String.fromCharCode(r);
      if (allowedChars.hasMatch(ch)) buf.write(ch);
    }
    final out = buf.toString();
    return out.isEmpty ? null : out;
  }

  /// Texto que queda en el TextField mientras el usuario escribe.
  static String sanitizeInput(String raw) {
    return normalize(raw) ?? '';
  }

  static bool isFormatValid(String? normalized) {
    if (normalized == null) return false;
    return validFull.hasMatch(normalized) && !reserved.contains(normalized);
  }

  static UsernameLocalIssue? localIssue(String? normalized) {
    if (normalized == null || normalized.isEmpty) {
      return UsernameLocalIssue.empty;
    }
    if (normalized.length < minLength) return UsernameLocalIssue.tooShort;
    if (normalized.length > maxLength) return UsernameLocalIssue.tooLong;
    if (!validFull.hasMatch(normalized)) return UsernameLocalIssue.invalid;
    if (reserved.contains(normalized)) return UsernameLocalIssue.reserved;
    return null;
  }

  static String formatHandle(String? username) {
    final n = username?.trim();
    if (n == null || n.isEmpty) return '';
    return n.startsWith('@') ? n : '@$n';
  }

  static String _stripAccents(String input) {
    const map = {
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'ã': 'a',
      'å': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'ý': 'y',
      'ÿ': 'y',
      'ñ': 'n',
      'ç': 'c',
    };
    final buf = StringBuffer();
    for (final r in input.runes) {
      final ch = String.fromCharCode(r);
      buf.write(map[ch] ?? ch);
    }
    // NFD leftovers
    return buf.toString().replaceAll(RegExp(r'[\u0300-\u036f]'), '');
  }
}

enum UsernameLocalIssue { empty, tooShort, tooLong, invalid, reserved }

/// Filtra teclado: fuerza minúsculas y bloquea no permitidos.
class UsernameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = UsernameRules.sanitizeInput(newValue.text);
    final clipped = cleaned.length > UsernameRules.maxLength
        ? cleaned.substring(0, UsernameRules.maxLength)
        : cleaned;
    return TextEditingValue(
      text: clipped,
      selection: TextSelection.collapsed(offset: clipped.length),
    );
  }
}
