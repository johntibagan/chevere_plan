import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../admin/data/admin_models.dart';
import '../../admin/data/admin_repository.dart';
import '../data/draft_reminder_service.dart';
import '../data/geo_place.dart';
import '../data/save_models.dart';
import '../data/saves_repository.dart';
import '../data/share_parser.dart';
import 'category_picker_sheet.dart';
import 'location_picker_page.dart';

const _kRequiredStar = Color(0xFFFF8C00);

class SavePlacePage extends StatefulWidget {
  const SavePlacePage({
    super.key,
    this.initialSharedText,
    this.existingSaveId,
    required this.savesRepository,
  });

  final String? initialSharedText;
  /// Si viene, carga y actualiza ese guardado (completar borrador / editar).
  final String? existingSaveId;
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
  final _categorySearchCtrl = TextEditingController();

  double? _lat;
  double? _lng;

  List<Category> _categories = [];
  final Set<String> _selectedCategoryIds = {};
  bool _isPublic = false;
  bool _isPhysical = true;
  bool _loadingCats = true;
  bool _saving = false;
  String? _network;
  String? _error;
  File? _pendingPhoto;
  String? _editSaveId;
  String? _editSiteId;

  bool get _isEditing => _editSaveId != null;

  @override
  void initState() {
    super.initState();
    final parsed = ShareParser.parse(widget.initialSharedText);
    if (parsed.url != null) _urlCtrl.text = parsed.url!;
    if (parsed.suggestedName != null) _nameCtrl.text = parsed.suggestedName!;
    _network = parsed.network;
    _bootstrapForm();
  }

  Future<void> _bootstrapForm() async {
    try {
      final cats = await _adminRepo.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats.where((c) => c.isActive).toList();
      });

