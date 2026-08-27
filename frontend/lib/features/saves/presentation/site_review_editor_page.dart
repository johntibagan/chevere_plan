import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/providers.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/discard_changes_scope.dart';
import '../data/site_review_models.dart';

/// Crear / editar reseña (comentario + estrellas + hasta 3 fotos + privacidad).
class SiteReviewEditorPage extends ConsumerStatefulWidget {
  const SiteReviewEditorPage({
    super.key,
    required this.siteId,
    required this.siteName,
    this.initialReview,
    this.seedPhotos = const [],
    this.siteIsPublic = true,
    this.initialIsPublic,
  });

  final String siteId;
  final String siteName;
  final SiteReview? initialReview;
  final List<File> seedPhotos;
  /// En sitio público se puede elegir reseña pública o bitácora privada.
  final bool siteIsPublic;
  /// Preferencia al abrir (p. ej. desde diálogo de duplicados).
  final bool? initialIsPublic;

  @override
  ConsumerState<SiteReviewEditorPage> createState() =>
      _SiteReviewEditorPageState();
}

class _SiteReviewEditorPageState extends ConsumerState<SiteReviewEditorPage> {
  late final TextEditingController _body;
  int _rating = 5;
  late bool _isPublic;
  final List<File> _newPhotos = [];
  /// Fotos ya en el servidor (editar).
  final List<SiteReviewPhoto> _existingPhotos = [];
  final Map<String, String> _existingUrls = {};
  final Set<String> _removedExistingIds = {};
  bool _saving = false;
  bool _loadingExisting = false;
  final FormDirtyTracker _formDirty = FormDirtyTracker();

  bool get _canChoosePrivacy => widget.siteIsPublic;

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
    _rating = r?.rating ?? 5;
    _isPublic = widget.initialIsPublic ??
        r?.isPublic ??
        false; // bitácora por defecto
    if (!_canChoosePrivacy) _isPublic = false;
    _newPhotos.addAll(widget.seedPhotos.take(3));
    if (r != null && r.photos.isNotEmpty) {
      _existingPhotos.addAll(r.photos);
      _loadingExisting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_loadExistingUrls());
      });
    }
    _formDirty.arm();
    // Semilla de fotos = ya hay contenido pendiente de guardar.
    if (_newPhotos.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formDirty.markDirty();
      });
    }
  }

  Future<void> _loadExistingUrls() async {
    final repo = ref.read(siteReviewsRepositoryProvider);
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
      final repo = ref.read(siteReviewsRepositoryProvider);
      for (final id in _removedExistingIds) {
        await repo.deleteReviewPhoto(id);
      }
      await repo.saveReview(
        siteId: widget.siteId,
        body: _body.text,
        rating: _rating,
        isPublic: _canChoosePrivacy && _isPublic,
        reviewId: widget.initialReview?.id,
        newPhotos: _newPhotos,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _formDirty.setSuppressed(false);
      AppToast.error(context, e, logContext: 'site_review_save');
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
          key: WidgetKeys.reviewEditor,
          appBar: AppBar(
            title: Text(l10n.reviewEditorTitle),
          ),
          body: DirtyInteractionScope(
            tracker: _formDirty,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  widget.siteName,
                  style: AppTypography.tabTitle(color: AppColors.foreground),
                ),
                SizedBox(height: 16),
                Text(
                  l10n.reviewRatingLabel,
                  style: TextStyle(color: AppColors.muted),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      IconButton(
                        key: WidgetKeys.reviewStar(i),
                        onPressed: () => setState(() => _rating = i),
                        icon: Icon(
                          i <= _rating ? Icons.star : Icons.star_border,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                TextField(
                  key: WidgetKeys.reviewBody,
                  controller: _body,
                  maxLines: 5,
                  maxLength: 800,
                  decoration: InputDecoration(
                    labelText: l10n.reviewCommentLabel,
                    alignLabelWithHint: true,
                  ),
                ),
                if (_canChoosePrivacy) ...[
                  SizedBox(height: 8),
                  SwitchListTile(
                    key: WidgetKeys.reviewPublicSwitch,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.reviewMakePublic,
                      style: TextStyle(color: AppColors.foreground),
                    ),
                    subtitle: Text(
                      _isPublic
                          ? l10n.reviewPublicHint
                          : l10n.reviewPrivateHint,
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    value: _isPublic,
                    onChanged: (v) => setState(() => _isPublic = v),
                  ),
                ],
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_loadingExisting)
                      const SizedBox(
                        width: 72,
                        height: 72,
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    for (final p in keptExisting)
                      _thumbShell(
                        onRemove: () =>
                            setState(() => _removedExistingIds.add(p.id)),
                        child: _existingUrls[p.id] != null
                            ? AppNetworkImage(
                                url: _existingUrls[p.id]!,
                                width: 72,
                                height: 72,
                                cacheKey: p.storagePath,
                              )
                            : ColoredBox(
                                color: AppColors.surfaceElevated,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: AppColors.muted,
                                ),
                              ),
                      ),
                    for (var i = 0; i < _newPhotos.length; i++)
                      _thumbShell(
                        onRemove: () =>
                            setState(() => _newPhotos.removeAt(i)),
                        child: Image.file(
                          _newPhotos[i],
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (_photoSlotsUsed < 3)
                      OutlinedButton.icon(
                        onPressed: _pickPhoto,
                        icon: Icon(Icons.add_a_photo_outlined),
                        label: Text(l10n.reviewAddPhoto),
                      ),
                  ],
                ),
                SizedBox(height: 24),
                FilledButton(
                  key: WidgetKeys.reviewSubmit,
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
      ),
    );
  }
}
