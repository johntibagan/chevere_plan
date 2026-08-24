import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/context_l10n.dart';
import '../theme/app_theme.dart';
import 'app_form_card.dart';
import 'tab_screen_header.dart';

/// Pantalla única de “aún no está listo” (ciclo 13). Sin avisos inventados.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  static Future<void> open(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ComingSoonPage(title: title, body: body),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: AppRoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mutedDark.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.build_outlined,
                      size: 34,
                      color: AppColors.mutedDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: AppColors.muted,
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila atenuada que abre [ComingSoonPage]. Un solo patrón para IA / transporte.
class ComingSoonCard extends StatelessWidget {
  const ComingSoonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pageTitle,
    required this.pageBody,
  });

  final String title;
  final String subtitle;
  final String pageTitle;
  final String pageBody;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: AppFormCard(
        onTap: () => ComingSoonPage.open(
          context,
          title: pageTitle,
          body: pageBody,
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.mutedDark.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.build_outlined,
                size: 18,
                color: AppColors.mutedDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.mutedDark,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              context.l10n.comingSoonBadge,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.mutedDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
