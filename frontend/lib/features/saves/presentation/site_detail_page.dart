import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/site_cover.dart';
import '../../../core/widgets/site_origin_tags.dart';
import '../../../core/widgets/tab_screen_header.dart';
import '../../../core/widgets/visibility_badge.dart';
import '../../auth/data/profile.dart';
import '../../moderation/data/moderation_models.dart';
import '../../search/data/search_models.dart';
import '../data/google_maps_links.dart';
import '../data/save_models.dart';
import '../data/site_ficha.dart';
import '../data/social_link_models.dart';
import 'favorite_heart_button.dart';
import 'save_place_page.dart';
import 'site_reviews_tab.dart';
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
  bool _isStaff = false;
  AppRole? _staffRole;
  String? _uid;

  List<SitePhoto> _photos = const [];
  final Map<String, String> _photoUrls = {};
  bool _photosLoading = true;
  bool _photosBusy = false;
  List<SiteSocialLink> _socialLinks = const [];

  bool get _canEditSite {
    final f = _ficha;
    if (f == null) return false;
    return f.isOwn || f.isCreatorOf(_uid) || _isStaff;
  }

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
    _loadStaffFlag();
    _load();
  }

  Future<void> _loadStaffFlag() async {
    try {
      final client = ref.read(supabaseClientProvider);
      final uid = client.auth.currentUser?.id;
      final p = await ref.read(profileRepositoryProvider).fetchCurrent();
      if (!mounted) return;
      setState(() {
        _uid = uid;
        _isStaff = p?.role.isStaff ?? false;
        _staffRole = p?.role.isStaff == true ? p!.role : null;
      });
    } catch (_) {}
  }

  String _staffRoleLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (_staffRole) {
      AppRole.root => l10n.staffRoleRoot,
      AppRole.admin => l10n.staffRoleAdmin,
      _ => l10n.staffRoleAdmin,
    };
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
        _error = 'failed';
        _loading = false;
      });
      AppToast.error(context, e, logContext: 'site_detail');
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
    final ficha = _ficha;
    if (ficha == null || !_canEditSite) return;
    final save = ficha.ownSave;
    final editSiteOnly =
        save == null && (ficha.isCreatorOf(_uid) || _isStaff);
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder: (_) => SavePlacePage(
          existingSaveId: save?.id,
          existingSiteId: editSiteOnly ? ficha.siteId : null,
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
      AppToast.error(context, e);
    }
  }

  Future<void> _openUrl(String? raw) async {
    final url = raw?.trim();
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  bool _canOpenMaps(SiteFicha? ficha) {
    if (ficha == null) return false;
    if (ficha.lat != null && ficha.lng != null) return true;
    if ((ficha.googlePlaceId ?? '').trim().isNotEmpty) return true;
    return ficha.name.trim().isNotEmpty;
  }

  Future<void> _openPlaceOnMaps(SiteFicha ficha) async {
    await _openMapsFor(ficha, directions: false);
  }

  Future<void> _openDirectionsOnMaps(SiteFicha ficha) async {
    await _openMapsFor(ficha, directions: true);
  }

  Future<void> _openMapsFor(SiteFicha ficha, {required bool directions}) async {
    if (!_canOpenMaps(ficha)) {
      if (!mounted) return;
      AppToast.show(context, context.l10n.siteDetailNoCoords, error: true);
      return;
    }
    SiteFicha f = ficha;
    try {
      f = await ref.read(savesRepositoryProvider).loadSiteFicha(ficha.siteId);
    } catch (_) {}
    final lat = f.lat ?? ficha.lat;
    final lng = f.lng ?? ficha.lng;
    final exact = f.useExactPin;
    if (exact && (lat == null || lng == null)) {
      if (!mounted) return;
      AppToast.show(context, context.l10n.siteDetailNoCoords, error: true);
      return;
    }
    final uri = directions
        ? GoogleMapsLinks.directionsTo(
            name: f.name,
            city: f.city,
            department: f.department,
            googlePlaceId: f.googlePlaceId,
            lat: lat,
            lng: lng,
            useExactPin: exact,
          )
        : GoogleMapsLinks.viewPlace(
            name: f.name,
            city: f.city,
            department: f.department,
            googlePlaceId: f.googlePlaceId,
            lat: lat,
            lng: lng,
            useExactPin: exact,
          );
    await _launchMapsUri(uri);
  }

  Future<void> _launchMapsUri(Uri httpsUri) async {
    final ok = await launchUrl(httpsUri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      AppToast.show(context, context.l10n.siteDetailOpenMapsFail, error: true);
    }
  }

  Future<void> _addPhoto() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.loginTerms),
        content: Text(context.l10n.photoTermsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionAcceptContinue),
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
      AppToast.show(context, context.l10n.photoAdded);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => _photosBusy = false);
    }
  }

  Future<void> _deletePhoto(SitePhoto photo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.photoDeleteTitle),
        content: Text(context.l10n.photoDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionDelete),
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
      AppToast.show(context, context.l10n.photoDeleted);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => _photosBusy = false);
    }
  }

  Future<void> _reportPhoto(SitePhoto photo) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.photoReportTitle),
        content: TextField(
          controller: reasonCtrl,
          decoration: InputDecoration(
            labelText: context.l10n.photoReportReason,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.photoReportSend),
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
      AppToast.show(context, context.l10n.photoReportSent);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e);
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
        key: WidgetKeys.siteDetailPage,
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Row(
                  children: [
                    AppRoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(_outcome),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ficha?.name ?? l10n.siteDetailTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    FavoriteHeartButton(
                      siteId: widget.siteId,
                      style: FavoriteHeartStyle.icon,
                    ),
                    if (_canEditSite)
                      PopupMenuButton<String>(
                        tooltip: l10n.actionEdit,
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
                            key: WidgetKeys.siteDetailEdit,
                            value: 'edit',
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.edit_outlined),
                              title: Text(l10n.actionEdit),
                            ),
                          ),
                          if (ficha?.isOwn == true)
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
                ),
              ),
            ),
            if (ficha != null)
              SizedBox(
                height: 176,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SiteCover(
                      imageUrl: _photoUrls.values
                              .where((u) => u.isNotEmpty)
                              .isEmpty
                          ? null
                          : _photoUrls.values
                              .firstWhere((u) => u.isNotEmpty),
                      cacheKey: _photos.isEmpty ? null : _photos.first.id,
                    ),
                    const SiteCoverScrim(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 4,
                        color: (ficha.isOwn ? ficha.isPublic : true)
                            ? AppColors.success
                            : AppColors.purple,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
                      child: Row(
                        children: [
                          VisibilityBadge(
                            isPublic: ficha.isOwn ? ficha.isPublic : true,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SiteOriginTags(
                              isOwn: ficha.isOwn,
                              isLinked: false,
                              isCatalog: ficha.isCatalogSite,
                            ),
                          ),
                          if (ficha.estimatedPriceAmount != null)
                            Text(
                              formatMoney(
                                ficha.estimatedPriceAmount!,
                                currencyCode: ficha.currencyCode,
                              ),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            TabBar(
              controller: _tabs,
              tabs: [
                Tab(text: l10n.siteDetailTabInfo),
                Tab(text: l10n.siteDetailTabReviews),
                Tab(text: l10n.siteDetailTabMore),
              ],
            ),
            Expanded(
              child: _loading && ficha == null
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null && ficha == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.errorLoadRetry,
                            textAlign: TextAlign.center,
                          ),
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
                        isStaff: _isStaff,
                        staffRoleLabel:
                            _isStaff ? _staffRoleLabel(context) : null,
                        onAddPhoto:
                            (ficha.isOwn ||
                                    ficha.isCreatorOf(_uid) ||
                                    _isStaff)
                                ? _addPhoto
                                : null,
                        onPhotoMenu: _onPhotoMenu,
                        onOpenLink: _openUrl,
                        onOpenPlaceOnMaps: _canOpenMaps(ficha)
                            ? () => _openPlaceOnMaps(ficha)
                            : null,
                        onOpenDirectionsOnMaps: _canOpenMaps(ficha)
                            ? () => _openDirectionsOnMaps(ficha)
                            : null,
                      ),
                      SiteReviewsTab(
                        siteId: widget.siteId,
                        siteName: ficha.name,
                        siteIsPublic: ficha.isPublic,
                        isStaff: _isStaff,
                        staffRoleLabel:
                            _isStaff ? _staffRoleLabel(context) : null,
                      ),
                      _TraceabilityTab(ficha: ficha),
                    ],
                  ),
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
    this.isStaff = false,
    this.staffRoleLabel,
    this.onAddPhoto,
    this.onOpenPlaceOnMaps,
    this.onOpenDirectionsOnMaps,
  });

  final SiteFicha ficha;
  final List<SitePhoto> photos;
  final Map<String, String> photoUrls;
  final bool photosLoading;
  final bool photosBusy;
  final List<SiteSocialLink> socialLinks;
  final void Function(SitePhoto photo, String action) onPhotoMenu;
  final void Function(String? url) onOpenLink;
  final bool isStaff;
  final String? staffRoleLabel;
  final VoidCallback? onAddPhoto;
  final VoidCallback? onOpenPlaceOnMaps;
  final VoidCallback? onOpenDirectionsOnMaps;

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
        if (isStaff) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.staffModeBanner(
                      staffRoleLabel ?? l10n.staffRoleAdmin,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
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
              // Privacidad del lugar (sites), no del checkbox del form al vincular.
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
        if (location.isNotEmpty ||
            onOpenPlaceOnMaps != null ||
            onOpenDirectionsOnMaps != null) ...[
          const SizedBox(height: 20),
          _Section(
            icon: Icons.place_outlined,
            title: l10n.siteDetailLocation,
            trailing: (onOpenPlaceOnMaps == null &&
                    onOpenDirectionsOnMaps == null)
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onOpenPlaceOnMaps != null)
                        IconButton(
                          tooltip: l10n.siteDetailOpenInMaps,
                          onPressed: onOpenPlaceOnMaps,
                          style: IconButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.12),
                          ),
                          icon: const Icon(Icons.place_outlined),
                        ),
                      if (onOpenDirectionsOnMaps != null)
                        IconButton(
                          tooltip: l10n.siteDetailDirections,
                          onPressed: onOpenDirectionsOnMaps,
                          style: IconButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.12),
                          ),
                          icon: const Icon(Icons.directions_outlined),
                        ),
                    ],
                  ),
            child: location.isNotEmpty
                ? Text(location, style: const TextStyle(color: AppColors.muted))
                : Text(
                    l10n.siteDetailNoCoords,
                    style: const TextStyle(color: AppColors.muted),
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
      ],
    );
  }
}

