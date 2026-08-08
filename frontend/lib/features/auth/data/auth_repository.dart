import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';

class AuthRepository {
  AuthRepository({
    SupabaseClient? client,
    GoogleSignIn? googleSignIn,
  })  : _client = client ?? Supabase.instance.client,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final SupabaseClient _client;
  final GoogleSignIn _googleSignIn;
  bool _googleReady = false;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> ensureGoogleInitialized() async {
    if (_googleReady) return;
    if (!Env.hasGoogleWebClientId) {
      throw StateError(
        'Falta GOOGLE_WEB_CLIENT_ID en frontend/.env '
        '(Client ID del OAuth tipo Web en Google Cloud).',
      );
    }
    await _googleSignIn.initialize(serverClientId: Env.googleWebClientId);
    _googleReady = true;
  }

  Future<AuthResponse> signInWithGoogle() async {
    await ensureGoogleInitialized();

    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        'Google no devolvió idToken. Revisa SHA-1, package com.chevere.plan '
        'y GOOGLE_WEB_CLIENT_ID (OAuth Web).',
      );
    }

    String? accessToken;
    try {
      final authorization = await account.authorizationClient
          .authorizationForScopes(const ['email', 'profile']);
      accessToken = authorization?.accessToken;
    } catch (_) {
      // Supabase puede autenticar solo con idToken.
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> signOut() async {
    try {
      if (_googleReady) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Ignorar fallo de Google al cerrar; igual cerramos sesión Supabase.
    }
    await _client.auth.signOut();
  }
}
