import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../admin/data/admin_models.dart';
import '../../admin/data/admin_repository.dart';
import '../data/draft_reminder_service.dart';
import '../data/save_models.dart';
import '../data/saves_repository.dart';
import '../data/share_parser.dart';

class SavePlacePage extends StatefulWidget {
  const SavePlacePage({
    super.key,
    this.initialSharedText,
    required this.savesRepository,
  });

  final String? initialSharedText;
  final SavesRepository savesRepository;

  @override
  State<SavePlacePage> createState() => _SavePlacePageState();
}

class _SavePlacePageState extends State<SavePlacePage> {
  final _adminRepo = AdminRepository();
  final _nameCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  List<Category> _categories = [];
  final Set<String> _selectedCategoryIds = {};
  bool _isPublic = false;
  bool _isPhysical = true;
  bool _loadingCats = true;
  bool _saving = false;
  String? _network;
  String? _error;
  File? _pendingPhoto;

  @override
  void initState() {
    super.initState();
    final parsed = ShareParser.parse(widget.initialSharedText);
    if (parsed.url != null) _urlCtrl.text = parsed.url!;
    if (parsed.suggestedName != null) _nameCtrl.text = parsed.suggestedName!;
    _network = parsed.network;
    _loadCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _cityCtrl.dispose();
    _deptCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _adminRepo.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats.where((c) => c.isActive).toList();
        _loadingCats = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFacingError(e);
        _loadingCats = false;
      });
    }
  }

  Future<void> _pickPhoto() async {
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
    if (accepted != true) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _pendingPhoto = File(file.path));
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final lat = double.tryParse(_latCtrl.text.replaceAll(',', '.'));
      final lng = double.tryParse(_lngCtrl.text.replaceAll(',', '.'));
      final name = _nameCtrl.text.trim().isEmpty ? 'Sin nombre' : _nameCtrl.text.trim();

      String? linkToExisting;
      final shouldCheckDuplicates = _isPhysical &&
          name != 'Sin nombre' &&
          ((_isPublic) ||
              (lat != null && lng != null) ||
              _cityCtrl.text.trim().isNotEmpty);

      if (shouldCheckDuplicates) {
        final dupes = await widget.savesRepository.findPossibleDuplicates(
          name: name,
          city: _cityCtrl.text,
          latitude: lat,
          longitude: lng,
        );
        if (dupes.isNotEmpty && mounted) {
          final chosen = await _askDuplicate(dupes.first);
          if (chosen == null) {
            setState(() => _saving = false);
            return; // canceló
          }
          if (chosen) {
            linkToExisting = dupes.first.siteId;
          }
        }
      }

      final saved = await widget.savesRepository.createSave(
        SaveDraftInput(
          name: _nameCtrl.text,
          sourceUrl: _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
          sourceNetwork: _network,
          city: _cityCtrl.text,
          department: _deptCtrl.text,
          addressLine: _addressCtrl.text,
          latitude: lat,
          longitude: lng,
          categoryIds: _selectedCategoryIds.toList(),
          isPublic: _isPublic,
          isPhysicalPlace: _isPhysical,
          linkToExistingSiteId: linkToExisting,
        ),
      );

      if (_pendingPhoto != null && linkToExisting == null) {
        await widget.savesRepository.uploadPhoto(
          siteId: saved.siteId,
          file: _pendingPhoto!,
        );
      }

      if (saved.status == SiteStatus.draft) {
        await DraftReminderService.instance.scheduleForSave(
          saveId: saved.id,
          title: saved.siteName,
        );
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Lugar guardado!'),
          content: Text(
            [
              if (saved.isPossibleDuplicate)
                'Quedó vinculado a un sitio público existente (posible duplicado).'
              else if (saved.status == SiteStatus.complete)
                'Quedó completo en tu lista.'
              else
                'Estado: ${saved.status.labelEs}. Puedes completarlo después.',
              if (!saved.isPublic) ' Privado por defecto.',
            ].join(),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Listo'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, saved);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFacingError(e);
        _saving = false;
      });
    }
  }

  /// `true` = mismo sitio, `false` = uno nuevo, `null` = cancelar
  Future<bool?> _askDuplicate(PossibleDuplicate d) {
    final dist = d.distanceM == null
        ? ''
        : ' · ~${d.distanceM!.round()} m';
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Es el mismo sitio?'),
        content: Text(
          'Encontramos un sitio público parecido:\n\n'
          '«${d.siteName}»'
          '${d.city != null ? ' — ${d.city}' : ''}$dist\n\n'
          'No se fusiona solo: tú decides.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Es uno nuevo'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, es el mismo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roots = _categories.where((c) => c.isRoot).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardar lugar'),
      ),
      body: _loadingCats
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Desde Instagram, TikTok, Facebook y más',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Enlace de la publicación',
                    hintText: 'Pega el enlace aquí…',
                    border: OutlineInputBorder(),
                    helperText: 'El enlace original siempre permanece privado',
                  ),
                  onChanged: (v) {
                    final p = ShareParser.parse(v);
                    setState(() => _network = p.network);
                  },
                ),
                if (_network != null) ...[
                  const SizedBox(height: 8),
                  Text('Red detectada: $_network'),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del lugar',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cityCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    border: OutlineInputBorder(),
                    helperText:
                        'Si no la conoces, déjala vacía → pendiente / borrador',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _deptCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Departamento',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Lat (opc.)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _lngCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Lng (opc.)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Categorías',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...roots.map((root) {
                  final children = _categories
                      .where((c) => c.parentId == root.id)
                      .toList()
                    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                  return ExpansionTile(
                    title: Text(root.nameEs),
                    children: [
                      CheckboxListTile(
                        dense: true,
                        title: Text('${root.nameEs} (categoría)'),
                        value: _selectedCategoryIds.contains(root.id),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selectedCategoryIds.add(root.id);
                            } else {
                              _selectedCategoryIds.remove(root.id);
                            }
                          });
                        },
                      ),
                      ...children.map(
                        (c) => CheckboxListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 24),
                          title: Text(
                            c.ageRestricted ? '${c.nameEs} (+18)' : c.nameEs,
                          ),
                          value: _selectedCategoryIds.contains(c.id),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedCategoryIds.add(c.id);
                              } else {
                                _selectedCategoryIds.remove(c.id);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }),
                SwitchListTile(
                  title: const Text('Es un lugar físico'),
                  subtitle: const Text(
                    'Si no lo es (receta, tip, etc.), quedará siempre privado',
                  ),
                  value: _isPhysical,
                  onChanged: (v) => setState(() {
                    _isPhysical = v;
                    if (!v) _isPublic = false;
                  }),
                ),
                SwitchListTile(
                  title: const Text('Hacer público'),
                  subtitle: Text(
                    _isPhysical
                        ? (_isPublic ? 'Visible para otros' : 'Solo para ti')
                        : 'No aplica (contenido no físico)',
                  ),
                  value: _isPublic,
                  onChanged: _isPhysical
                      ? (v) => setState(() => _isPublic = v)
                      : null,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.photo_outlined),
                  label: Text(
                    _pendingPhoto == null
                        ? 'Añadir foto (máx. 15)'
                        : 'Foto lista para subir',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
    );
  }
}
