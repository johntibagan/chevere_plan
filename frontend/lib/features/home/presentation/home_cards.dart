import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../saves/data/save_models.dart';
import '../../search/data/search_models.dart';

String homeSavedAgo(AppLocalizations l10n, DateTime? at) {
  if (at == null) return '';
  final days = DateTime.now().toUtc().difference(at.toUtc()).inDays;
  if (days <= 0) return l10n.homeSavedToday;
  if (days == 1) return l10n.homeSavedYesterday;
  if (days < 14) return l10n.homeSavedDaysAgo(days);
  return l10n.homeSavedWeeksAgo((days / 7).floor().clamp(1, 99));
}

Color homeCategoryTint(String? name) {
  final n = (name ?? '').toLowerCase();
  if (n.contains('gastro') || n.contains('comida') || n.contains('bar')) {
    return AppColors.catGastro;
  }
  if (n.contains('aloj') || n.contains('hotel')) return AppColors.catAloj;
  if (n.contains('natur') || n.contains('parque')) return AppColors.catNat;
  if (n.contains('cult') || n.contains('museo')) return AppColors.catCult;
  if (n.contains('entreten') || n.contains('música') || n.contains('musica')) {
    return AppColors.catEnt;
  }
  if (n.contains('compra')) return AppColors.catComp;
  if (n.contains('evento')) return AppColors.catEven;
  if (n.contains('serv')) return AppColors.catServ;
  if (n.contains('deporte')) return AppColors.catDeporte;
  return AppColors.primary;
}

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.foreground,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            InkWell(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class HomeSourceBadge extends StatelessWidget {
  const HomeSourceBadge({super.key, required this.network});

  final String? network;

  @override
  Widget build(BuildContext context) {
    final n = (network ?? '').toLowerCase();
    if (n.isEmpty) return const SizedBox.shrink();
    final label = switch (n) {
      'instagram' => 'IG',
      'tiktok' => 'TK',
      'facebook' => 'FB',
      'google_maps' || 'maps' => 'GM',
      _ => n.length >= 2 ? n.substring(0, 2).toUpperCase() : n.toUpperCase(),
    };
    final color = switch (n) {
      'instagram' => const Color(0xFFE1306C),
      'tiktok' => const Color(0xFF69C9D0),
      'facebook' => const Color(0xFF1877F2),
      _ => AppColors.mutedDark,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: AppColors.onImage,
        ),
      ),
    );
  }
}

class HomeCategoryChip extends StatelessWidget {
  const HomeCategoryChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = homeCategoryTint(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Carrusel Figma: foto 144×176, nombre encima, categoría debajo.
class HomeRecentRailCard extends StatelessWidget {
  const HomeRecentRailCard({
    super.key,
    required this.save,
    required this.onTap,
  });

  final UserSave save;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cat = save.categoryNames.isNotEmpty ? save.categoryNames.first : null;
    return SizedBox(
      width: 144,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: AppColors.surfaceElevated),
                    const Center(
                      child: Icon(
                        Icons.place_outlined,
                        color: AppColors.mutedDark,
                        size: 32,
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xCC000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: HomeSourceBadge(network: save.sourceNetwork),
                    ),
                    if (!save.isPublic)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0x99000000),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.lock_rounded,
                              size: 10,
                              color: AppColors.purple,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            save.siteName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onImage,
                            ),
                          ),
                          if (save.city != null && save.city!.isNotEmpty)
                            Text(
                              save.city!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.onImageMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (cat != null) HomeCategoryChip(label: cat),
          ],
        ),
      ),
    );
  }
}

/// Grilla Figma 2 columnas: foto 144px, nombre, barrio/ciudad, categoría y fecha.
class HomePopularCard extends StatelessWidget {
  const HomePopularCard({
    super.key,
    required this.hit,
    required this.onTap,
  });

  final SearchHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final price = hit.estimatedPriceAmount;
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: (hit.isPublic ? AppColors.success : AppColors.purple)
              .withValues(alpha: 0.35),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 144,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: AppColors.surfaceElevated),
                  const Center(
                    child: Icon(
                      Icons.landscape_outlined,
                      color: AppColors.mutedDark,
                      size: 36,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xB3000000)],
                      ),
                    ),
                  ),
                  if (!hit.isPublic)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: Icon(
                        Icons.lock_rounded,
                        size: 12,
                        color: AppColors.purple,
                      ),
                    ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 10,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hit.city ?? hit.department ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onImage,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (price != null)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Text(
                        formatMoney(price, currencyCode: hit.currencyCode),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.foreground,
                    ),
                  ),
                  if (hit.department != null && hit.department!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        hit.department!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (hit.distanceKm != null)
                        Text(
                          '${hit.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.mutedDark,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        homeSavedAgo(l10n, hit.updatedAt),
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.mutedDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeQuickAction extends StatelessWidget {
  const HomeQuickAction({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
