import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/di/providers.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/prefs/feed_layout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/widgets/site_cover.dart';
import '../../../core/widgets/site_origin_tags.dart';
import '../../../core/widgets/visibility_badge.dart';
import '../../admin/data/admin_models.dart';
import '../../saves/data/save_models.dart';
import '../../saves/presentation/favorite_heart_button.dart';
import '../../search/data/search_models.dart';

String homeSavedAgo(AppLocalizations l10n, DateTime? at) {
  if (at == null) return '';
  final days = DateTime.now().toUtc().difference(at.toUtc()).inDays;
  if (days <= 0) return l10n.homeSavedToday;
  if (days == 1) return l10n.homeSavedYesterday;
  if (days < 14) return l10n.homeSavedDaysAgo(days);
  return l10n.homeSavedWeeksAgo((days / 7).floor().clamp(1, 99));
}

Color homeCategoryTint(String? name) =>
    SiteCoverFamily.resolve(hint: name).accent;

SearchHit hitFromSave(UserSave save) {
  return SearchHit(
    siteId: save.siteId,
    name: save.siteName,
    isOwn: true,
    isPublic: save.isPublic,
    isCatalog: save.isCatalogSite,
    isLinked: save.isPossibleDuplicate,
    city: save.city,
    department: save.department,
    categoryNames: save.categoryNames,
    coverStoragePath: save.coverStoragePath,
    isIncomplete: save.isIncomplete,
    sourceNetwork: save.sourceNetwork,
    updatedAt: save.siteUpdatedAt ?? save.createdAt,
  );
}

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.expanded,
    this.onToggleExpanded,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
  /// Si hay [onToggleExpanded], el título pliega/despliega la sección.
  final bool? expanded;
  final VoidCallback? onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final canToggle = onToggleExpanded != null;
    final isOpen = expanded ?? true;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onToggleExpanded,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    if (canToggle) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isOpen
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 20,
                        color: AppColors.mutedDark,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 8),
          ],
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

