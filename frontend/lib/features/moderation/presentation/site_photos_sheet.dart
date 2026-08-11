import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../saves/data/saves_repository.dart';
import '../data/moderation_models.dart';
import '../data/moderation_repository.dart';

Future<void> showSitePhotosSheet({
  required BuildContext context,
  required String siteId,
  required String siteName,
  required ModerationRepository repository,
  bool canManage = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _SitePhotosSheet(
      siteId: siteId,
      siteName: siteName,
      repository: repository,
      canManage: canManage,
    ),
  );
}

class _SitePhotosSheet extends ConsumerStatefulWidget {
  const _SitePhotosSheet({
    required this.siteId,
    required this.siteName,
    required this.repository,
    required this.canManage,
  });

  final String siteId;
  final String siteName;
  final ModerationRepository repository;
  final bool canManage;

  @override
  ConsumerState<_SitePhotosSheet> createState() => _SitePhotosSheetState();
}

class _SitePhotosSheetState extends ConsumerState<_SitePhotosSheet> {
  bool _loading = true;
  bool _busy = false;
  String? _error;
  List<SitePhoto> _photos = const [];
  final Map<String, String> _urls = {};

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
        } catch (_) {
          // Deja sin URL; se muestra broken_image.
        }
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

  bool _canDelete(SitePhoto photo) => widget.canManage;

  Future<void> _addPhoto(SavesRepository savesRepo) async {
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
    final height = MediaQuery.sizeOf(context).height * 0.65;
    final savesRepo = ref.read(savesRepositoryProvider);

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Fotos · ${widget.siteName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (widget.canManage)
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : () => _addPhoto(savesRepo),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                    label: const Text('Añadir'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _photos.isEmpty
                          ? Center(
                              child: Text(
                                widget.canManage
                                    ? 'Sin fotos. Usa «Añadir» para subir una.'
                                    : 'Este sitio no tiene fotos.',
                              ),
                            )
                          : ListView.separated(
                              itemCount: _photos.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final photo = _photos[index];
                                final url = _urls[photo.id];
                                return Row(
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          if (_canDelete(photo))
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
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
