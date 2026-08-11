import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../saves/data/saves_repository.dart';
import '../data/moderation_models.dart';
import '../data/moderation_repository.dart';

/// Abre la galería de fotos del sitio como **página** (no bottom sheet).
///
/// Preferir página completa: en tema oscuro los `showModalBottomSheet` con
/// listas altas suelen verse como “pantalla oscurecida sin contenido”.
Future<void> openSitePhotos({
  required BuildContext context,
  required String siteId,
  required String siteName,
  required ModerationRepository repository,
  SavesRepository? savesRepository,
  bool canManage = false,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => SitePhotosPage(
        siteId: siteId,
        siteName: siteName,
        repository: repository,
        savesRepository: savesRepository,
        canManage: canManage,
      ),
    ),
  );
}

/// @deprecated Usar [openSitePhotos].
Future<void> showSitePhotosSheet({
  required BuildContext context,
  required String siteId,
  required String siteName,
  required ModerationRepository repository,
  SavesRepository? savesRepository,
  bool canManage = false,
}) {
  return openSitePhotos(
    context: context,
    siteId: siteId,
    siteName: siteName,
    repository: repository,
    savesRepository: savesRepository,
    canManage: canManage,
  );
}

class SitePhotosPage extends StatefulWidget {
  const SitePhotosPage({
    super.key,
    required this.siteId,
    required this.siteName,
    required this.repository,
    this.savesRepository,
    this.canManage = false,
  });

  final String siteId;
  final String siteName;
  final ModerationRepository repository;
  final SavesRepository? savesRepository;
  final bool canManage;

  @override
  State<SitePhotosPage> createState() => _SitePhotosPageState();
}

class _SitePhotosPageState extends State<SitePhotosPage> {
  bool _loading = true;
  bool _busy = false;
  String? _error;
  List<SitePhoto> _photos = const [];
  final Map<String, String> _urls = {};

  bool get _canManage =>
      widget.canManage && widget.savesRepository != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final photos = await widget.repository.listSitePhotos(widget.siteId);
      final urls = <String, String>{};
      for (final p in photos) {
        try {
          urls[p.id] = await widget.repository.signedPhotoUrl(p.storagePath);
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _photos = photos;
        _urls
          ..clear()
          ..addAll(urls);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFacingError(e);
        _loading = false;
      });
    }
  }

  Future<void> _addPhoto() async {
    final savesRepo = widget.savesRepository;
    if (savesRepo == null) return;

    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos de Uso'),
        content: const Text(
          'Al subir una foto confirmas que cumple los Términos de Uso de '
          'Chevere Plan (turismo, gastronomía y planes de ocio; sin contenido '
          'sexual, ilegal o de acoso).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Acepto y continuar'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (picked == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await savesRepo.uploadPhoto(
        siteId: widget.siteId,
        file: File(picked.path),
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto añadida.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(SitePhoto photo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Quieres eliminar esta foto del sitio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await widget.repository.deletePhoto(photo);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto eliminada.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _report(SitePhoto photo) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar foto'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            labelText: 'Motivo (opcional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar reporte'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await widget.repository.reportPhoto(
        photoId: photo.id,
        reason: reasonCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte enviado. Un administrador lo revisará.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Fotos · ${widget.siteName}'),
        actions: [
          if (_canManage)
            IconButton(
              tooltip: 'Añadir foto',
              onPressed: _busy ? null : _addPhoto,
              icon: const Icon(Icons.add_a_photo_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _photos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _canManage
                                  ? 'Sin fotos. Pulsa el icono de cámara para añadir.'
                                  : 'Este sitio no tiene fotos.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            if (_canManage) ...[
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _busy ? null : _addPhoto,
                                icon: const Icon(Icons.add_a_photo_outlined),
                                label: const Text('Añadir foto'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _photos.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final photo = _photos[index];
                        final url = _urls[photo.id];
                        return Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (url != null && url.isNotEmpty)
                                  AppNetworkImage(
                                    url: url,
                                    width: 96,
                                    height: 96,
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                else
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      if (_canManage)
                                        OutlinedButton.icon(
                                          onPressed: _busy
                                              ? null
                                              : () => _delete(photo),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                          ),
                                          label: const Text('Eliminar'),
                                        ),
                                      OutlinedButton.icon(
                                        onPressed: _busy
                                            ? null
                                            : () => _report(photo),
                                        icon: const Icon(
                                          Icons.flag_outlined,
                                          size: 18,
                                        ),
                                        label: const Text('Reportar'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
