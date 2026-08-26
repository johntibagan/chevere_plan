import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app.dart';
import '../../features/saves/data/saves_repository.dart';
import '../../features/saves/presentation/open_site_detail.dart';
import '../../features/saves/presentation/save_place_page.dart';
import 'notification_kind.dart';

/// Enruta taps de notificaciones locales (proximidad, borrador, futuros).
class LocalNotificationRouter {
  LocalNotificationRouter._();

  static String? _pendingProximitySiteId;
  static String? _pendingDraftSaveId;

  static void handlePayload(String? payload) {
    final p = payload?.trim();
    if (p == null || p.isEmpty) return;

    if (p.startsWith(NotificationKind.proximity.payloadPrefix)) {
      final id =
          p.substring(NotificationKind.proximity.payloadPrefix.length).trim();
      if (id.isEmpty) return;
      _pendingProximitySiteId = id;
      tryOpenPending();
      return;
    }
    if (p.startsWith(NotificationKind.draft.payloadPrefix)) {
      final id = p.substring(NotificationKind.draft.payloadPrefix.length).trim();
      if (id.isEmpty) return;
      _pendingDraftSaveId = id;
      tryOpenPending();
      return;
    }
    // event: / summary: — reservados; no-op hasta que existan pantallas.
  }

  /// Reintentar tras login / primer frame con navigator listo.
  static void tryOpenPending() {
    if (Supabase.instance.client.auth.currentSession == null) return;
    final nav = appNavigatorKey.currentState;
    final ctx = appNavigatorKey.currentContext;
    if (nav == null || ctx == null) return;

    final siteId = _pendingProximitySiteId;
    if (siteId != null) {
      _pendingProximitySiteId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final c = appNavigatorKey.currentContext;
        if (c == null) return;
        openSiteDetail(c, siteId: siteId);
      });
      return;
    }

    final saveId = _pendingDraftSaveId;
    if (saveId != null) {
      _pendingDraftSaveId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final c = appNavigatorKey.currentContext;
        if (c == null) return;
        Navigator.of(c).push(
          MaterialPageRoute(
            builder: (_) => SavePlacePage(
              existingSaveId: saveId,
              savesRepository: SavesRepository(),
            ),
          ),
        );
      });
    }
  }
}
