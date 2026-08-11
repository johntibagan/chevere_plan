import 'package:flutter/material.dart';

import '../../../core/errors/user_facing_error.dart';
import '../data/moderation_models.dart';
import '../data/moderation_repository.dart';

Future<void> showSitePhotosSheet({
  required BuildContext context,
  required String siteId,
  required String siteName,
  required ModerationRepository repository,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _SitePhotosSheet(
      siteId: siteId,
      siteName: siteName,
      repository: repository,
    ),
  );
}

class _SitePhotosSheet extends StatefulWidget {
  const _SitePhotosSheet({
    required this.siteId,
    required this.siteName,
    required this.repository,
  });

  final String siteId;
  final String siteName;
  final ModerationRepository repository;

  @override
  State<_SitePhotosSheet> createState() => _SitePhotosSheetState();
}

class _SitePhotosSheetState extends State<_SitePhotosSheet> {
  bool _loading = true;
  String? _error;
  List<SitePhoto> _photos = const [];

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
      if (!mounted) return;
      setState(() {
        _photos = photos;
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
    final height = MediaQuery.sizeOf(context).height * 0.6;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Fotos · ${widget.siteName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _photos.isEmpty
                          ? const Center(child: Text('Este sitio no tiene fotos.'))
                          : ListView.separated(
                              itemCount: _photos.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final photo = _photos[index];
                                final url = widget.repository
                                    .publicPhotoUrl(photo.storagePath);
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        url,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) =>
                                            Container(
                                          width: 96,
                                          height: 96,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: OutlinedButton.icon(
                                          onPressed: () => _report(photo),
                                          icon: const Icon(
                                            Icons.flag_outlined,
                                            size: 18,
                                          ),
                                          label: const Text('Reportar'),
                                        ),
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
