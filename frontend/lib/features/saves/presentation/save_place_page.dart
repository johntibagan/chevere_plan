import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../admin/data/admin_models.dart';
import '../data/geo_place.dart';
import '../data/google_maps_link_importer.dart';
import '../data/link_preview_fetcher.dart';
import '../data/save_models.dart';
import '../data/saves_repository.dart';
import '../data/share_parser.dart';
import '../data/social_link_models.dart';
import 'category_picker_sheet.dart';
import 'location_picker_page.dart';
import 'site_status_l10n.dart';
import 'social_link_preview_card.dart';

const _kRequiredStar = Color(0xFFFF8C00);

class SavePlacePage extends ConsumerStatefulWidget {
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
  ConsumerState<SavePlacePage> createState() => _SavePlacePageState();
}

class _SavePlacePageState extends ConsumerState<SavePlacePage> {
  final _nameCtrl = TextEditingController();
  final _mapsCtrl = TextEditingController();
  final _socialCtrl = TextEditingController();
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
  bool _importingMaps = false;
  bool _addingSocial = false;
  /// true = pegar enlace Google Maps; false = mapa interactivo.
  bool _useGoogleLink = false;
  bool _locationDetailsExpanded = false;
  int _locationPanelEpoch = 0;
  String? _error;
  File? _pendingPhoto;
  String? _pendingMapImageUrl;
  String? _editSaveId;
  String? _editSiteId;
  final List<SocialLinkDraft> _socialLinks = [];
  final _previewFetcher = LinkPreviewFetcher();
  final _mapsImporter = GoogleMapsLinkImporter();

  bool get _isEditing => _editSaveId != null;

  @override
  void initState() {
    super.initState();
    final parsed = ShareParser.parse(widget.initialSharedText);
    if (parsed.url != null) {
      if (GoogleMapsLinkImporter.looksLikeMapsUrl(parsed.url)) {
        _mapsCtrl.text = parsed.url!;
        _useGoogleLink = true;
      } else {
        _socialCtrl.text = parsed.url!;
      }
    }
    if (parsed.suggestedName != null) _nameCtrl.text = parsed.suggestedName!;
    _bootstrapForm();
  }

