import 'dart:convert';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Entrada persistida: payload JSON + marca de tiempo.
class CacheRecord {
  const CacheRecord({
    required this.payload,
    required this.fetchedAtMs,
  });

  final Object? payload;
  final int fetchedAtMs;

  DateTime get fetchedAt =>
      DateTime.fromMillisecondsSinceEpoch(fetchedAtMs, isUtc: true);

  Map<String, dynamic> toJson() => {
        'payload': payload,
        'fetchedAtMs': fetchedAtMs,
      };

  factory CacheRecord.fromJson(Map<String, dynamic> json) {
    return CacheRecord(
      payload: json['payload'],
      fetchedAtMs: (json['fetchedAtMs'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Caché en capas: memoria → Hive (disco) → (red la aporta el caller).
class EntityCacheStore {
  EntityCacheStore._();

  static final EntityCacheStore instance = EntityCacheStore._();

  static const _boxName = 'entity_cache_v1';

  Box<String>? _box;
  final Map<String, CacheRecord> _memory = {};
  var _ready = false;

  bool get isReady => _ready;

  Future<void> init() async {
    if (_ready) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
    _ready = true;
  }

  CacheRecord? peek(String key) => _memory[key];

  Future<CacheRecord?> read(String key) async {
    final mem = _memory[key];
    if (mem != null) return mem;
    final box = _box;
    if (box == null) return null;
    try {
      final raw = box.get(key);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      final record = CacheRecord.fromJson(Map<String, dynamic>.from(map));
      _memory[key] = record;
      return record;
    } catch (_) {
      // Caché corrupta: borrar clave y seguir a red.
      try {
        await box.delete(key);
      } catch (_) {}
      _memory.remove(key);
      return null;
    }
  }

  Future<void> write(String key, Object? payload) async {
    final record = CacheRecord(
      payload: payload,
      fetchedAtMs: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    _memory[key] = record;
    final box = _box;
    if (box == null) return;
    try {
      await box.put(key, jsonEncode(record.toJson()));
    } catch (_) {
      // Disco falló: memoria sigue válida.
    }
  }

  Future<void> invalidate(String key) async {
    _memory.remove(key);
    try {
      await _box?.delete(key);
    } catch (_) {}
  }

  Future<void> invalidatePrefix(String prefix) async {
    final keys = [
      ..._memory.keys.where((k) => k.startsWith(prefix)),
      ...?_box?.keys.whereType<String>().where((k) => k.startsWith(prefix)),
    ];
    for (final k in keys.toSet()) {
      await invalidate(k);
    }
  }

  /// Borra toda la caché de entidad (p. ej. al cerrar sesión / cambiar de cuenta).
  Future<void> clearAll() async {
    _memory.clear();
    try {
      await _box?.clear();
    } catch (_) {}
  }
}
