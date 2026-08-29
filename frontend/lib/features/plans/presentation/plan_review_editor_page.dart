import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/discard_changes_scope.dart';
import '../data/plan_review_models.dart';

class PlanReviewEditorPage extends ConsumerStatefulWidget {
  const PlanReviewEditorPage({
    super.key,
    required this.planId,
    required this.planTitle,
    this.initialReview,
  });

  final String planId;
  final String planTitle;
  final PlanReview? initialReview;

  @override
  ConsumerState<PlanReviewEditorPage> createState() =>
      _PlanReviewEditorPageState();
}

class _PlanReviewEditorPageState extends ConsumerState<PlanReviewEditorPage> {
  late final TextEditingController _body;
  final List<File> _newPhotos = [];
  final List<PlanReviewPhoto> _existingPhotos = [];
  final Map<String, String> _existingUrls = {};
  final Set<String> _removedExistingIds = {};
  bool _saving = false;
  bool _loadingExisting = false;
  final FormDirtyTracker _formDirty = FormDirtyTracker();

  int get _keptExistingCount =>
      _existingPhotos.where((p) => !_removedExistingIds.contains(p.id)).length;

  int get _photoSlotsUsed => _keptExistingCount + _newPhotos.length;

  @override
  void initState() {
    super.initState();
    final r = widget.initialReview;
    _body = TextEditingController(text: r?.body ?? '');
    _body.addListener(() {
      if (mounted) setState(() {});
    });
    if (r != null && r.photos.isNotEmpty) {
      _existingPhotos.addAll(r.photos);
      _loadingExisting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_loadExistingUrls());
      });
    }
    _formDirty.arm();
  }

  Future<void> _loadExistingUrls() async {
    final repo = ref.read(planReviewsRepositoryProvider);
    final urls = <String, String>{};
    for (final p in _existingPhotos) {
      final u = await repo.signedUrl(p.storagePath);
      if (u != null && u.isNotEmpty) urls[p.id] = u;
    }
    if (!mounted) return;
    setState(() {
      _existingUrls
        ..clear()
        ..addAll(urls);
      _loadingExisting = false;
    });
  }

  @override
  void dispose() {
    _formDirty.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_photoSlotsUsed >= 3) {
      AppToast.show(context, context.l10n.reviewMaxPhotos, error: true);
      return;
    }
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 2560,
    );
    if (file == null) return;
    setState(() => _newPhotos.add(File(file.path)));
    _formDirty.markDirty();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    _formDirty.setSuppressed(true);
    try {
      final repo = ref.read(planReviewsRepositoryProvider);
      for (final id in _removedExistingIds) {
        await repo.deleteReviewPhoto(id);
      }
      await repo.saveReview(
        planId: widget.planId,
        body: _body.text,
        reviewId: widget.initialReview?.id,
        newPhotos: _newPhotos,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _formDirty.setSuppressed(false);
      AppToast.error(context, e, logContext: 'plan_review_save');
    }
  }

  Widget _thumbShell({required Widget child, required VoidCallback onRemove}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(width: 72, height: 72, child: child),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: AppColors.surfaceElevated,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: AppColors.foreground),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    final keptExisting = _existingPhotos
        .where((p) => !_removedExistingIds.contains(p.id))
        .toList();

    return ListenableBuilder(
      listenable: _formDirty,
      builder: (context, _) => DiscardChangesScope(
        hasUnsavedChanges: _formDirty.hasUnsavedChanges,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.planReviewEditorTitle),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.planTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _body,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: l10n.reviewCommentLabel,
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _formDirty.markDirty(),
              ),
              SizedBox(height: 16),
              if (_loadingExisting)
                Center(child: CircularProgressIndicator())
              else if (keptExisting.isNotEmpty || _newPhotos.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in keptExisting)
                      if (_existingUrls[p.id] != null)
                        _thumbShell(
                          child: AppNetworkImage(
                            url: _existingUrls[p.id]!,
                            width: 72,
                            height: 72,
                            cacheKey: p.storagePath,
                          ),
                          onRemove: () {
                            setState(() => _removedExistingIds.add(p.id));
                            _formDirty.markDirty();
                          },
                        ),
                    for (var i = 0; i < _newPhotos.length; i++)
                      _thumbShell(
                        child: Image.file(
                          _newPhotos[i],
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                        onRemove: () {
                          setState(() => _newPhotos.removeAt(i));
                          _formDirty.markDirty();
                        },
                      ),
                  ],
                ),
              SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _photoSlotsUsed >= 3 ? null : _pickPhoto,
                icon: Icon(Icons.add_photo_alternate_outlined),
                label: Text(l10n.reviewAddPhoto),
              ),
              SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.reviewSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