/// Carrusel Figma: foto 144×176, visibilidad + nombre, categoría debajo.
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
    final l10n = context.l10n;
    final cat = save.categoryNames.isNotEmpty ? save.categoryNames.first : null;
    return SizedBox(
      width: 144,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SiteCover(
                      categoryHint: cat,
                      seed: save.siteId,
                    ),
                    const SiteCoverScrim(bottomOpacity: 0.75),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        children: [
                          HomeSourceBadge(network: save.sourceNetwork),
                          if (save.isIncomplete) ...[
                            if (save.sourceNetwork != null &&
                                save.sourceNetwork!.isNotEmpty)
                              const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft.withValues(
                                  alpha: 0.22,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.statusDraft,
                                key: WidgetKeys.homeSaveStatus(
                                  save.id,
                                  save.status.name,
                                ),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primarySoft,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavoriteHeartButton(siteId: save.siteId),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            save.isPublic
                                ? Icons.visibility_outlined
                                : Icons.lock_rounded,
                            size: 12,
                            color: save.isPublic
                                ? AppColors.success
                                : AppColors.purple,
                          ),
                          const SizedBox(height: 2),
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

/// Grilla: franja + borde de visibilidad, foto o ilustración padre.
class HomePopularCard extends ConsumerWidget {
  const HomePopularCard({
    super.key,
    required this.hit,
    required this.onTap,
    this.showOriginRow = false,
    this.photoHeight = 100,
    this.showPlaceOnCover = true,
  });

  final SearchHit hit;
  final VoidCallback onTap;
  /// Explorar: visibilidad + Tuyo/Vinculado/Catálogo. Inicio: solo nombre/precio.
  final bool showOriginRow;
  final double photoHeight;
  final bool showPlaceOnCover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final price = hit.estimatedPriceAmount;
    final origin = SiteOriginTags(
      isOwn: hit.isOwn,
      isLinked: hit.isLinked,
      isCatalog: hit.isCatalog,
    );
    final cats = ref.watch(
      categoriesProvider.select((a) => a.valueOrNull ?? const <Category>[]),
    );
    final hint = Category.parentNameEs(cats, hit.categoryNames);
    final path = hit.coverStoragePath?.trim();
    final signed = (path == null || path.isEmpty)
        ? null
        : ref.watch(coverSignedUrlProvider(path)).valueOrNull;
    final vis = hit.isPublic ? AppColors.success : AppColors.purple;
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: vis.withValues(alpha: 0.55)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: photoHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SiteCover(
                    imageUrl: signed,
                    cacheKey: path,
                    categoryHint: hint,
                  ),
                  const SiteCoverScrim(),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: VisibilityStripe(isPublic: hit.isPublic),
                  ),
                  Positioned(
                    top: 6,
                    left: 8,
                    child: Row(
                      children: [
                        HomeSourceBadge(network: hit.sourceNetwork),
                        if (hit.isIncomplete) ...[
                          if (hit.sourceNetwork != null &&
                              hit.sourceNetwork!.isNotEmpty)
                            const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft.withValues(
                                alpha: 0.22,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.statusDraft,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primarySoft,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: FavoriteHeartButton(siteId: hit.siteId),
                  ),
                  if (showPlaceOnCover)
                    Positioned(
                      left: 10,
                      bottom: 6,
                      right: 36,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 9,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hit.city ?? hit.department ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showOriginRow) ...[
                    Row(
                      children: [
                        VisibilityBadge(isPublic: hit.isPublic, compact: true),
                        if (origin.hasAny) ...[
                          const SizedBox(width: 6),
                          Expanded(child: origin),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    hit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (hit.distanceKm != null)
                        Text(
                          '${hit.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.mutedDark,
                          ),
                        ),
                      const Spacer(),
                      if (price != null)
                        Text(
                          formatMoney(price, currencyCode: hit.currencyCode),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
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

/// Fila de Explorar: misma ficha que la grilla, en formato lista.
class HomeSearchListCard extends ConsumerWidget {
  const HomeSearchListCard({
    super.key,
    required this.hit,
    required this.onTap,
  });

  final SearchHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final origin = SiteOriginTags(
      isOwn: hit.isOwn,
      isLinked: hit.isLinked,
      isCatalog: hit.isCatalog,
    );
    final place = [
      if (hit.city != null && hit.city!.isNotEmpty) hit.city!,
      if (hit.department != null && hit.department!.isNotEmpty) hit.department!,
    ].join(' · ');
    final price = hit.estimatedPriceAmount;
    final cats = ref.watch(
      categoriesProvider.select((a) => a.valueOrNull ?? const <Category>[]),
    );
    final hint = Category.parentNameEs(cats, hit.categoryNames);
    final path = hit.coverStoragePath?.trim();
    final signed = (path == null || path.isEmpty)
        ? null
        : ref.watch(coverSignedUrlProvider(path)).valueOrNull;
    final vis = hit.isPublic ? AppColors.success : AppColors.purple;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: vis.withValues(alpha: 0.55)),
        ),
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VisibilityStripe(isPublic: hit.isPublic),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 0, 10),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: SiteCover(
                        imageUrl: signed,
                        cacheKey: path,
                        categoryHint: hint,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            VisibilityBadge(
                              isPublic: hit.isPublic,
                              compact: true,
                            ),
                            if (origin.hasAny) ...[
                              const SizedBox(width: 6),
                              Expanded(child: origin),
                            ],
                            FavoriteHeartButton(
                              siteId: hit.siteId,
                              style: FavoriteHeartStyle.icon,
                            ),
                          ],
                        ),
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
                        if (place.isNotEmpty)
                          Text(
                            place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                            ),
                          ),
                        const Spacer(),
                        Row(
                          children: [
                            if (hit.distanceKm != null)
                              Text(
                                '${hit.distanceKm!.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.mutedDark,
                                ),
                              ),
                            const Spacer(),
                            if (price != null)
                              Text(
                                formatMoney(
                                  price,
                                  currencyCode: hit.currencyCode,
                                ),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.mutedDark,
                  ),
                ),
              ],
            ),
          ),
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

class HomeFeedHits extends StatelessWidget {
  const HomeFeedHits({
    super.key,
    required this.hits,
    required this.layout,
    required this.onTap,
    this.showOriginRow = false,
  });

  final List<SearchHit> hits;
  final FeedLayout layout;
  final void Function(SearchHit hit) onTap;
  final bool showOriginRow;

  @override
  Widget build(BuildContext context) {
    if (layout.isList) {
      return Column(
        children: [
          for (final hit in hits)
            HomeSearchListCard(
              hit: hit,
              onTap: () => onTap(hit),
            ),
        ],
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: hits.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: layout.childAspectRatio(
          showOriginRow: showOriginRow,
        ),
      ),
      itemBuilder: (context, i) {
        final hit = hits[i];
        return HomePopularCard(
          hit: hit,
          onTap: () => onTap(hit),
          showOriginRow: showOriginRow,
          photoHeight: layout.photoHeight(showOriginRow: showOriginRow),
          showPlaceOnCover: layout != FeedLayout.grid4,
        );
      },
    );
  }
}
