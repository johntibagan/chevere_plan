import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/saves/data/share_parser.dart';
import '../features/saves/presentation/save_place_page.dart';
import 'core/cache/session_cache_cleanup.dart';
import 'core/di/providers.dart';
import 'core/l10n/context_l10n.dart';
import 'core/notifications/local_notification_router.dart';
import 'core/theme/app_theme.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class CheverePlanApp extends ConsumerStatefulWidget {
  const CheverePlanApp({super.key});

  @override
  ConsumerState<CheverePlanApp> createState() => _CheverePlanAppState();
}

class _CheverePlanAppState extends ConsumerState<CheverePlanApp> {
  StreamSubscription<List<SharedMediaFile>>? _shareSub;

  @override
  void initState() {
    super.initState();
    _listenShares();
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    super.dispose();
  }

  void _listenShares() {
    _shareSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (files) => _handleShared(files),
      onError: (_) {},
    );
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      _handleShared(files);
      ReceiveSharingIntent.instance.reset();
    });
  }

  void _handleShared(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    final texts = files
        .map((f) => f.path)
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (texts.isEmpty) return;
    var payload = texts.join('\n');
    if (payload.length > ShareParser.maxInputChars) {
      payload = payload.substring(0, ShareParser.maxInputChars);
    }
    final parsed = ShareParser.parse(payload);
    if (!parsed.hasNavigableContent) return;
    final safeText = parsed.rawText ?? parsed.url ?? payload;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = appNavigatorKey.currentState;
      if (nav == null) return;
      if (Supabase.instance.client.auth.currentSession == null) return;
      final savesRepo = ref.read(savesRepositoryProvider);
      nav.push(
        MaterialPageRoute<void>(
          builder: (_) => SavePlacePage(
            initialSharedText: safeText,
            savesRepository: savesRepo,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      locale: const Locale('es'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  Session? _lastSession;

  @override
  Widget build(BuildContext context) {
    final authRepository = ref.watch(authRepositoryProvider);

    return StreamBuilder<AuthState>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ?? authRepository.currentSession;

        if (_lastSession != null && session == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            unawaited(
              clearSessionCaches(
                invalidate: ref.invalidate,
                read: ref.read,
              ),
            );
          });
        }
        _lastSession = session;

        if (snapshot.connectionState == ConnectionState.waiting &&
            session == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (session != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LocalNotificationRouter.tryOpenPending();
          });
          return HomePage(session: session);
        }

        return const LoginPage();
      },
    );
  }
}
