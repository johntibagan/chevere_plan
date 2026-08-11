import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/visibility_badge.dart';
import '../../moderation/data/moderation_models.dart';
import '../../search/data/search_models.dart';
import '../data/save_models.dart';
import '../data/site_ficha.dart';
import '../data/social_link_models.dart';
import 'save_place_page.dart';
import 'site_status_l10n.dart';
import 'social_link_preview_card.dart';

/// Ficha de sitio: info + galería + acciones en menú + pestañas futuras.
class SiteDetailPage extends ConsumerStatefulWidget {
  const SiteDetailPage({
    super.key,
    required this.siteId,
    this.initialSave,
    this.initialHit,
  });

  final String siteId;
  final UserSave? initialSave;
  final SearchHit? initialHit;

  @override
  ConsumerState<SiteDetailPage> createState() => _SiteDetailPageState();
}

class _SiteDetailPageState extends ConsumerState<SiteDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  SiteFicha? _ficha;
  bool _loading = true;
  String? _error;
  var _outcome = SiteDetailOutcome.none;

  List<SitePhoto> _photos = const [];
  final Map<String, String> _photoUrls = {};
  bool _photosLoading = true;
  bool _photosBusy = false;
  List<SiteSocialLink> _socialLinks = const [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    if (widget.initialSave != null) {
      _ficha = SiteFicha.fromSave(widget.initialSave!);
      _loading = false;
    } else if (widget.initialHit != null) {
      _ficha = SiteFicha.fromSearchHit(widget.initialHit!);
      _loading = false;
    }
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final hasSeed = _ficha != null;
    setState(() {
      _loading = !hasSeed;
      _error = null;
    });
    try {
      // SWR vía Riverpod: caché inmediata + refresh en background.
      final ficha = await ref.read(siteFichaProvider(widget.siteId).future);
      if (!mounted) return;
      setState(() {
        _ficha = ficha.copyWithMeta(
          estimatedPriceAmount: ficha.estimatedPriceAmount ??
              widget.initialHit?.estimatedPriceAmount,
          currencyCode: widget.initialHit?.currencyCode ?? ficha.currencyCode,
          distanceKm: ficha.distanceKm ?? widget.initialHit?.distanceKm,
          lat: ficha.lat ?? widget.initialHit?.lat,
          lng: ficha.lng ?? widget.initialHit?.lng,
        );
        _loading = false;
      });
      await Future.wait([_loadPhotos(), _loadSocialLinks()]);
    } catch (e) {
      if (!mounted) return;
      if (_ficha != null) {
        setState(() => _loading = false);
        await Future.wait([_loadPhotos(), _loadSocialLinks()]);
        return;
      }
      setState(() {
        _error = userFacingError(e);
        _loading = false;
      });
    }
  }

  Future<void> _loadPhotos() async {
    setState(() => _photosLoading = true);
    try {
      final moderation = ref.read(moderationRepositoryProvider);
      final photos = await moderation.listSitePhotos(widget.siteId);
      final urls = await moderation.signedPhotoUrlsParallel(
        photos.map((p) => (id: p.id, storagePath: p.storagePath)),
      );
      if (!mounted) return;
      setState(() {
        _photos = photos;
        _photoUrls
          ..clear()
          ..addAll(urls);
        _photosLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _photosLoading = false);
    }
  }

  Future<void> _loadSocialLinks() async {
    try {
      final links = await ref
          .read(savesRepositoryProvider)
          .listSocialLinks(widget.siteId);
      if (!mounted) return;
      if (links.isNotEmpty) {
        setState(() => _socialLinks = links);
        return;
      }
      final fallback = _ficha?.sourceUrl?.trim();
      if (fallback != null && fallback.isNotEmpty) {
        setState(() {
          _socialLinks = [
            SiteSocialLink(
              id: 'legacy',
              siteId: widget.siteId,
              url: fallback,
            ),
          ];
        });
      } else {
        setState(() => _socialLinks = const []);
      }
    } catch (_) {
      // Migración 12 puede no estar aplicada aún.
      if (!mounted) return;
      final fallback = _ficha?.sourceUrl?.trim();
      if (fallback != null && fallback.isNotEmpty) {
        setState(() {
          _socialLinks = [
            SiteSocialLink(
              id: 'legacy',
              siteId: widget.siteId,
              url: fallback,
            ),
          ];
        });
      }
    }
  }

  Future<void> _edit() async {
    final save = _ficha?.ownSave;
    if (save == null) return;
    final result = await Navigator.of(context).push<UserSave>(
      MaterialPageRoute(
        builder: (_) => SavePlacePage(
          existingSaveId: save.id,
          savesRepository: ref.read(savesRepositoryProvider),
        ),
      ),
    );
    if (result != null && mounted) {
      _outcome = SiteDetailOutcome.updated;
      await ref.read(siteFichaProvider(widget.siteId).notifier).refresh(force: true);
      await _load();
    }
  }

  Future<void> _discard() async {
    final save = _ficha?.ownSave;
    if (save == null) return;
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.homeDiscardTitle),
        content: Text(l10n.homeDiscardConfirm(save.siteName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionDiscard),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(draftReminderServiceProvider).cancelForSave(save.id);
      await ref.read(savesRepositoryProvider).discardSave(save.id);
      if (!mounted) return;
      Navigator.of(context).pop(SiteDetailOutcome.deleted);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _openUrl(String? raw) async {
    final url = raw?.trim();
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _addPhoto() async {
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

    setState(() => _photosBusy = true);
    try {
      await ref.read(savesRepositoryProvider).uploadPhoto(
            siteId: widget.siteId,
            file: File(picked.path),
          );
      await _loadPhotos();
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
      if (mounted) setState(() => _photosBusy = false);
    }
  }

  Future<void> _deletePhoto(SitePhoto photo) async {
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

    setState(() => _photosBusy = true);
    try {
      await ref.read(moderationRepositoryProvider).deletePhoto(photo);
      await _loadPhotos();
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
      if (mounted) setState(() => _photosBusy = false);
    }
  }

  Future<void> _reportPhoto(SitePhoto photo) async {
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
      await ref.read(moderationRepositoryProvider).reportPhoto(
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

  void _onPhotoMenu(SitePhoto photo, String action) {
    switch (action) {
      case 'delete':
        _deletePhoto(photo);
      case 'report':
        _reportPhoto(photo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ficha = _ficha;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_outcome);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            ficha?.name ?? l10n.siteDetailTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_outcome),
          ),
          actions: [
            if (ficha?.isOwn == true)
              PopupMenuButton<String>(
                tooltip: 'Acciones',
                onSelected: (v) {
                  switch (v) {
                    case 'edit':
                      _edit();
                    case 'discard':
                      _discard();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l10n.actionEdit),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'discard',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete_outline),
                      title: Text(l10n.actionDiscard),
                    ),
                  ),
                ],
              ),
          ],
          bottom: TabBar(
            controller: _tabs,
            tabs: [
              Tab(text: l10n.siteDetailTabInfo),
              Tab(text: l10n.siteDetailTabReviews),
              Tab(text: l10n.siteDetailTabMore),
            ],
          ),
        ),
        body: _loading && ficha == null
            ? const Center(child: CircularProgressIndicator())
            : _error != null && ficha == null
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
                            child: Text(l10n.actionRetry),
                          ),
                        ],
                      ),
                    ),
                  )
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _InfoTab(
                        ficha: ficha!,
                        photos: _photos,
                        photoUrls: _photoUrls,
                        photosLoading: _photosLoading,
                        photosBusy: _photosBusy,
                        socialLinks: _socialLinks,
                        onAddPhoto: ficha.isOwn ? _addPhoto : null,
                        onPhotoMenu: _onPhotoMenu,
                        onOpenLink: _openUrl,
                        onOpenInGoogleMaps: (ficha.lat != null && ficha.lng != null)
                            ? () => _openInGoogleMaps(ficha.lat!, ficha.lng!)
                            : null,
                      ),
                      _PlaceholderTab(
                        title: l10n.siteDetailReviewsSoonTitle,
                        body: l10n.siteDetailReviewsSoonBody,
                      ),
                      _PlaceholderTab(
                        title: l10n.siteDetailMoreSoonTitle,
                        body: l10n.siteDetailMoreSoonBody,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.ficha,
    required this.photos,
    required this.photoUrls,
    required this.photosLoading,
    required this.photosBusy,
    required this.socialLinks,
    required this.onPhotoMenu,
    required this.onOpenLink,
    this.onAddPhoto,
    this.onOpenInGoogleMaps,
  });

  final SiteFicha ficha;
  final List<SitePhoto> photos;
  final Map<String, String> photoUrls;
  final bool photosLoading;
  final bool photosBusy;
  final List<SiteSocialLink> socialLinks;
  final void Function(SitePhoto photo, String action) onPhotoMenu;
  final void Function(String? url) onOpenLink;
  final VoidCallback? onAddPhoto;
  final VoidCallback? onOpenInGoogleMaps;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final location = ficha.locationLine;
    final legacySource = ficha.sourceUrl?.trim();
    final showLegacySource = (legacySource != null &&
            legacySource.isNotEmpty) &&
        socialLinks.every((l) => l.url != legacySource);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          ficha.name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            VisibilityBadge(
              isPublic: ficha.isOwn ? ficha.isPublic : true,
            ),
            if (ficha.isOwn && ficha.ownSave != null)
              _Chip(label: ficha.ownSave!.status.label(l10n)),
            if (ficha.isOwn) _Chip(label: l10n.labelOwn),
            if (!ficha.isPhysicalPlace)
              _Chip(label: l10n.siteDetailNotPhysical),
          ],
        ),
        const SizedBox(height: 20),
        _GallerySection(
          photos: photos,
          photoUrls: photoUrls,
          loading: photosLoading,
          busy: photosBusy,
          canManage: onAddPhoto != null,
          onAddPhoto: onAddPhoto,
          onPhotoMenu: onPhotoMenu,
        ),
        if (location.isNotEmpty || onOpenInGoogleMaps != null) ...[
          const SizedBox(height: 20),
          _Section(
            icon: Icons.place_outlined,
            title: l10n.siteDetailLocation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (location.isNotEmpty)
                  Text(location, style: const TextStyle(color: AppColors.muted)),
                if (onOpenInGoogleMaps != null) ...[
                  if (location.isNotEmpty) const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: onOpenInGoogleMaps,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Abrir en Google Maps'),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (ficha.categoryNames.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(
            icon: Icons.category_outlined,
            title: l10n.siteDetailCategories,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ficha.categoryNames
                  .map(
                    (c) => Chip(
                      label: Text(c),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        if (ficha.estimatedPriceAmount != null) ...[
          const SizedBox(height: 16),
          _Section(
            icon: Icons.payments_outlined,
            title: l10n.siteDetailPrice,
            child: Text(
              formatMoney(
                ficha.estimatedPriceAmount!,
                currencyCode: ficha.currencyCode,
              ),
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        ],
        if (ficha.distanceKm != null) ...[
          const SizedBox(height: 16),
          _Section(
            icon: Icons.near_me_outlined,
            title: l10n.siteDetailDistance,
            child: Text(
              '${ficha.distanceKm!.toStringAsFixed(1)} km',
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        ],
        if (socialLinks.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(
            icon: Icons.link,
            title: 'Enlaces',
            child: Column(
              children: socialLinks
                  .map(
                    (l) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SocialLinkPreviewCard(
                        draft: SocialLinkDraft(
                          url: l.url,
                          network: l.network,
                          title: l.title,
                          description: l.description,
                          imageUrl: l.imageUrl,
                          existingId: l.id,
                        ),
                        onTap: () => onOpenLink(l.url),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        if (showLegacySource) ...[
          const SizedBox(height: 16),
          _Section(
            icon: Icons.link,
            title: l10n.siteDetailSource,
            child: InkWell(
              onTap: () => onOpenLink(legacySource),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  legacySource,
                  style: const TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
        if (ficha.notes != null && ficha.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(
            icon: Icons.notes_outlined,
            title: l10n.siteDetailNotes,
            child: Text(
              ficha.notes!,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        ],
        if (ficha.alsoSharedBy.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(
            icon: Icons.people_outline,
            title: l10n.siteDetailAlsoShared,
            child: Text(
              ficha.alsoSharedBy.join(', '),
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        ],
      ],
    );
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection({
    required this.photos,
    required this.photoUrls,
    required this.loading,
    required this.busy,
    required this.canManage,
    required this.onPhotoMenu,
    this.onAddPhoto,
  });

  final List<SitePhoto> photos;
  final Map<String, String> photoUrls;
  final bool loading;
  final bool busy;
  final bool canManage;
  final void Function(SitePhoto photo, String action) onPhotoMenu;
  final VoidCallback? onAddPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _Section(
      icon: Icons.photo_library_outlined,
      title: l10n.siteDetailPhotos,
      trailing: canManage
          ? IconButton(
              tooltip: 'Añadir foto',
              onPressed: busy ? null : onAddPhoto,
              icon: const Icon(Icons.add_a_photo_outlined, size: 20),
            )
          : null,
      child: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : photos.isEmpty
              ? Text(
                  canManage
                      ? 'Sin fotos. Usa el icono de cámara para añadir.'
                      : 'Este sitio no tiene fotos.',
                  style: const TextStyle(color: AppColors.muted),
                )
              : SizedBox(
                  height: 148,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      final url = photoUrls[photo.id];
                      return _PhotoTile(
                        url: url,
                        cacheKey: photo.id,
                        canDelete: canManage,
                        busy: busy,
                        onMenu: (action) => onPhotoMenu(photo, action),
                      );
                    },
                  ),
                ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.url,
    required this.cacheKey,
    required this.canDelete,
    required this.busy,
    required this.onMenu,
  });

  final String? url;
  final String cacheKey;
  final bool canDelete;
  final bool busy;
  final ValueChanged<String> onMenu;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: url != null && url!.isNotEmpty
                  ? AppNetworkImage(
                      url: url!,
                      cacheKey: cacheKey,
                      width: 140,
                      height: 148,
                      fit: BoxFit.cover,
                    )
                  : ColoredBox(
                      color: AppColors.surfaceElevated,
                      child: const Icon(
                        Icons.broken_image,
                        color: AppColors.muted,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: PopupMenuButton<String>(
                enabled: !busy,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                onSelected: onMenu,
                itemBuilder: (context) => [
                  if (canDelete)
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline),
                        title: Text('Eliminar'),
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'report',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.flag_outlined),
                      title: Text('Reportar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction_outlined,
              size: 40,
              color: AppColors.muted,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.foreground,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.muted),
      ),
    );
  }
}