class _TraceabilityTab extends StatelessWidget {
  const _TraceabilityTab({required this.ficha});

  final SiteFicha ficha;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final creator = ficha.createdByPerson;
    final also = ficha.alsoSharedPeople;
    final createdAt = ficha.siteCreatedAt;
    final updatedAt = ficha.siteUpdatedAt;
    final ownSavedAt = ficha.ownSave?.createdAt;
    final hasAny = creator != null ||
        also.isNotEmpty ||
        createdAt != null ||
        updatedAt != null ||
        ficha.isCatalogSite ||
        ownSavedAt != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (ficha.isCatalogSite) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.public, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.siteDetailCatalogBadge,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (creator != null) ...[
          _Section(
            icon: Icons.person_outline,
            title: l10n.siteDetailCreatedBy,
            child: _PersonAvatar(person: creator, showJoinedHint: false),
          ),
          const SizedBox(height: 16),
        ],
        if (also.isNotEmpty) ...[
          _Section(
            icon: Icons.people_outline,
            title: l10n.siteDetailAlsoShared,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final person in also)
                  _PersonAvatar(person: person, showJoinedHint: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (createdAt != null) ...[
          _TraceRow(
            label: l10n.siteDetailCreatedAt,
            value: formatDateTimeShort(createdAt),
          ),
          const SizedBox(height: 10),
        ],
        if (updatedAt != null) ...[
          _TraceRow(
            label: l10n.siteDetailUpdatedAt,
            value: formatDateTimeShort(updatedAt),
          ),
          const SizedBox(height: 10),
        ],
        if (ownSavedAt != null) ...[
          _TraceRow(
            label: l10n.siteDetailYourSaveAt(formatDateTimeShort(ownSavedAt)),
            value: '',
          ),
          const SizedBox(height: 10),
        ],
        if (!hasAny)
          Text(
            l10n.siteDetailTraceEmpty,
            style: const TextStyle(color: AppColors.muted),
          ),
      ],
    );
  }
}

