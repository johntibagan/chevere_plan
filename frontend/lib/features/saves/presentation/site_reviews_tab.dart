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

enum _ReviewSort {
  newest,
  oldest,
  ratingHigh,
  ratingLow,
}

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

  /// null = todas las estrellas.
  int? _starFilter;
  bool _mineOnly = false;
  _ReviewSort _sort = _ReviewSort.newest;

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

  List<SiteReview> get _visible {
    var list = List<SiteReview>.from(_reviews);
    if (_starFilter != null) {
      list = list.where((r) => r.rating == _starFilter).toList();
    }
    if (_mineOnly && _uid != null) {
      list = list.where((r) => r.userId == _uid).toList();
    }
    switch (_sort) {
      case _ReviewSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _ReviewSort.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _ReviewSort.ratingHigh:
        list.sort((a, b) {
          final c = b.rating.compareTo(a.rating);
          return c != 0 ? c : b.createdAt.compareTo(a.createdAt);
        });
      case _ReviewSort.ratingLow:
        list.sort((a, b) {
          final c = a.rating.compareTo(b.rating);
          return c != 0 ? c : b.createdAt.compareTo(a.createdAt);
        });
    }
    return list;
  }

  Future<void> _openEditor({SiteReview? review}) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SiteReviewEditorPage(
          siteId: widget.siteId,
          siteName: widget.siteName,
          initialReview: review,
          siteIsPublic: widget.siteIsPublic,
        ),
      ),
    );
    if (ok == true) await _load();
  }

  Future<void> _confirmDelete(SiteReview review) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.reviewDeleteTitle,
          style: const TextStyle(color: AppColors.foreground),
        ),
        content: Text(
          l10n.reviewDeleteBody,
          style: const TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.reviewDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(siteReviewsRepositoryProvider).deleteMyReview(review.id);
      if (!mounted) return;
      AppToast.show(context, l10n.reviewDeleted);
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e, logContext: 'review_delete');
    }
  }

  String _sortLabel(_ReviewSort sort) {
    final l10n = context.l10n;
    switch (sort) {
      case _ReviewSort.newest:
        return l10n.reviewSortNewest;
      case _ReviewSort.oldest:
        return l10n.reviewSortOldest;
      case _ReviewSort.ratingHigh:
        return l10n.reviewSortRatingHigh;
      case _ReviewSort.ratingLow:
        return l10n.reviewSortRatingLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final visible = _visible;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _summary.reviewCount > 0
                    ? l10n.reviewAvg(
                        _summary.avgRating.toStringAsFixed(1),
                        _summary.reviewCount,
                      )
                    : l10n.reviewEmpty,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.foreground,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.reviewWrite,
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_comment_outlined),
              color: AppColors.primary,
            ),
            PopupMenuButton<_ReviewSort>(
              tooltip: l10n.reviewSortLabel,
              initialValue: _sort,
              onSelected: (v) => setState(() => _sort = v),
              itemBuilder: (context) => [
                for (final s in _ReviewSort.values)
                  PopupMenuItem(
                    value: s,
                    child: Text(_sortLabel(s)),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort, size: 20, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _sortLabel(_sort),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: Text(l10n.reviewFilterAll),
                selected: _starFilter == null && !_mineOnly,
                onSelected: (_) => setState(() {
                  _starFilter = null;
                  _mineOnly = false;
                }),
              ),
              const SizedBox(width: 6),
              for (var star = 5; star >= 1; star--) ...[
                FilterChip(
                  label: Text('$star★'),
                  selected: _starFilter == star,
                  onSelected: (sel) => setState(() {
                    _starFilter = sel ? star : null;
                  }),
                ),
                const SizedBox(width: 6),
              ],
              if (_uid != null)
                FilterChip(
                  label: Text(l10n.reviewFilterMine),
                  selected: _mineOnly,
                  onSelected: (sel) => setState(() => _mineOnly = sel),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          Text(
            _reviews.isEmpty ? l10n.reviewEmpty : l10n.reviewFilterEmpty,
            style: const TextStyle(color: AppColors.muted),
          )
        else
          for (final r in visible) ...[
            _ReviewCard(
              review: r,
              photoUrls: _urls,
              isMine: r.userId == _uid,
              onEdit: () => _openEditor(review: r),
              onDelete: () => _confirmDelete(r),
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
    required this.onEdit,
    required this.onDelete,
  });

  final SiteReview review;
  final Map<String, String> photoUrls;
  final bool isMine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: AppColors.muted,
                          ),
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
                      const VisibilityBadge(isPublic: false, compact: true),
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
              if (isMine)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.muted),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(l10n.reviewEditMine),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(l10n.reviewDelete),
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
