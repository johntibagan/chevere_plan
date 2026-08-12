import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../admin/data/admin_models.dart';
import '../data/geo_place.dart';
import '../data/google_maps_link_importer.dart';
import '../data/place_geocoder.dart';
import '../data/save_models.dart';
import '../data/saves_repository.dart';
import '../data/share_parser.dart';
import '../data/social_link_models.dart';
import '../data/social_place_extractor.dart';
import '../domain/category_suggester.dart';
import '../domain/save_policies.dart';
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
  final _socialExtractor = SocialPlaceExtractor();
  final _mapsImporter = GoogleMapsLinkImporter();
  final _placeGeocoder = PlaceGeocoder();
  /// Si el usuario eligió/quitó categorías a mano, no sobrescribir la sugerencia.
  bool _categoriesUserTouched = false;
  bool _categoryWasAutoSuggested = false;

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
          _categoriesUserTouched = data.categoryIds.isNotEmpty;
          _categoryWasAutoSuggested = false;
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
        } else {
          _maybeSuggestCategories();
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
      _maybeSuggestCategories(force: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.hasCoords
                ? 'Datos de Google Maps aplicados (nombre, ubicación'
                    '${result.staticMapUrl != null ? ', mapa' : ''}'
                    ', categoría).'
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
      final hint = await _socialExtractor.extract(url);
      if (!mounted) return;
      setState(() {
        draft
          ..title = hint.title
          ..description = hint.description
          ..imageUrl = hint.imageUrl
          ..network = draft.network ?? hint.network;
        if ((_nameCtrl.text.trim().isEmpty ||
                _nameCtrl.text.trim() == 'Sin nombre') &&
            hint.suggestedPlaceName != null) {
          _nameCtrl.text = hint.suggestedPlaceName!;
        }
        _addingSocial = false;
      });
      _maybeSuggestCategories();
      unawaited(_tryFillLocationFromHint(hint));
    } catch (_) {
      if (!mounted) return;
      setState(() => _addingSocial = false);
    }
  }

  static final _venueCue = RegExp(
    r'restaurante|hotel|hostal|parque|museo|finca|termales|mirador|'
    r'cafeter[ií]a|caf[eé]|playa|plaza|iglesia|cascada|glamping|'
    r'bar |discoteca|piscina|tejo|mercado',
    caseSensitive: false,
  );

  bool get _hasFormLocation => SavePolicies.hasLocation(
        city: _cityCtrl.text,
        addressLine: _addressCtrl.text,
        latitude: _lat,
        longitude: _lng,
      );

  Future<void> _tryFillLocationFromHint(SocialPlaceHint hint) async {
    final name = hint.suggestedPlaceName;
    if (name == null || _hasFormLocation) return;
    if (!_venueCue.hasMatch(name) && !_venueCue.hasMatch(hint.haystack)) {
      return;
    }
    try {
      final hits = await _placeGeocoder.search('$name Colombia', limit: 1);
      if (!mounted || hits.isEmpty || _hasFormLocation) return;
      final place = hits.first;
      setState(() {
        _lat ??= place.lat;
        _lng ??= place.lng;
        if (_cityCtrl.text.trim().isEmpty && (place.city?.isNotEmpty ?? false)) {
          _cityCtrl.text = place.city!;
        }
        if (_deptCtrl.text.trim().isEmpty &&
            (place.department?.isNotEmpty ?? false)) {
          _deptCtrl.text = place.department!;
        }
        if (_addressCtrl.text.trim().isEmpty &&
            (place.addressLine?.isNotEmpty ?? false)) {
          _addressCtrl.text = place.addressLine!;
        }
      });
    } catch (_) {}
  }

  String _parentName(Category c) {
    if (c.parentId == null) return '';
    final parent = _categories.where((p) => p.id == c.parentId);
    return parent.isEmpty ? '' : parent.first.nameEs;
  }

  String get _categoryHaystack => [
        _nameCtrl.text,
        _cityCtrl.text,
        _deptCtrl.text,
        _addressCtrl.text,
        _mapsCtrl.text,
      ].join(' ');

  /// Sugiere y marca categoría según nombre / Maps; si no hay match → Otros.
  void _maybeSuggestCategories({bool force = false}) {
    if (_categories.isEmpty) return;
    if (!force && _categoriesUserTouched) return;

    final suggestion = CategorySuggester.suggest(
      categories: _categories,
      haystack: _categoryHaystack,
    );
    if (suggestion.categories.isEmpty) return;

    setState(() {
      _selectedCategoryIds
        ..clear()
        ..addAll(suggestion.categories.map((c) => c.id));
      _categoryWasAutoSuggested = true;
      if (force) _categoriesUserTouched = false;
    });
  }

  List<String> _resolvedCategoryIds() {
    if (_selectedCategoryIds.isNotEmpty) {
      return _selectedCategoryIds.toList();
    }
    final fallback = CategorySuggester.defaultCategory(_categories);
    if (fallback != null) return [fallback.id];
    final suggestion = CategorySuggester.suggest(
      categories: _categories,
      haystack: _categoryHaystack,
    );
    return suggestion.categories.map((c) => c.id).toList();
  }

  void _markCategoriesTouched() {
    _categoriesUserTouched = true;
    _categoryWasAutoSuggested = false;
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
      _markCategoriesTouched();
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
    _maybeSuggestCategories();
  }

  String get _locationSummary {
    final name = _nameCtrl.text.trim();
    final parts = <String>[
      if (name.isNotEmpty) name else 'Sin nombre',
      if (_cityCtrl.text.trim().isNotEmpty) _cityCtrl.text.trim(),
      if (_deptCtrl.text.trim().isNotEmpty) _deptCtrl.text.trim(),
      if (_addressCtrl.text.trim().isNotEmpty) _addressCtrl.text.trim(),
      if (_lat != null && _lng != null) 'Punto en mapa',
    ];
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

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final lat = _lat;
      final lng = _lng;
      final name = _nameCtrl.text.trim().isEmpty
          ? 'Sin nombre'
          : _nameCtrl.text.trim();
      final primaryLink =
          _socialLinks.isNotEmpty ? _socialLinks.first : null;

      final categoryIds = _resolvedCategoryIds();
      if (categoryIds.isEmpty) {
        setState(() {
          _saving = false;
          _error =
              'No hay categorías en la base. Aplica el seed / reseed de categorías.';
        });
        return;
      }
      if (_selectedCategoryIds.isEmpty) {
        setState(() {
          _selectedCategoryIds.addAll(categoryIds);
          _categoryWasAutoSuggested = true;
        });
      }

      final onlyDefault = categoryIds.every((id) {
        final cat = _categories.where((c) => c.id == id);
        if (cat.isEmpty) return false;
        final c = cat.first;
        return c.slug == CategorySuggester.defaultChildSlug ||
            c.slug == CategorySuggester.defaultParentSlug;
      });
      final categoryIsExplicit =
          _categoriesUserTouched && !onlyDefault;

      final input = SaveDraftInput(
        name: name,
        sourceUrl: primaryLink?.url,
        sourceNetwork: primaryLink?.network,
        city: _cityCtrl.text,
        department: _deptCtrl.text,
        addressLine: _addressCtrl.text,
        latitude: lat,
        longitude: lng,
        categoryIds: categoryIds,
        isPublic: _isPublic && _hasFormLocation,
        isPhysicalPlace: _isPhysical,
        categoryIsExplicit: categoryIsExplicit,
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
            isPublic: input.isPublic,
            isPhysicalPlace: _isPhysical,
            linkToExistingSiteId: linkToExisting,
            categoryIsExplicit: categoryIsExplicit,
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
      } else {
        await ref.read(draftReminderServiceProvider).scheduleForSave(
          saveId: saved.id,
          title: saved.siteName,
        );
      }

      if (!mounted) return;
      ref.invalidate(mySavesProvider);
      final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (uid != null) {
        unawaited(
          ref
              .read(entityCacheStoreProvider)
              .invalidate(CacheKeys.mySavesSummary(uid)),
        );
      }
      if (saved.siteId.isNotEmpty) {
        unawaited(
          ref
              .read(entityCacheStoreProvider)
              .invalidate(CacheKeys.siteFicha(saved.siteId)),
        );
        ref.invalidate(siteFichaProvider(saved.siteId));
      }
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

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // 1) Ubicación primero
                _sectionCard(
                  title: '1. Ubicación (opcional)',
                  children: [
                    const Text(
                      'Si no la tienes aún, guarda igual: queda en borrador.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    if (!_useGoogleLink) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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
                        AppNetworkImage(
                          url: _pendingMapImageUrl!,
                          cacheKey: 'map:${_pendingMapImageUrl!}',
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ],
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        key: ValueKey('loc-$_locationPanelEpoch'),
                        initiallyExpanded: _locationDetailsExpanded,
                        maintainState: true,
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(bottom: 4),
                        onExpansionChanged: (v) =>
                            setState(() => _locationDetailsExpanded = v),
                        title: const Text(
                          'Nombre y detalles',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          _locationSummary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                        children: [
                          TextField(
                            controller: _nameCtrl,
                            decoration: _dec(
                              'Nombre del lugar',
                              helper:
                                  'Opcional. Se completa del mapa o queda “Sin nombre”',
                            ),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) => setState(() {}),
                            onEditingComplete: () {
                              _maybeSuggestCategories();
                              FocusScope.of(context).unfocus();
                            },
                            onSubmitted: (_) => _maybeSuggestCategories(),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _cityCtrl,
                            decoration: _dec('Ciudad'),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _deptCtrl,
                            decoration: _dec('Departamento'),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _addressCtrl,
                            decoration: _dec('Dirección'),
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 2) Enlaces
                _sectionCard(
                  title: '2. Enlaces (opcional)',
                  children: [
                    TextField(
                      controller: _socialCtrl,
                      decoration: _dec('Pegar enlace (IG, TikTok, FB…)'),
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
                      const SizedBox(height: 8),
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
                                : () =>
                                    setState(() => _socialLinks.remove(d)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // 3) Categorías (sugeridas; default Otros si no hay match)
                _sectionCard(
                  title: '3. Categorías',
                  children: [
                    if (_categoryWasAutoSuggested &&
                        _selectedCategories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          _selectedCategories.any(
                                (c) =>
                                    c.slug ==
                                        CategorySuggester.defaultChildSlug ||
                                    c.slug ==
                                        CategorySuggester.defaultParentSlug,
                              )
                              ? 'Sin coincidencia clara → Otros (puedes cambiarla)'
                              : 'Sugerida según el nombre / Maps (puedes cambiarla)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
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
                                : () => setState(() {
                                      _markCategoriesTouched();
                                      _selectedCategoryIds.remove(c.id);
                                    }),
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
                              _markCategoriesTouched();
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
                                'Se sugiere sola; o busca / abre el árbol.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _saving ? null : _openCategoryTree,
                              icon: const Icon(
                                Icons.account_tree_outlined,
                                size: 18,
                              ),
                              label: const Text('Árbol'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // 4) Opciones
                _sectionCard(
                  title: '4. Visibilidad y foto',
                  children: [
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
                      subtitle: Text(
                        !_isPhysical
                            ? 'Los contenidos no físicos quedan privados'
                            : !_hasFormLocation
                                ? 'Primero indica ubicación para poder publicarlo'
                                : 'Visible para otros en la capa pública',
                      ),
                      value: _isPublic,
                      onChanged: (_isPhysical && _hasFormLocation)
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
                  ],
                ),

                if (_error != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
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
                Text(
                  'Puedes guardar ya: sin ubicación queda en borrador y te '
                  'recordaremos completarlo.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}