  Future<void> _bootstrapForm() async {
    try {
      final cats = await ref.read(categoriesProvider.future);
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
        _cityCtrl.text = s.city ?? '';
        _deptCtrl.text = s.department ?? '';
        _addressCtrl.text = s.addressLine ?? '';
        final links = await widget.savesRepository.listSocialLinks(s.siteId);
        if (!mounted) return;
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
          _socialLinks
            ..clear()
            ..addAll(
              links.map(
                (l) => SocialLinkDraft(
                  url: l.url,
                  network: l.network,
                  title: l.title,
                  description: l.description,
                  imageUrl: l.imageUrl,
                  existingId: l.id,
                ),
              ),
            );
          if (_socialLinks.isEmpty &&
              (s.sourceUrl?.trim().isNotEmpty ?? false)) {
            _socialLinks.add(
              SocialLinkDraft(
                url: s.sourceUrl!,
                network: s.sourceNetwork,
              ),
            );
          }
          _loadingCats = false;
        });
      } else {
        // Si vino un enlace social por share, generar preview.
        if (_socialCtrl.text.trim().isNotEmpty) {
          await _addSocialLink(_socialCtrl.text.trim());
          _socialCtrl.clear();
        }
        if (_mapsCtrl.text.trim().isNotEmpty) {
          await _importFromGoogleMaps();
        }
        if (mounted) setState(() => _loadingCats = false);
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
    _mapsCtrl.dispose();
    _socialCtrl.dispose();
    _cityCtrl.dispose();
    _deptCtrl.dispose();
    _addressCtrl.dispose();
    _categorySearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _importFromGoogleMaps() async {
    final text = _mapsCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Pega un enlace de Google Maps.');
      return;
    }
    setState(() {
      _importingMaps = true;
      _error = null;
    });
    try {
      final result = await _mapsImporter.importFromText(text);
      if (!mounted) return;
      setState(() {
        if (result.name != null &&
            (result.name!.trim().isNotEmpty) &&
            (_nameCtrl.text.trim().isEmpty ||
                _nameCtrl.text.trim() == 'Sin nombre')) {
          _nameCtrl.text = result.name!;
        }
        if (result.city != null && result.city!.trim().isNotEmpty) {
          _cityCtrl.text = result.city!;
        }
        if (result.department != null &&
            result.department!.trim().isNotEmpty) {
          _deptCtrl.text = result.department!;
        }
        if (result.addressLine != null &&
            result.addressLine!.trim().isNotEmpty &&
            _addressCtrl.text.trim().isEmpty) {
          _addressCtrl.text = result.addressLine!;
        }
        _lat = result.lat ?? _lat;
        _lng = result.lng ?? _lng;
        _pendingMapImageUrl = result.staticMapUrl;
        _locationDetailsExpanded = false;
        _locationPanelEpoch++;
        _importingMaps = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.hasCoords
                ? 'Datos de Google Maps aplicados (nombre, ubicación'
                    '${result.staticMapUrl != null ? ', mapa' : ''}).'
                : 'Se leyó el enlace; completa ciudad o elige en el mapa.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _importingMaps = false;
        _error = userFacingError(e);
      });
    }
  }

  Future<void> _addSocialLink(String raw) async {
    final parsed = ShareParser.parse(raw);
    final url = parsed.url ?? raw.trim();
    if (url.isEmpty || !url.startsWith('http')) {
      setState(() => _error = 'Pega un enlace http(s) válido.');
      return;
    }
    if (_socialLinks.any((l) => l.url == url)) {
      setState(() => _error = 'Ese enlace ya está en la lista.');
      return;
    }
    setState(() {
      _addingSocial = true;
      _error = null;
    });
    final draft = SocialLinkDraft(url: url, network: parsed.network);
    setState(() => _socialLinks.add(draft));
    try {
      final preview = await _previewFetcher.fetch(url);
      if (!mounted) return;
      setState(() {
        draft
          ..title = preview.title
          ..description = preview.description
          ..imageUrl = preview.imageUrl
          ..network = draft.network ??
              ShareParser.parse(url).network ??
              preview.siteName;
        _addingSocial = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _addingSocial = false);
    }
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
    // Refetch por si el form quedó sin datos o el seed se aplicó después.
    if (_categories.isEmpty) {
      try {
        final cats = await ref.read(categoriesProvider.future);
        if (!mounted) return;
        setState(() {
          _categories = cats.where((c) => c.isActive).toList();
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
        return;
      }
    }

    if (_categories.isEmpty) {
      // Reintento forzado si el seed se aplicó después del primer fetch cacheado.
      ref.invalidate(categoriesProvider);
      try {
        final cats = await ref.read(categoriesProvider.future);
        if (!mounted) return;
        setState(() {
          _categories = cats.where((c) => c.isActive).toList();
        });
      } catch (_) {}
    }

    if (_categories.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay categorías. Aplica el seed SQL (migración 2 y 10) en Supabase.',
          ),
        ),
      );
      return;
    }

    final result = await showCategoryPickerSheet(
      context: context,
      categories: List<Category>.from(_categories),
      selectedIds: Set<String>.from(_selectedCategoryIds),
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
      _locationDetailsExpanded = false;
      _locationPanelEpoch++;
    });
  }

  String get _locationSummary {
    final parts = <String>[
      if (_cityCtrl.text.trim().isNotEmpty) _cityCtrl.text.trim(),
      if (_deptCtrl.text.trim().isNotEmpty) _deptCtrl.text.trim(),
      if (_addressCtrl.text.trim().isNotEmpty) _addressCtrl.text.trim(),
      if (_lat != null && _lng != null) 'Punto en mapa',
    ];
    if (parts.isEmpty) return 'Sin datos aún';
    return parts.join(' · ');
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
    // Misma regla que SavePolicies: ubicación = ciudad, dirección o coords.
    if (_isPhysical) {
      final hasCoords = _lat != null && _lng != null;
      final hasCity = _cityCtrl.text.trim().isNotEmpty;
      final hasAddress = _addressCtrl.text.trim().isNotEmpty;
      if (!hasCoords && !hasCity && !hasAddress) {
        setState(() {
          _error =
              'Indica la ubicación: elige en el mapa, o escribe ciudad/dirección.';
        });
        return false;
      }
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
      final primaryLink =
          _socialLinks.isNotEmpty ? _socialLinks.first : null;

      final input = SaveDraftInput(
        name: name,
        sourceUrl: primaryLink?.url,
        sourceNetwork: primaryLink?.network,
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
      }

      if (_pendingPhoto == null &&
          _pendingMapImageUrl != null &&
          _pendingMapImageUrl!.isNotEmpty) {
        try {
          final res = await http.get(Uri.parse(_pendingMapImageUrl!));
          if (res.statusCode >= 200 && res.statusCode < 300) {
            final tmp = File(
              '${Directory.systemTemp.path}/chevere_map_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
            await tmp.writeAsBytes(res.bodyBytes);
            _pendingPhoto = tmp;
          }
        } catch (_) {}
      }

      if (_pendingPhoto != null) {
        try {
          await widget.savesRepository.uploadPhoto(
            siteId: saved.siteId,
            file: _pendingPhoto!,
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lugar guardado, pero la foto no se subió: ${userFacingError(e)}',
              ),
            ),
          );
        }
      }

      try {
        await widget.savesRepository.replaceSocialLinks(
          siteId: saved.siteId,
          links: _socialLinks,
        );
      } catch (_) {
        // Tabla puede no existir aún si no aplicaron migración 12.
      }

      if (saved.status == SiteStatus.complete) {
        await ref.read(draftReminderServiceProvider).cancelForSave(saved.id);
      } else if (saved.status == SiteStatus.draft) {
        await ref.read(draftReminderServiceProvider).scheduleForSave(
          saveId: saved.id,
          title: saved.siteName,
        );
      }

      if (!mounted) return;
      ref.invalidate(mySavesProvider);
      final l10n = context.l10n;
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
                l10n.saveStatusAfterSave(saved.status.label(l10n)),
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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.savePlaceEditTitle : l10n.savePlaceTitle,
        ),
      ),
      body: _loadingCats
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: _dec('Nombre del lugar', required: true),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                _label(
                  _isPhysical ? 'Ubicación' : 'Ubicación (opcional)',
                  required: _isPhysical,
                ),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Mapa'),
                      icon: Icon(Icons.map_outlined, size: 18),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Enlace Google'),
                      icon: Icon(Icons.link, size: 18),
                    ),
                  ],
                  selected: {_useGoogleLink},
                  onSelectionChanged: _saving
                      ? null
                      : (s) => setState(() => _useGoogleLink = s.first),
                ),
                const SizedBox(height: 12),
                if (!_useGoogleLink) ...[
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.touch_app_outlined,
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
                            : 'Toca el mapa o busca el lugar',
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
                ] else ...[
                  TextField(
                    controller: _mapsCtrl,
                    decoration: _dec(
                      'Pegar enlace de Google Maps',
                      helper: 'maps.app.goo.gl o google.com/maps',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: (_saving || _importingMaps)
                        ? null
                        : _importFromGoogleMaps,
                    icon: _importingMaps
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_outlined),
                    label: Text(
                      _importingMaps
                          ? 'Importando…'
                          : 'Importar del enlace',
                    ),
                  ),
                  if (_pendingMapImageUrl != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _pendingMapImageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 8),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: ValueKey('loc-$_locationPanelEpoch'),
                    initiallyExpanded: _locationDetailsExpanded,
                    maintainState: true,
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    onExpansionChanged: (v) =>
                        setState(() => _locationDetailsExpanded = v),
                    title: Text(
                      'Datos del lugar',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    subtitle: Text(
                      _locationSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                    children: [
                      TextField(
                        controller: _cityCtrl,
                        decoration: _dec('Ciudad'),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _deptCtrl,
                        decoration: _dec('Departamento'),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _addressCtrl,
                        decoration: _dec('Dirección'),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                // Enlaces redes
                _label('Enlaces de redes / web'),
                const SizedBox(height: 8),
                TextField(
                  controller: _socialCtrl,
                  decoration: _dec(
                    'Pegar enlace (IG, TikTok, FB…)',
                  ),
                  keyboardType: TextInputType.url,
                  onSubmitted: (v) async {
                    await _addSocialLink(v);
                    _socialCtrl.clear();
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: (_saving || _addingSocial)
                      ? null
                      : () async {
                          await _addSocialLink(_socialCtrl.text);
                          _socialCtrl.clear();
                        },
                  icon: _addingSocial
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_link),
                  label: const Text('Añadir enlace'),
                ),
                if (_socialLinks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ..._socialLinks.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SocialLinkPreviewCard(
                        draft: d,
                        loading: _addingSocial &&
                            d.title == null &&
                            d.imageUrl == null,
                        onRemove: _saving
                            ? null
                            : () => setState(() => _socialLinks.remove(d)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                // Categorías
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
                      : Text(
                          _isEditing
                              ? l10n.savePlaceSubmitEdit
                              : l10n.savePlaceSubmit,
                        ),
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
