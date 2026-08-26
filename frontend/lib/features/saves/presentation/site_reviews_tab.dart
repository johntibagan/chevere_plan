import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/di/providers.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/site_photo_viewer_page.dart';
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
    this.isStaff = false,
    this.staffRoleLabel,
  });

  final String siteId;
  final String siteName;
  final bool siteIsPublic;
  /// Admin/root: privilegios sobre contenido público (no bitácoras ajenas).
  final bool isStaff;
  final String? staffRoleLabel;

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
      var list = await repo.listForSite(widget.siteId);
      // Bitácora privada: solo el autor (tampoco staff).
      if (_uid != null) {
        list = list
            .where((r) => r.isPublic || r.userId == _uid)
            .toList();
      }
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
          style: TextStyle(color: AppColors.foreground),
        ),
        content: Text(
          l10n.reviewDeleteBody,
          style: TextStyle(color: AppColors.muted),
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

  Future<void> _openReviewPhotos(SiteReview review, int initialIndex) async {
    final author = () {
      final n = review.authorName?.trim() ?? '';
      if (n.isNotEmpty) return n;
      if (review.userId == _uid) return context.l10n.reviewAuthorYou;
      return context.l10n.defaultUserDisplayName;
    }();
    final canManage =
        review.userId == _uid || (widget.isStaff && review.isPublic);
    final targetId =
        review.photos[initialIndex.clamp(0, review.photos.length - 1)].id;
    final items = <SitePhotoViewItem>[];
    var start = 0;
    for (final p in review.photos) {
      final u = _urls[p.id];
      if (u == null || u.isEmpty) continue;
      if (p.id == targetId) start = items.length;
      items.add(
        SitePhotoViewItem(
          id: p.id,
          url: u,
          cacheKey: p.storagePath,
          uploaderName: author,
          uploadedAt: p.createdAt ?? review.createdAt,
          canDelete: canManage,
          canSetCover: false,
          isCover: false,
        ),
      );
    }
    if (items.isEmpty || !mounted) return;
    await SitePhotoViewerPage.open(
      context,
      photos: items,
      initialIndex: start,
      onMenu: (item, action) {
        switch (action) {
          case 'delete':
            _deleteReviewPhoto(item);
          case 'report':
            _reportReviewPhoto(item);
        }
      },
    );
  }

  Future<void> _deleteReviewPhoto(SitePhotoViewItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.photoDeleteTitle),
        content: Text(context.l10n.photoDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref
          .read(siteReviewsRepositoryProvider)
          .deleteReviewPhoto(item.id);
      if (!mounted) return;
      AppToast.show(context, context.l10n.photoDeleted);
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e, logContext: 'review_photo_delete');
    }
  }

  Future<void> _reportReviewPhoto(SitePhotoViewItem item) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.photoReportTitle),
        content: TextField(
          controller: reasonCtrl,
          decoration: InputDecoration(
            labelText: context.l10n.photoReportReason,
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.photoReportSend),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(moderationRepositoryProvider).reportPhoto(
            photoId: item.id,
            reason: reasonCtrl.text,
          );
      if (!mounted) return;
      AppToast.show(context, context.l10n.photoReportSent);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e, logContext: 'review_photo_report');
    }
  }

  Future<void> _reportReview(SiteReview review) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.reviewReportTitle),
        content: TextField(
          controller: reasonCtrl,
          decoration: InputDecoration(
            labelText: context.l10n.photoReportReason,
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.photoReportSend),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(moderationRepositoryProvider).reportReview(
            reviewId: review.id,
            reason: reasonCtrl.text,
          );
      if (!mounted) return;
      AppToast.show(context, context.l10n.reviewReportSent);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e, logContext: 'review_report');
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
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    final visible = _visible;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: [
            if (widget.isStaff) ...[
              _StaffPrivilegesBanner(
                message: l10n.staffModeBanner(
                  widget.staffRoleLabel ?? l10n.staffRoleAdmin,
                ),
              ),
              SizedBox(height: 12),
            ],
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
                        Icon(Icons.sort, size: 20, color: AppColors.muted),
                        SizedBox(width: 4),
                        Text(
                          _sortLabel(_sort),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
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
                  SizedBox(width: 6),
                  for (var star = 5; star >= 1; star--) ...[
                    FilterChip(
                      label: Text('$star★'),
                      selected: _starFilter == star,
                      onSelected: (sel) => setState(() {
                        _starFilter = sel ? star : null;
                      }),
                    ),
                    SizedBox(width: 6),
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
            SizedBox(height: 16),
            if (visible.isEmpty)
              Text(
                _reviews.isEmpty ? l10n.reviewEmpty : l10n.reviewFilterEmpty,
                style: TextStyle(color: AppColors.muted),
              )
            else
              for (final r in visible) ...[
                _ReviewCard(
                  review: r,
                  photoUrls: _urls,
                  isMine: r.userId == _uid,
                  canManage:
                      r.userId == _uid || (widget.isStaff && r.isPublic),
                  canReport: _uid != null &&
                      r.userId != _uid &&
                      r.isPublic,
                  onEdit: () => _openEditor(review: r),
                  onDelete: () => _confirmDelete(r),
                  onReport: () => _reportReview(r),
                  onOpenPhoto: (index) => _openReviewPhotos(r, index),
                ),
                SizedBox(height: 12),
              ],
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'site_review_fab_${widget.siteId}',
            tooltip: l10n.reviewWrite,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            onPressed: () => _openEditor(),
            child: Icon(Icons.add_comment, size: 28),
          ),
        ),
      ],
    );
  }
}

