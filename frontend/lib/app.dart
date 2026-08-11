import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/saves/data/saves_repository.dart';
import '../features/saves/presentation/save_place_page.dart';
import 'core/theme/app_theme.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class CheverePlanApp extends StatefulWidget {
  const CheverePlanApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<CheverePlanApp> createState() => _CheverePlanAppState();
}

class _CheverePlanAppState extends State<CheverePlanApp> {
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
    // App abierta (stream)
    _shareSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (files) => _handleShared(files),
      onError: (_) {},
    );
    // App fría / recién abierta
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
    final payload = texts.join('\n');

    // Esperar un frame para tener navigator + sesión
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = appNavigatorKey.currentState;
      if (nav == null) return;
      if (Supabase.instance.client.auth.currentSession == null) return;
      nav.push(
        MaterialPageRoute<void>(
          builder: (_) => SavePlacePage(
            initialSharedText: payload,
            savesRepository: SavesRepository(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chevere Plan',
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: AuthGate(authRepository: widget.authRepository),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ?? authRepository.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting &&
            session == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (session != null) {
          return HomePage(
            authRepository: authRepository,
            session: session,
          );
        }

        return LoginPage(authRepository: authRepository);
      },
    );
  }
}