class _TraceRow extends StatelessWidget {
  const _TraceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
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
              color: AppColors.scrim,
              shape: const CircleBorder(),
              child: PopupMenuButton<String>(
                enabled: !busy,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert, color: AppColors.onImage, size: 20),
                onSelected: onMenu,
                itemBuilder: (context) {
                  final l10n = context.l10n;
                  return [
                    if (canDelete)
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.delete_outline),
                          title: Text(l10n.actionDelete),
                        ),
                      ),
                    PopupMenuItem(
                      value: 'report',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.flag_outlined),
                        title: Text(l10n.actionReport),
                      ),
                    ),
                  ];
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({
    required this.person,
    this.showJoinedHint = false,
  });

  final SitePerson person;
  final bool showJoinedHint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final url = person.avatarUrl?.trim();
    final hasUrl = url != null && url.isNotEmpty;
    var tip = person.tooltipName;
    if (showJoinedHint && person.joinedAt != null) {
      tip =
          '$tip · ${l10n.siteDetailJoinedAt(formatDateTimeShort(person.joinedAt!))}';
    }
    return Tooltip(
      message: tip,
      triggerMode: TooltipTriggerMode.tap,
      child: ClipOval(
        child: SizedBox(
          width: 36,
          height: 36,
          child: hasUrl
              ? AppNetworkImage(
                  url: url,
                  width: 36,
                  height: 36,
                  cacheKey: 'avatar:${person.userId}',
                  fit: BoxFit.cover,
                )
              : const ColoredBox(
                  color: AppColors.surfaceElevated,
                  child: Icon(Icons.person, size: 20, color: AppColors.muted),
                ),
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
