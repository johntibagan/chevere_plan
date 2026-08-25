import 'package:flutter/material.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_network_image.dart';
import '../data/social_link_models.dart';

/// Tarjeta de preview de enlace (estilo “pegar en WhatsApp”).
class SocialLinkPreviewCard extends StatelessWidget {
  const SocialLinkPreviewCard({
    super.key,
    required this.draft,
    this.onRemove,
    this.onTap,
    this.loading = false,
  });

  final SocialLinkDraft draft;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = draft.title?.trim().isNotEmpty == true
        ? draft.title!
        : (draft.network ?? Uri.tryParse(draft.url)?.host ?? l10n.saveLinkFallback);
    final desc = draft.description?.trim();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loading)
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (draft.imageUrl != null && draft.imageUrl!.isNotEmpty)
                AppNetworkImage(
                  url: draft.imageUrl!,
                  cacheKey: 'og:${draft.url}',
                  width: 64,
                  height: 64,
                  borderRadius: BorderRadius.circular(8),
                )
              else
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.link, color: AppColors.muted),
                ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                      ),
                    ),
                    if (desc != null && desc.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                    SizedBox(height: 4),
                    Text(
                      draft.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.close, size: 18),
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
