import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/di/providers.dart';
import '../../../core/formatters/distance_format.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/formatters/place_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/prefs/feed_layout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/widgets/site_cover.dart';
import '../../../core/widgets/site_origin_tags.dart';
import '../../../core/widgets/visibility_badge.dart';
import '../../saves/data/save_models.dart';
import '../../saves/presentation/favorite_heart_button.dart';
import '../../saves/presentation/site_look_cover.dart';
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
    addressLine: save.addressLine,
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
                      SizedBox(width: 4),
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
            SizedBox(width: 8),
          ],
          if (actionLabel != null && onAction != null)
            InkWell(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Icon(
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
    if (n.isEmpty) return SizedBox.shrink();
    final label = switch (n) {
      'instagram' => 'IG',
      'tiktok' => 'TK',
      'facebook' => 'FB',
      'google_maps' || 'maps' => 'GM',
      _ => n.length >= 2 ? n.substring(0, 2).toUpperCase() : n.toUpperCase(),
    };
    final color = switch (n) {
      'instagram' => AppColors.badgeInstagram,
      'tiktok' => AppColors.badgeTikTok,
      'facebook' => AppColors.badgeFacebook,
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
        style: TextStyle(
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

/// Carrusel de guardados: borde/franja de visibilidad + origen + lugar.
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
    final vis = save.isPublic ? AppColors.success : AppColors.purple;
    return SizedBox(
      width: 152,
      child: Material(
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
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SiteLookCover(
                      siteId: save.siteId,
                      categoryNames: save.categoryNames,
                      coverStoragePath: save.coverStoragePath,
                    ),
                    const SiteCoverScrim(),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: VisibilityStripe(isPublic: save.isPublic),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        children: [
                          HomeSourceBadge(network: save.sourceNetwork),
                          if (save.isIncomplete) ...[
                            if (save.sourceNetwork != null &&
                                save.sourceNetwork!.isNotEmpty)
                              SizedBox(width: 4),
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
                                style: TextStyle(
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
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SiteCardOriginRow(
                        isPublic: save.isPublic,
                        isOwn: true,
                        isLinked: save.isPossibleDuplicate,
                        isCatalog: save.isCatalogSite,
                      ),
                      SizedBox(height: 4),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: SiteCardPlaceTexts(
                            name: save.siteName,
                            department: save.department,
                            city: save.city,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nombre, departamento-municipio y dirección. Scroll si no cabe.
class SiteCardPlaceTexts extends StatelessWidget {
  const SiteCardPlaceTexts({
    super.key,
    required this.name,
    this.department,
    this.city,
    this.addressLine,
    this.nameSize = 12,
  });

  final String name;
  final String? department;
  final String? city;
  final String? addressLine;
  final double nameSize;

  @override
  Widget build(BuildContext context) {
    final place = formatDeptCity(department, city);
    final address = (addressLine ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: nameSize,
            fontWeight: FontWeight.w800,
            color: AppColors.foreground,
            height: 1.25,
          ),
        ),
        if (place.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            place,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.mutedDark,
              height: 1.25,
            ),
          ),
        ],
        if (address.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.muted,
              height: 1.25,
            ),
          ),
        ],
      ],
    );
  }
}

/// Grilla: franja + borde de visibilidad, foto o ilustración padre.
/// Portada [Expanded] con BoxFit.cover (sin forzar proporción); textos compactos.
class HomePopularCard extends ConsumerWidget {
  const HomePopularCard({
    super.key,
    required this.hit,
    required this.onTap,
    this.photoHeight = 100,
    this.showPlaceOnCover = true,
  });

  final SearchHit hit;
  final VoidCallback onTap;
  /// Ignorado: la portada rellena el espacio libre de la celda.
  final double photoHeight;
  final bool showPlaceOnCover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    final unit = ref.watch(preferredDistanceUnitProvider);
    final price = hit.estimatedPriceAmount;
    final vis = hit.isPublic ? AppColors.success : AppColors.purple;
    final hasMetaRow = hit.distanceKm != null || price != null;
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
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SiteLookCover(
                    siteId: hit.siteId,
                    categoryNames: hit.categoryNames,
                    coverStoragePath: hit.coverStoragePath,
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
                            SizedBox(width: 4),
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
                              style: TextStyle(
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
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SiteCardOriginRow(
                      isPublic: hit.isPublic,
                      isOwn: hit.isOwn,
                      isLinked: hit.isLinked,
                      isCatalog: hit.isCatalog,
                    ),
                    SizedBox(height: 2),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: SiteCardPlaceTexts(
                          name: hit.name,
                          department: hit.department,
                          city: hit.city,
                          addressLine: hit.addressLine,
                        ),
                      ),
                    ),
                    if (hasMetaRow) ...[
                      SizedBox(height: 2),
                      Row(
                        children: [
                          if (hit.distanceKm != null)
                            Text(
                              formatDistanceFromKm(
                                context.l10n,
                                unit,
                                hit.distanceKm!,
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.mutedDark,
                              ),
                            ),
                          Spacer(),
                          if (price != null)
                            Text(
                              formatMoney(
                                price,
                                currencyCode: hit.currencyCode,
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
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
    ref.watchAppThemeMode();
    final unit = ref.watch(preferredDistanceUnitProvider);
    final price = hit.estimatedPriceAmount;
    final vis = hit.isPublic ? AppColors.success : AppColors.purple;

    // Altura = presupuesto de contenido ([SiteCardListMetrics]); miniatura ≈ 98%.
    const rowH = SiteCardListMetrics.rowHeight;
    const thumbPad = SiteCardListMetrics.thumbPad;
    const thumb = SiteCardListMetrics.thumbSize;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: vis.withValues(alpha: 0.55)),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: rowH,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VisibilityStripe(isPublic: hit.isPublic),
                Padding(
                  padding: const EdgeInsets.only(top: thumbPad, bottom: thumbPad),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(8),
                    ),
                    child: SizedBox(
                      width: thumb,
                      height: thumb,
                      child: SiteLookCover(
                        siteId: hit.siteId,
                        categoryNames: hit.categoryNames,
                        coverStoragePath: hit.coverStoragePath,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SiteCardOriginRow(
                          isPublic: hit.isPublic,
                          isOwn: hit.isOwn,
                          isLinked: hit.isLinked,
                          isCatalog: hit.isCatalog,
                          trailing: FavoriteHeartButton(
                            siteId: hit.siteId,
                            style: FavoriteHeartStyle.icon,
                          ),
                        ),
                        SizedBox(height: 2),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: SiteCardPlaceTexts(
                              name: hit.name,
                              department: hit.department,
                              city: hit.city,
                              addressLine: hit.addressLine,
                              nameSize: 12,
                            ),
                          ),
                        ),
                        if (hit.distanceKm != null || price != null)
                          Row(
                            children: [
                              if (hit.distanceKm != null)
                                Text(
                                  formatDistanceFromKm(
                                    context.l10n,
                                    unit,
                                    hit.distanceKm!,
                                  ),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.mutedDark,
                                  ),
                                ),
                              Spacer(),
                              if (price != null)
                                Text(
                                  formatMoney(
                                    price,
                                    currencyCode: hit.currencyCode,
                                  ),
                                  style: TextStyle(
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
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.mutedDark,
                    ),
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
        side: BorderSide(color: AppColors.border),
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
              SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
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
  });

  final List<SearchHit> hits;
  final FeedLayout layout;
  final void Function(SearchHit hit) onTap;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = layout.childAspectRatioForWidth(constraints.maxWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hits.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: layout.crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: ratio,
          ),
          itemBuilder: (context, i) {
            final hit = hits[i];
            return HomePopularCard(
              hit: hit,
              onTap: () => onTap(hit),
              showPlaceOnCover: layout != FeedLayout.grid4,
            );
          },
        );
      },
    );
  }
}
