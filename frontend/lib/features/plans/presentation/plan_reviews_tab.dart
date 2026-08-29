import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/di/providers.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_floating_action_layout.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/site_photo_viewer_page.dart';
import '../data/plan_review_models.dart';
import 'plan_review_editor_page.dart';

enum _PlanReviewSort { newest, oldest }

class PlanReviewsTab extends ConsumerStatefulWidget {
  const PlanReviewsTab({
    super.key,
    required this.planId,
    required this.planTitle,
    this.bottomPadding = AppFloatingActionLayout.fixedBottomBarClearance,
    this.onReviewsChanged,
  });

  final String planId;
  final String planTitle;
  final double bottomPadding;
  final VoidCallback? onReviewsChanged;

  @override
  ConsumerState<PlanReviewsTab> createState() => _PlanReviewsTabState();
}

class _PlanReviewsTabState extends ConsumerState<PlanReviewsTab> {
  bool _loading = true;
  List<PlanReview> _reviews = const [];
  final Map<String, String> _urls = {};
  String? _uid;
  _PlanReviewSort _sort = _PlanReviewSort.newest;

  @override
  void initState() {
    super.initState();
    _uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(planReviewsRepositoryProvider);
      final list = await repo.listForPlan(widget.planId);
      final urls = <String, String>{};
      for (final r in list) {
        for (final p in r.photos) {
          final u = await repo.signedUrl(p.storagePath);
          if (u != null) urls[p.id] = u;
        }
      }
      if (!mounted) return;
      setState(() {
        _reviews = list;
        _urls
          ..clear()
          ..addAll(urls);
        _loading = false;
      });
      widget.onReviewsChanged?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.error(context, e, logContext: 'plan_reviews_load');
    }
  }

  List<PlanReview> get _visible {
    final list = List<PlanReview>.from(_reviews);
    switch (_sort) {
      case _PlanReviewSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _PlanReviewSort.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return list;
  }

  Future<void> _openEditor({PlanReview? review}) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PlanReviewEditorPage(
          planId: widget.planId,
          planTitle: widget.planTitle,
          initialReview: review,
        ),
      ),
    );
    if (ok == true) await _load();
  }

  Future<void> _confirmDelete(PlanReview review) async {
    final l10n = context.l10n;
    final ok = await showAppConfirmDialog<bool>(
      context: context,
      icon: Icons.delete_outline,
      tone: AppConfirmTone.danger,
      title: l10n.reviewDeleteTitle,
      body: l10n.reviewDeleteBody,
      actions: [
        AppConfirmAction(label: l10n.actionCancel, value: false),
        AppConfirmAction(
          label: l10n.reviewDelete,
          value: true,
          isPrimary: true,
          isDestructive: true,
        ),
      ],
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(planReviewsRepositoryProvider).deleteMyReview(review.id);
      if (!mounted) return;
      AppToast.show(context, l10n.reviewDeleted);
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e, logContext: 'plan_review_delete');
    }
  }

  Future<void> _openReviewPhotos(PlanReview review, int initialIndex) async {
    final l10n = context.l10n;
    final isMine = review.userId == _uid;
    final author = () {
      final n = review.authorName?.trim() ?? '';
      if (n.isNotEmpty) return n;
      return isMine ? l10n.reviewAuthorYou : l10n.defaultUserDisplayName;
    }();
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
          canDelete: isMine,
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
        if (action == 'delete') _deleteReviewPhoto(item);
      },
    );
  }

  Future<void> _deleteReviewPhoto(SitePhotoViewItem item) async {
    final l10n = context.l10n;
    final ok = await showAppConfirmDialog<bool>(
      context: context,
      icon: Icons.delete_outline,
      tone: AppConfirmTone.danger,
      title: l10n.photoDeleteTitle,
      body: l10n.photoDeleteConfirm,
      actions: [
        AppConfirmAction(label: l10n.actionCancel, value: false),
        AppConfirmAction(
          label: l10n.actionDelete,
          value: true,
          isPrimary: true,
          isDestructive: true,
        ),
      ],
    );
    if (ok != true || !mounted) return;
    try {
      await ref
          .read(planReviewsRepositoryProvider)
          .deleteReviewPhoto(item.id);
      if (!mounted) return;
      AppToast.show(context, l10n.photoDeleted);
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e, logContext: 'plan_review_photo_delete');
    }
  }

  String _sortLabel(_PlanReviewSort sort) {
    final l10n = context.l10n;
    return switch (sort) {
      _PlanReviewSort.newest => l10n.reviewSortNewest,
      _PlanReviewSort.oldest => l10n.reviewSortOldest,
    };
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
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            AppFloatingActionLayout.listScrollPadding(
              context,
              aboveFixedBottomBar: true,
            ),
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _reviews.isEmpty
                        ? l10n.reviewEmpty
                        : l10n.planReviewCount(_reviews.length),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                PopupMenuButton<_PlanReviewSort>(
                  tooltip: l10n.reviewSortLabel,
                  initialValue: _sort,
                  onSelected: (v) => setState(() => _sort = v),
                  itemBuilder: (context) => [
                    for (final s in _PlanReviewSort.values)
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
            SizedBox(height: 12),
            if (visible.isEmpty)
              Text(
                l10n.reviewEmpty,
                style: TextStyle(color: AppColors.muted),
              )
            else
              for (final r in visible) ...[
                _PlanReviewCard(
                  review: r,
                  photoUrls: _urls,
                  isMine: r.userId == _uid,
                  onEdit: () => _openEditor(review: r),
                  onDelete: () => _confirmDelete(r),
                  onOpenPhoto: (index) => _openReviewPhotos(r, index),
                ),
                SizedBox(height: 12),
              ],
          ],
        ),
        AppAnchoredFloatingAction(
          aboveFixedBottomBar: true,
          child: FloatingActionButton(
            heroTag: 'plan_review_fab_${widget.planId}',
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

class _PlanReviewCard extends StatelessWidget {
  const _PlanReviewCard({
    required this.review,
    required this.photoUrls,
    required this.isMine,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenPhoto,
  });

  final PlanReview review;
  final Map<String, String> photoUrls;
  final bool isMine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<int> onOpenPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = () {
      final n = review.authorName?.trim() ?? '';
      if (n.isNotEmpty) return n;
      return isMine ? l10n.reviewAuthorYou : l10n.defaultUserDisplayName;
    }();
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      Text(
                        formatDateTimeShort(review.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMine)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: AppColors.muted),
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
                            width: 72,
                            height: 72,
                            cacheKey: review.photos[i].storagePath,
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
