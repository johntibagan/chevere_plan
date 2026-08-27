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
///
/// Siempre **una sola fila** (sin Wrap a 2 líneas): el presupuesto de altura de
/// las cards de lista/grilla no tolera un segundo renglón (overflow amarillo).
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

  static TextStyle _style(Color color) => TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.1,
      );

  @override
  Widget build(BuildContext context) {
    if (!hasAny) return SizedBox.shrink();
    final l10n = context.l10n;
    final tags = <Widget>[
      if (isOwn)
        Text(
          l10n.labelOwn,
          key: WidgetKeys.siteOriginOwn,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _style(AppColors.primary),
        ),
      if (_showCard)
        Text(
          l10n.labelCard,
          key: WidgetKeys.siteOriginCard,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _style(AppColors.muted),
        ),
      if (isLinked)
        Text(
          l10n.labelLinked,
          key: WidgetKeys.siteOriginLinked,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _style(AppColors.muted),
        ),
      if (isCatalog)
        Text(
          l10n.labelCatalog,
          key: WidgetKeys.siteOriginCatalog,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _style(AppColors.muted),
        ),
      if (_showPublicOrigin)
        Text(
          l10n.labelPublic,
          key: WidgetKeys.siteOriginPublic,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _style(AppColors.success),
        ),
    ];
    return Row(
      children: [
        for (var i = 0; i < tags.length; i++) ...[
          if (i > 0) SizedBox(width: 4),
          Flexible(child: tags[i]),
        ],
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        VisibilityBadge(isPublic: isPublic, compact: true),
        if (origin.hasAny) ...[
          SizedBox(width: 4),
          Expanded(child: origin),
        ] else
          const Spacer(),
        ?trailing,
      ],
    );
  }
}