      final saveId = widget.existingSaveId;
      if (saveId != null) {
        final data = await widget.savesRepository.loadForEdit(saveId);
        if (!mounted) return;
        final s = data.save;
        _nameCtrl.text = s.siteName == 'Sin nombre' ? '' : s.siteName;
        _urlCtrl.text = s.sourceUrl ?? '';
        _cityCtrl.text = s.city ?? '';
        _deptCtrl.text = s.department ?? '';
        _addressCtrl.text = s.addressLine ?? '';
        _network = s.sourceNetwork;
        setState(() {
          _editSaveId = s.id;
          _editSiteId = s.siteId;
          _isPublic = s.isPublic;
          _isPhysical = s.isPhysicalPlace;
          _lat = data.latitude;
          _lng = data.longitude;
          _selectedCategoryIds
            ..clear()
            ..addAll(data.categoryIds);
          _loadingCats = false;
        });
      } else {
        setState(() => _loadingCats = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFacingError(e);
        _loadingCats = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _cityCtrl.dispose();
    _deptCtrl.dispose();
    _addressCtrl.dispose();
    _categorySearchCtrl.dispose();
    super.dispose();
  }

  String _parentName(Category c) {
    if (c.parentId == null) return '';
    final parent = _categories.where((p) => p.id == c.parentId);
    return parent.isEmpty ? '' : parent.first.nameEs;
  }

  List<Category> get _filteredCategories {
    final q = _categorySearchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final hits = _categories.where((c) {
      if (!c.isActive) return false;
      if (c.matchesQuery(q)) return true;
      final parent = _categories.where((p) => p.id == c.parentId);
      if (parent.isNotEmpty && parent.first.matchesQuery(q)) return true;
      final parentName = _parentName(c).toLowerCase();
      if (parentName.contains(q)) return true;
      return false;
    }).toList();
    hits.sort((a, b) {
      if (a.isRoot != b.isRoot) return a.isRoot ? 1 : -1;
      return a.nameEs.compareTo(b.nameEs);
    });
    return hits.take(16).toList();
  }

  Future<void> _openCategoryTree() async {
    final result = await showCategoryPickerSheet(
      context: context,
      categories: _categories,
      selectedIds: _selectedCategoryIds,
    );
    if (result == null || !mounted) return;
    setState(() {
      _selectedCategoryIds
        ..clear()
        ..addAll(result);
    });
  }

  List<Category> get _selectedCategories {
    return _categories
        .where((c) => _selectedCategoryIds.contains(c.id))
        .toList();
  }

  Future<void> _openMap() async {
    final place = await Navigator.of(context).push<GeoPlace>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialLat: _lat,
          initialLng: _lng,
        ),
      ),
    );
    if (place == null || !mounted) return;
    setState(() {
      _lat = place.lat;
      _lng = place.lng;
      if (place.city != null && place.city!.isNotEmpty) {
        _cityCtrl.text = place.city!;
      }
      if (place.department != null && place.department!.isNotEmpty) {
        _deptCtrl.text = place.department!;
      }
      if (place.addressLine != null && place.addressLine!.isNotEmpty) {
        _addressCtrl.text = place.addressLine!;
      }
      // Solo rellenar nombre si está vacío (no pisar share/sugerencia previa).
      if (_nameCtrl.text.trim().isEmpty &&
          place.name != null &&
          place.name!.isNotEmpty) {
        _nameCtrl.text = place.name!;
      }
    });
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

  bool _validate() {
    if (_isPhysical && (_lat == null || _lng == null)) {
      setState(() => _error = 'Elige la ubicación en el mapa.');
      return false;
    }
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Escribe el nombre del lugar.');
      return false;
    }
    if (_selectedCategoryIds.isEmpty) {
      setState(() => _error = 'Selecciona al menos una categoría.');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final lat = _lat;
      final lng = _lng;
      final name = _nameCtrl.text.trim();

      final input = SaveDraftInput(
        name: name,
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
      );

      final UserSave saved;
      final editSaveId = _editSaveId;
      final editSiteId = _editSiteId;

      if (editSaveId != null && editSiteId != null) {
        saved = await widget.savesRepository.updateSave(
          saveId: editSaveId,
          siteId: editSiteId,
          input: input,
        );
      } else {
        String? linkToExisting;
        final shouldCheckDuplicates = _isPhysical &&
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
              return;
            }
            if (chosen) linkToExisting = dupes.first.siteId;
          }
        }

        saved = await widget.savesRepository.createSave(
          SaveDraftInput(
            name: name,
            sourceUrl: input.sourceUrl,
            sourceNetwork: input.sourceNetwork,
            city: input.city,
            department: input.department,
            addressLine: input.addressLine,
            latitude: lat,
            longitude: lng,
            categoryIds: input.categoryIds,
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
      }

      if (_pendingPhoto != null && editSaveId != null) {
        await widget.savesRepository.uploadPhoto(
          siteId: saved.siteId,
          file: _pendingPhoto!,
        );
      }

      if (saved.status == SiteStatus.complete) {
        await DraftReminderService.instance.cancelForSave(saved.id);
      } else if (saved.status == SiteStatus.draft) {
        await DraftReminderService.instance.scheduleForSave(
          saveId: saved.id,
          title: saved.siteName,
        );
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_isEditing ? '¡Actualizado!' : '¡Lugar guardado!'),
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

  Future<bool?> _askDuplicate(PossibleDuplicate d) {
    final dist =
        d.distanceM == null ? '' : ' · ~${d.distanceM!.round()} m';
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

  Widget _label(String text, {bool required = false}) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: _kRequiredStar,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label, {bool required = false, String? helper}) {
    return InputDecoration(
      label: required
          ? Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: label),
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: _kRequiredStar,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Text(label),
      border: const OutlineInputBorder(),
      helperText: helper,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Completar / editar lugar' : 'Guardar lugar'),
      ),
      body: _loadingCats
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Primero ubica el lugar; el mapa rellena ciudad y departamento.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),

                // 1) Mapa primero
                _label(
                  _isPhysical ? 'Ubicación en el mapa' : 'Ubicación (opcional)',
                  required: _isPhysical,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.map_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      _lat != null && _lng != null
                          ? 'Punto listo'
                          : 'Elegir en el mapa',
                    ),
                    subtitle: Text(
                      _lat != null && _lng != null
                          ? '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}'
                          : 'Busca o toca el mapa (Geoapify + OpenStreetMap)',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _saving ? null : _openMap,
                  ),
                ),
                if (_lat != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() {
                                _lat = null;
                                _lng = null;
                              }),
                      child: const Text('Quitar ubicación'),
                    ),
                  ),

                const SizedBox(height: 16),
                // 2) Campos auto / editables
                TextField(
                  controller: _nameCtrl,
                  decoration: _dec('Nombre del lugar', required: true),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cityCtrl,
                  decoration: _dec('Ciudad', helper: 'Se completa desde el mapa'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _deptCtrl,
                  decoration: _dec(
                    'Departamento',
                    helper: 'Se completa desde el mapa',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressCtrl,
                  decoration: _dec('Dirección'),
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 16),
                // 3) Link red social
                TextField(
                  controller: _urlCtrl,
                  decoration: _dec(
                    'Enlace de la red social',
                    helper: 'El enlace original siempre permanece privado',
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (v) {
                    final p = ShareParser.parse(v);
                    setState(() => _network = p.network);
                  },
                ),
                if (_network != null) ...[
                  const SizedBox(height: 6),
                  Text('Red detectada: $_network'),
                ],

                const SizedBox(height: 16),
                // 4) Categorías por búsqueda
                _label('Categorías', required: true),
                const SizedBox(height: 8),
                if (_selectedCategories.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedCategories.map((c) {
                      final parent = _parentName(c);
                      final label = parent.isEmpty
                          ? c.nameEs
                          : '$parent › ${c.nameEs}';
                      return InputChip(
                        label: Text(
                          c.ageRestricted ? '$label (+18)' : label,
                        ),
                        onDeleted: _saving
                            ? null
                            : () => setState(
                                  () => _selectedCategoryIds.remove(c.id),
                                ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: _categorySearchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ej. nadar, tejo, plaza, bar…',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: IconButton(
                      tooltip: 'Ver árbol de categorías',
                      onPressed: _saving ? null : _openCategoryTree,
                      icon: const Icon(Icons.account_tree_outlined),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (_categorySearchCtrl.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ..._filteredCategories.map((c) {
                    final parent = _parentName(c);
                    final label = parent.isEmpty
                        ? c.nameEs
                        : '$parent › ${c.nameEs}';
                    final selected = _selectedCategoryIds.contains(c.id);
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        c.ageRestricted ? '$label (+18)' : label,
                      ),
                      value: selected,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selectedCategoryIds.add(c.id);
                          } else {
                            _selectedCategoryIds.remove(c.id);
                          }
                        });
                      },
                    );
                  }),
                  if (_filteredCategories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Sin coincidencias'),
                    ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Escribe una palabra clave o abre el árbol.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _saving ? null : _openCategoryTree,
                          icon: const Icon(Icons.account_tree_outlined, size: 18),
                          label: const Text('Árbol'),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Es un lugar físico'),
                  subtitle: const Text(
                    'Si no lo es (receta, tip…), quedará siempre privado',
                  ),
                  value: _isPhysical,
                  onChanged: (v) => setState(() {
                    _isPhysical = v;
                    if (!v) _isPublic = false;
                  }),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hacer público'),
                  value: _isPublic,
                  onChanged: _isPhysical
                      ? (v) => setState(() => _isPublic = v)
                      : null,
                ),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickPhoto,
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Guardar cambios' : 'Guardar'),
                ),
                const SizedBox(height: 8),
                const Text(
                  '* Campos obligatorios',
                  style: TextStyle(color: _kRequiredStar, fontSize: 12),
                ),
              ],
            ),
    );
  }
}
