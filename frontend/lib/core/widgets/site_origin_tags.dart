import 'package:flutter/material.dart';

import '../l10n/context_l10n.dart';
import '../testing/widget_keys.dart';
import '../theme/app_theme.dart';
import 'visibility_badge.dart';

/// Tuyo / Tarjeta / Catálogo / Público / Vinculado — etiquetas distintas de la franja de color.
///
/// «Público» aquí es **origen** (listado comunitario), no el color de visibilidad:
/// se muestra si el sitio es público y no es tuyo ni de catálogo.
/// «Tarjeta» = no es lugar físico.
class SiteOriginTags extends StatelessWidget {
  const SiteOriginTags({
    super.key,
    required this.isOwn,
    required this.isLinked,
    required this.isCatalog,
    this.isPublic = false,
    this.isPhysicalPlace = true,
  });

  final bool isOwn;
  final bool isLinked;
  final bool isCatalog;
  final bool isPublic;
  final bool isPhysicalPlace;

  bool get _showPublicOrigin => isPublic && !isOwn && !isCatalog;
  bool get _showCard => !isPhysicalPlace;

  bool get hasAny =>
      isOwn || isLinked || isCatalog || _showPublicOrigin || _showCard;

  @override
  Widget build(BuildContext context) {
    if (!hasAny) return SizedBox.shrink();
    final l10n = context.l10n;
    return Wrap(
      spacing: 6,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (isOwn)
          Text(
            l10n.labelOwn,
            key: WidgetKeys.siteOriginOwn,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        if (_showCard)
          Text(
            l10n.labelCard,
            key: WidgetKeys.siteOriginCard,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
            ),
          ),
        if (isLinked)
          Text(
            l10n.labelLinked,
            key: WidgetKeys.siteOriginLinked,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
            ),
          ),
        if (isCatalog)
          Text(
            l10n.labelCatalog,
            key: WidgetKeys.siteOriginCatalog,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
            ),
          ),
        if (_showPublicOrigin)
          Text(
            l10n.labelPublic,
            key: WidgetKeys.siteOriginPublic,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            ),
          ),
      ],
    );
  }
}

/// Fila estándar de tarjeta de sitio: icono público/privado + origen.
class SiteCardOriginRow extends StatelessWidget {
  const SiteCardOriginRow({
    super.key,
    required this.isPublic,
    required this.isOwn,
    required this.isLinked,
    required this.isCatalog,
    this.isPhysicalPlace = true,
    this.trailing,
  });

  final bool isPublic;
  final bool isOwn;
  final bool isLinked;
  final bool isCatalog;
  final bool isPhysicalPlace;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final origin = SiteOriginTags(
      isOwn: isOwn,
      isLinked: isLinked,
      isCatalog: isCatalog,
      isPublic: isPublic,
      isPhysicalPlace: isPhysicalPlace,
    );
    return Row(
      children: [
        VisibilityBadge(isPublic: isPublic, compact: true),
        if (origin.hasAny) ...[
          SizedBox(width: 6),
          Expanded(child: origin),
        ] else
          const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
