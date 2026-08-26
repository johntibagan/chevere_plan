import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../logging/app_log.dart';

/// Descarga portadas a disco para BigPicture (válido en isolate de geofence).
abstract final class NotificationCoverCache {
  static const _dirName = 'notif_covers';

  static Future<Directory> _dir() async {
    final root = await getApplicationSupportDirectory();
    final dir = Directory(p.join(root.path, _dirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<String?> localPathForKey(String key) async {
    final safe = key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final dir = await _dir();
    final file = File(p.join(dir.path, '$safe.jpg'));
    if (await file.exists() && await file.length() > 0) return file.path;
    return null;
  }

  /// Firma Storage + guarda bytes. Devuelve path local o null.
  static Future<String?> cacheFromStoragePath({
    required String cacheKey,
    required String storagePath,
    SupabaseClient? client,
  }) async {
    final trimmed = storagePath.trim();
    if (trimmed.isEmpty) return null;
    try {
      final c = client ?? Supabase.instance.client;
      final url = await c.storage.from('site-photos').createSignedUrl(trimmed, 3600);
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
      if (res.statusCode < 200 || res.statusCode >= 300 || res.bodyBytes.isEmpty) {
        return null;
      }
      return cacheBytes(cacheKey: cacheKey, bytes: res.bodyBytes);
    } catch (e, st) {
      AppLog.debug(
        'notif cover download failed',
        name: 'notifications',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  static Future<String?> cacheBytes({
    required String cacheKey,
    required Uint8List bytes,
  }) async {
    if (bytes.isEmpty) return null;
    try {
      final safe = cacheKey.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final dir = await _dir();
      final file = File(p.join(dir.path, '$safe.jpg'));
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e, st) {
      AppLog.debug(
        'notif cover write failed',
        name: 'notifications',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
