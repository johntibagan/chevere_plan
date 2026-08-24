import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../legal/legal_texts.dart';
import '../../legal/presentation/legal_document_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _loading = false;
  bool _acceptedLegal = false;
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  static const _prefsKey = 'legal_accepted_${LegalTexts.tosVersion}';

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () => LegalDocumentPage.openTerms(context);
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => LegalDocumentPage.openPrivacy(context);
    _loadAccepted();
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
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
    final l10n = context.l10n;
    if (!_acceptedLegal) {
      AppToast.show(context, l10n.loginMustAcceptLegal, error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await _persistAccepted();
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (error) {
      if (!mounted) return;
      AppToast.error(context, error, logContext: 'login');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canSignIn = _acceptedLegal && !_loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 34,
                  color: AppColors.background,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.appTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(flex: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegalCheck(
                    value: _acceptedLegal,
                    enabled: !_loading,
                    onChanged: (v) => setState(() => _acceptedLegal = v),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: AppColors.muted,
                        ),
                        children: [
                          TextSpan(text: '${l10n.loginAcceptLegal} '),
                          TextSpan(
                            text: l10n.loginTerms,
                            style: const TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: _termsTap,
                          ),
                          const TextSpan(text: ' y el '),
                          TextSpan(
                            text: l10n.loginPrivacy,
                            style: const TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: _privacyTap,
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Material(
                  color: canSignIn ? Colors.white : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    key: const Key('login_google_button'),
                    onTap: canSignIn ? _onGooglePressed : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Opacity(
                      opacity: _acceptedLegal ? 1 : 0.5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_loading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else ...[
                            const _GoogleMark(),
                            const SizedBox(width: 12),
                            Text(
                              l10n.loginContinueGoogle,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: canSignIn
                                    ? const Color(0xFF1A1A1A)
                                    : AppColors.mutedDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
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

class _LegalCheck extends StatelessWidget {
  const _LegalCheck({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Material(
        color: value ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: enabled ? () => onChanged(!value) : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.background,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    p.color = const Color(0xFF4285F4);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.5), 3.2, p);
    p.color = const Color(0xFF34A853);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.78), 3.2, p);
    p.color = const Color(0xFFFBBC05);
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.5), 3.2, p);
    p.color = const Color(0xFFEA4335);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.22), 3.2, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
