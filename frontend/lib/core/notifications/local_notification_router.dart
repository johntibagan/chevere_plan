import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app.dart';
import '../../features/saves/presentation/open_site_detail.dart';

/// Enruta taps de notificaciones locales (proximidad) a la ficha del sitio.
class LocalNotificationRouter {
  LocalNotificationRouter._();

  static const proximityPrefix = 'proximity:';

  static String? _pendingSiteId;

  static String? siteIdFromPayload(String? payload) {
    final p = payload?.trim();
    if (p == null || p.isEmpty) return null;
    if (p.startsWith(proximityPrefix)) {
      final id = p.substring(proximityPrefix.length).trim();
      return id.isEmpty ? null : id;
    }
    return null;
  }

  static void handlePayload(String? payload) {
    final id = siteIdFromPayload(payload);
    if (id == null) return;
    _pendingSiteId = id;
    tryOpenPending();
  }

  /// Reintentar tras login / primer frame con navigator listo.
  static void tryOpenPending() {
    final id = _pendingSiteId;
    if (id == null) return;
    if (Supabase.instance.client.auth.currentSession == null) return;
    final nav = appNavigatorKey.currentState;
    final ctx = appNavigatorKey.currentContext;
    if (nav == null || ctx == null) return;
    _pendingSiteId = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = appNavigatorKey.currentContext;
      if (c == null) return;
      openSiteDetail(c, siteId: id);
    });
  }
}
