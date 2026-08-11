import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/user_facing_error.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Chevere Plan',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Guarda lugares y arma planes.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (_error != null) ...[
                Material(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
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
                          Text(
                            'Acepto los documentos legales del MVP.',
                            style: theme.textTheme.bodySmall,
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
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loading ? null : _onGooglePressed,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(
                  _loading ? 'Conectando…' : 'Continuar con Google',
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
