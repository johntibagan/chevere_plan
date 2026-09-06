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
import 'core/l10n/app_locale.dart';
import 'core/l10n/context_l10n.dart';
import 'core/logging/app_log.dart';
import 'core/notifications/local_notification_router.dart';
import 'core/supabase/supabase_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/chevere_theme_colors.dart';
import 'core/theme/chevere_theme_scope.dart';
import 'core/theme/theme_rebuild.dart';
import 'features/beta/presentation/beta_update_gate.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class CheverePlanApp extends ConsumerStatefulWidget {
  const CheverePlanApp({super.key, this.optimisticSession});

  /// Sesión leída del Keystore de este dispositivo antes de confirmar con red.
  final Session? optimisticSession;

  @override
  ConsumerState<CheverePlanApp> createState() => _CheverePlanAppState();
}

class _CheverePlanAppState extends ConsumerState<CheverePlanApp> {
  StreamSubscription<List<SharedMediaFile>>? _shareSub;
  List<SharedMediaFile>? _pendingShare;

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
    if (!SupabaseBootstrap.isReady) {
      _pendingShare = files;
      unawaited(_flushShareWhenReady());
      return;
    }
    _openShare(files);
  }

  Future<void> _flushShareWhenReady() async {
    await SupabaseBootstrap.ready;
    if (!mounted) return;
    final files = _pendingShare;
    _pendingShare = null;
    if (files == null || !SupabaseBootstrap.isReady) return;
    _openShare(files);
  }

  void _openShare(List<SharedMediaFile> files) {
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
      if (!SupabaseBootstrap.isReady) return;
      if (Supabase.instance.client.auth.currentSession == null &&
          widget.optimisticSession == null) {
        return;
      }
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
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: const Locale(kAppLocale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        final colors =
            Theme.of(context).extension<ChevereThemeColors>() ??
                ChevereThemeColors.dark;
        AppColors.bind(colors);
        return ChevereThemeScope(
          colors: colors,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: BetaUpdateGate(
        child: AuthGate(optimisticSession: widget.optimisticSession),
      ),
    );
  }
}

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key, this.optimisticSession});

  /// Sesión local del mismo dispositivo (Keystore). Confirmar en background.
  final Session? optimisticSession;

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  Session? _lastSession;
  Session? _optimistic;
  bool _forceLogin = false;
  bool _confirmStarted = false;

  @override
  void initState() {
    super.initState();
    _optimistic = widget.optimisticSession;
  }

  /// Confirma la sesión optimista con el servidor sin bloquear el primer paint.
  ///
  /// - OK / sesión válida → no cambia la UI (ya pintamos Home).
  /// - [AuthException] explícita (revocada / no refrescable) → login.
  /// - Red / timeout / retryable → mantener optimista; reintentar más tarde.
  Future<void> _confirmSessionInBackground({bool isRetry = false}) async {
    if (_confirmStarted && !isRetry) return;
    _confirmStarted = true;
    await SupabaseBootstrap.ready;
    if (!mounted) return;
    if (!SupabaseBootstrap.isReady) {
      _scheduleConfirmRetry();
      return;
    }
    try {
      final session = await Supabase.instance.client.auth.getSession();
      if (!mounted) return;
      if (session != null) {
        // Servidor/SDK OK: el stream de auth actualizará; soltar el seed.
        setState(() => _optimistic = null);
        return;
      }
      // Sin sesión en el cliente tras initialize: no hay JWT usable.
      if (_optimistic != null) {
        AppLog.debug(
          'optimistic session cleared (no current session)',
          name: 'auth',
        );
        setState(() {
          _forceLogin = true;
          _optimistic = null;
        });
      }
    } on AuthRetryableFetchException catch (e, st) {
      AppLog.debug(
        'optimistic confirm retryable',
        name: 'auth',
        error: e,
        stackTrace: st,
      );
      _scheduleConfirmRetry();
    } on AuthException catch (e, st) {
      AppLog.debug(
        'optimistic confirm rejected',
        name: 'auth',
        error: e,
        stackTrace: st,
      );
      if (!mounted) return;
      setState(() {
        _forceLogin = true;
        _optimistic = null;
      });
      unawaited(Supabase.instance.client.auth.signOut());
    } catch (e, st) {
      AppLog.debug(
        'optimistic confirm network/other',
        name: 'auth',
        error: e,
        stackTrace: st,
      );
      _scheduleConfirmRetry();
    }
  }

  void _scheduleConfirmRetry() {
    Future<void>.delayed(const Duration(seconds: 45), () {
      if (!mounted || _forceLogin || _optimistic == null) return;
      unawaited(_confirmSessionInBackground(isRetry: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watchAppThemeMode();
    // Rebuild when initialize termina (éxito o fallo).
    ref.watch(supabaseReadyProvider);

    // Antes de cliente listo: pintar Home con sesión de Keystore (sin repos).
    if (!SupabaseBootstrap.isReady) {
      if (_optimistic != null && !_forceLogin) {
        return HomePage(session: _optimistic!);
      }
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_optimistic != null && !_confirmStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_confirmSessionInBackground());
      });
    }

    // Tras init diferido: repos frescos (evita error cacheado si alguien
    // tocó el client demasiado pronto en hot-restart).
    final authRepository = ref.watch(authRepositoryProvider);

    return StreamBuilder<AuthState>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        final event = snapshot.data?.event;
        if (event == AuthChangeEvent.signedOut) {
          _optimistic = null;
          _forceLogin = true;
        }

        final liveSession =
            snapshot.data?.session ?? authRepository.currentSession;
        final session = liveSession ??
            (_forceLogin ? null : _optimistic);

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

        // Con sesión optimista (mismo dispositivo) no bloquear con spinner.
        if (snapshot.connectionState == ConnectionState.waiting &&
            session == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (session != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LocalNotificationRouter.tryOpenPending();
            unawaited(ref.read(categoriesProvider.future));
          });
          return HomePage(session: session);
        }

        return const LoginPage();
      },
    );
  }
}
