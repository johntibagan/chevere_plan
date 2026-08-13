import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
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
  bool _saving = false;

  bool get _canChoosePrivacy => widget.siteIsPublic;

  @override
  void initState() {
    super.initState();
    final r = widget.initialReview;
    _body = TextEditingController(text: r?.body ?? '');
    _rating = r?.rating ?? 5;
    _isPublic = widget.initialIsPublic ??
        r?.isPublic ??
        false; // bitácora por defecto
    if (!_canChoosePrivacy) _isPublic = false;
    _newPhotos.addAll(widget.seedPhotos.take(3));
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final existing = widget.initialReview?.photos.length ?? 0;
    if (existing + _newPhotos.length >= 3) {
      AppToast.show(context, context.l10n.reviewMaxPhotos, error: true);
      return;
    }
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _newPhotos.add(File(file.path)));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(siteReviewsRepositoryProvider).saveReview(
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
      AppToast.error(context, e, logContext: 'site_review_save');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.reviewEditorTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.siteName,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.reviewRatingLabel, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(
                    i <= _rating ? Icons.star : Icons.star_border,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            maxLines: 5,
            maxLength: 800,
            decoration: InputDecoration(
              labelText: l10n.reviewCommentLabel,
              alignLabelWithHint: true,
            ),
          ),
          if (_canChoosePrivacy) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.reviewMakePublic,
                style: const TextStyle(color: AppColors.foreground),
              ),
              subtitle: Text(
                _isPublic ? l10n.reviewPublicHint : l10n.reviewPrivateHint,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              value: _isPublic,
              onChanged: (v) => setState(() => _isPublic = v),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in _newPhotos)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(f, width: 72, height: 72, fit: BoxFit.cover),
                ),
              OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(l10n.reviewAddPhoto),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.reviewSave),
          ),
        ],
      ),
    );
  }
}
