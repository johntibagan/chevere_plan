import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/home/presentation/home_page.dart';
import 'core/theme/app_theme.dart';

class CheverePlanApp extends StatelessWidget {
  const CheverePlanApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chevere Plan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AuthGate(authRepository: authRepository),
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
