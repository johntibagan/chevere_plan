import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../logging/app_log.dart';

/// Registra / actualiza el token FCM del dispositivo en [user_fcm_tokens].
/// Sin UI propia: permiso del SO vía [FirebaseMessaging.requestPermission].
class PushNotificationService {
  PushNotificationService();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenSub;
  String? _lastToken;
  String? _boundUserId;

  String? get lastToken => _lastToken;

  /// Tras login / sesión confirmada: permiso + upsert token.
  Future<void> syncForSession(SupabaseClient client) async {
    final uid = client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      AppLog.debug(
        'FCM permission: ${settings.authorizationStatus}',
        name: 'push',
      );

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        AppLog.debug('FCM token vacío', name: 'push');
        return;
      }

      await _upsertToken(client, userId: uid, token: token);
      _boundUserId = uid;
      _listenRefresh(client, uid);
    } catch (e, st) {
      AppLog.debug(
        'Push syncForSession',
        name: 'push',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Al cerrar sesión: borra el token de este dispositivo.
  Future<void> clearForLogout(SupabaseClient client) async {
    await _tokenSub?.cancel();
    _tokenSub = null;
    final token = _lastToken;
    _lastToken = null;
    _boundUserId = null;
    if (token == null || token.isEmpty) return;
    try {
      await client.from('user_fcm_tokens').delete().eq('token', token);
    } catch (e, st) {
      AppLog.debug(
        'Push clearForLogout',
        name: 'push',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _listenRefresh(SupabaseClient client, String userId) {
    _tokenSub?.cancel();
    _tokenSub = _messaging.onTokenRefresh.listen((token) {
      unawaited(_upsertToken(client, userId: userId, token: token));
    });
  }

  Future<void> _upsertToken(
    SupabaseClient client, {
    required String userId,
    required String token,
  }) async {
    _lastToken = token;
    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.android => 'android',
      _ => Platform.isIOS
          ? 'ios'
          : Platform.isAndroid
              ? 'android'
              : null,
    };
    await client.from('user_fcm_tokens').upsert(
      {
        'user_id': userId,
        'token': token,
        'platform': platform,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'token',
    );
    AppLog.debug(
      'FCM token upserted (len=${token.length}) user=$_boundUserId',
      name: 'push',
    );
  }
}
