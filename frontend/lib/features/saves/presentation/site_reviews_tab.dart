import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/di/providers.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/visibility_badge.dart';
import '../data/site_review_models.dart';
import 'site_review_editor_page.dart';

class SiteReviewsTab extends ConsumerStatefulWidget {
  const SiteReviewsTab({
    super.key,
    required this.siteId,
    required this.siteName,
    this.siteIsPublic = true,
  });

  final String siteId;
  final String siteName;
  final bool siteIsPublic;

  @override
  ConsumerState<SiteReviewsTab> createState() => _SiteReviewsTabState();
}

class _SiteReviewsTabState extends ConsumerState<SiteReviewsTab> {
  bool _loading = true;
  SiteRatingSummary _summary =
      const SiteRatingSummary(avgRating: 0, reviewCount: 0);
  List<SiteReview> _reviews = const [];
  final Map<String, String> _urls = {};
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(siteReviewsRepositoryProvider);
      final summary = await repo.ratingSummary(widget.siteId);
      final list = await repo.listForSite(widget.siteId);
      final urls = <String, String>{};
      for (final r in list) {
        for (final p in r.photos) {
          final u = await repo.signedUrl(p.storagePath);
          if (u != null) urls[p.id] = u;
        }
      }
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _reviews = list;
        _urls
          ..clear()
          ..addAll(urls);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.error(context, e, logContext: 'site_reviews_load');
    }
  }

  Future<void> _openEditor({SiteReview? mine}) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SiteReviewEditorPage(
          siteId: widget.siteId,
          siteName: widget.siteName,
          initialReview: mine,
          siteIsPublic: widget.siteIsPublic,
        ),
      ),
    );
    if (ok == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final SiteReview? mine = () {
      if (_uid == null) return null;
      for (final r in _reviews) {
        if (r.userId == _uid) return r;
      }
      return null;
    }();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (_summary.reviewCount > 0)
          Text(
            l10n.reviewAvg(
              _summary.avgRating.toStringAsFixed(1),
              _summary.reviewCount,
            ),
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.foreground,
            ),
          ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () => _openEditor(mine: mine),
          child: Text(mine == null ? l10n.reviewWrite : l10n.reviewEditMine),
        ),
        const SizedBox(height: 16),
        if (_reviews.isEmpty)
          Text(l10n.reviewEmpty, style: const TextStyle(color: AppColors.muted))
        else
          for (final r in _reviews) ...[
            _ReviewCard(
              review: r,
              photoUrls: _urls,
              isMine: r.userId == _uid,
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.photoUrls,
    required this.isMine,
  });

  final SiteReview review;
  final Map<String, String> photoUrls;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final name = review.authorName?.trim().isNotEmpty == true
        ? review.authorName!
        : 'Usuario';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: (review.authorAvatarUrl ?? '').isNotEmpty
                      ? AppNetworkImage(
                          url: review.authorAvatarUrl!,
                          width: 32,
                          height: 32,
                          cacheKey: 'avatar:${review.userId}',
                        )
                      : const ColoredBox(
                          color: AppColors.surfaceElevated,
                          child: Icon(Icons.person, size: 18, color: AppColors.muted),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Tooltip(
                        message: name,
                        triggerMode: TooltipTriggerMode.tap,
                        child: Text(
                          isMine ? 'Tú' : 'Usuario',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                    ),
                    if (isMine && !review.isPublic) ...[
                      const SizedBox(width: 6),
                      VisibilityBadge(isPublic: false, compact: true),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= review.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ],
          ),
          if (review.body.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.body, style: const TextStyle(color: AppColors.muted)),
          ],
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                for (final p in review.photos)
                  if (photoUrls[p.id] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AppNetworkImage(
                        url: photoUrls[p.id]!,
                        width: 64,
                        height: 64,
                        cacheKey: p.id,
                      ),
                    ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Text(
            '${formatDateTimeShort(review.createdAt)}'
            '${review.updatedAt.difference(review.createdAt).inSeconds.abs() > 2 ? ' · editado ${formatDateTimeShort(review.updatedAt)}' : ''}',
            style: const TextStyle(fontSize: 11, color: AppColors.mutedDark),
          ),
        ],
      ),
    );
  }
}
