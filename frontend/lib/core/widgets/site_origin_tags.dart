import 'package:flutter/material.dart';

import '../l10n/context_l10n.dart';
import '../testing/widget_keys.dart';
import '../theme/app_theme.dart';

/// Tuyo / Vinculado / Catálogo — etiquetas distintas de la visibilidad (color).
class SiteOriginTags extends StatelessWidget {
  const SiteOriginTags({
    super.key,
    required this.isOwn,
    required this.isLinked,
    required this.isCatalog,
  });

  final bool isOwn;
  final bool isLinked;
  final bool isCatalog;

  bool get hasAny => isOwn || isLinked || isCatalog;

  @override
  Widget build(BuildContext context) {
    if (!hasAny) return const SizedBox.shrink();
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
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        if (isLinked)
          Text(
            l10n.labelLinked,
            key: WidgetKeys.siteOriginLinked,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
            ),
          ),
        if (isCatalog)
          Text(
            l10n.labelCatalog,
            key: WidgetKeys.siteOriginCatalog,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
            ),
          ),
      ],
    );
  }
}
