import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../legal/legal_texts.dart';
import '../../legal/presentation/legal_document_page.dart';
import '../data/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  bool _acceptedLegal = false;
  String? _error;

  static const _prefsKey = 'legal_accepted_${LegalTexts.tosVersion}';

  @override
  void initState() {
    super.initState();
    _loadAccepted();
  }

  Future<void> _loadAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _acceptedLegal = prefs.getBool(_prefsKey) ?? false);
  }

  Future<void> _persistAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  Future<void> _onGooglePressed() async {
    if (!_acceptedLegal) {
      setState(() {
        _error =
            'Debes aceptar los Términos de Uso y el Aviso de privacidad para continuar.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _persistAccepted();
      await widget.authRepository.signInWithGoogle();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = userFacingError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    size: 36,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Chevere Plan',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Guarda lugares y arma planes\nen Colombia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(flex: 3),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptedLegal,
                    onChanged: _loading
                        ? null
                        : (v) => setState(() => _acceptedLegal = v ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Acepto los documentos legales del MVP.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                          Wrap(
                            spacing: 4,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    LegalDocumentPage.openTerms(context),
                                child: const Text('Términos de Uso'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    LegalDocumentPage.openPrivacy(context),
                                child: const Text('Aviso de privacidad'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _loading ? null : _onGooglePressed,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.login),
                label: Text(
                  _loading ? 'Conectando…' : 'Continuar con Google',
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