class _StaffPrivilegesBanner extends StatelessWidget {
  const _StaffPrivilegesBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.photoUrls,
    required this.isMine,
    required this.canManage,
    required this.canReport,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
    required this.onOpenPhoto,
  });

  final SiteReview review;
  final Map<String, String> photoUrls;
  final bool isMine;
  final bool canManage;
  final bool canReport;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final ValueChanged<int> onOpenPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = () {
      final n = review.authorName?.trim() ?? '';
      if (n.isNotEmpty) return n;
      return isMine ? l10n.reviewAuthorYou : l10n.defaultUserDisplayName;
    }();
    final accent =
        review.isPublic ? AppColors.success : AppColors.purple;
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accent.withValues(alpha: 0.4)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                                : ColoredBox(
                                    color: AppColors.surfaceElevated,
                                    child: Icon(
                                      Icons.person,
                                      size: 18,
                                      color: AppColors.muted,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 1; i <= 5; i++)
                              Icon(
                                i <= review.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                        if (canManage || canReport)
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: AppColors.muted,
                            ),
                            onSelected: (v) {
                              if (v == 'edit') onEdit();
                              if (v == 'delete') onDelete();
                              if (v == 'report') onReport();
                            },
                            itemBuilder: (context) => [
                              if (canManage)
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text(l10n.reviewEditMine),
                                ),
                              if (canManage)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(l10n.reviewDelete),
                                ),
                              if (canReport)
                                PopupMenuItem(
                                  value: 'report',
                                  child: Text(l10n.actionReport),
                                ),
                            ],
                          ),
                      ],
                    ),
                    if (review.body.trim().isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        review.body,
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                    if (review.photos.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (var i = 0; i < review.photos.length; i++)
                            if (photoUrls[review.photos[i].id] != null)
                              GestureDetector(
                                onTap: () => onOpenPhoto(i),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: AppNetworkImage(
                                    url: photoUrls[review.photos[i].id]!,
                                    width: 64,
                                    height: 64,
                                    cacheKey: review.photos[i].id,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ],
                    SizedBox(height: 6),
                    Text(
                      formatDateTimeShort(review.createdAt) +
                          (review.updatedAt
                                      .difference(review.createdAt)
                                      .inSeconds
                                      .abs() >
                                  2
                              ? l10n.reviewEditedOn(
                                  formatDateTimeShort(review.updatedAt),
                                )
                              : ''),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedDark,
                      ),
                    ),
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
