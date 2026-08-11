import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../moderation/presentation/site_photos_sheet.dart';
import '../../search/data/search_models.dart';
import '../data/save_models.dart';
import '../data/site_ficha.dart';
import 'save_place_page.dart';
import 'site_status_l10n.dart';

/// Ficha de sitio: info + acciones (editar/eliminar si es propio) + pestañas futuras.
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
    setState(() {
      _loading = _ficha == null;
      _error = null;
    });
    try {
      final ficha =
          await ref.read(savesRepositoryProvider).loadSiteFicha(widget.siteId);
      if (!mounted) return;
      setState(() {
        _ficha = ficha.copyWithMeta(
          estimatedPriceAmount:
              ficha.estimatedPriceAmount ?? widget.initialHit?.estimatedPriceAmount,
          currencyCode: widget.initialHit?.currencyCode ?? ficha.currencyCode,
          distanceKm: ficha.distanceKm ?? widget.initialHit?.distanceKm,
        );
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (_ficha != null) {
        setState(() => _loading = false);
        return;
      }
      setState(() {
        _error = userFacingError(e);
        _loading = false;
      });
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

  Future<void> _openPhotos() async {
    final ficha = _ficha;
    if (ficha == null) return;
    await showSitePhotosSheet(
      context: context,
      siteId: ficha.siteId,
      siteName: ficha.name,
      repository: ref.read(moderationRepositoryProvider),
      canManage: ficha.isOwn,
    );
  }

  Future<void> _openSource() async {
    final url = _ficha?.sourceUrl?.trim();
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
            if (ficha?.isOwn == true) ...[
              IconButton(
                tooltip: l10n.actionEdit,
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: l10n.actionDiscard,
                onPressed: _discard,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
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
                        onPhotos: _openPhotos,
                        onEdit: ficha.isOwn ? _edit : null,
                        onDiscard: ficha.isOwn ? _discard : null,
                        onOpenSource: ficha.sourceUrl != null &&
                                ficha.sourceUrl!.trim().isNotEmpty
                            ? _openSource
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
    required this.onPhotos,
    this.onEdit,
    this.onDiscard,
    this.onOpenSource,
  });

  final SiteFicha ficha;
  final VoidCallback onPhotos;
  final VoidCallback? onEdit;
  final VoidCallback? onDiscard;
  final VoidCallback? onOpenSource;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final location = ficha.locationLine;

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
            if (ficha.isOwn && ficha.ownSave != null)
              _Chip(label: ficha.ownSave!.status.label(l10n)),
            _Chip(
              label: ficha.isOwn
                  ? (ficha.isPublic
                      ? l10n.visibilityPublic
                      : l10n.visibilityPrivate)
                  : l10n.visibilityPublic,
            ),
            if (ficha.isOwn) _Chip(label: l10n.labelOwn),
            if (!ficha.isPhysicalPlace)
              _Chip(label: l10n.siteDetailNotPhysical),
          ],
        ),
        if (location.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(
            icon: Icons.place_outlined,
            title: l10n.siteDetailLocation,
            child: Text(location, style: const TextStyle(color: AppColors.muted)),
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
                  .map((c) => Chip(label: Text(c), visualDensity: VisualDensity.compact))
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
        if (ficha.notes != null && ficha.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(
            icon: Icons.notes_outlined,
            title: l10n.siteDetailNotes,
            child: Text(ficha.notes!, style: const TextStyle(color: AppColors.muted)),
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
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onPhotos,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.siteDetailPhotos),
            ),
            if (onOpenSource != null)
              OutlinedButton.icon(
                onPressed: onOpenSource,
                icon: const Icon(Icons.link),
                label: Text(l10n.siteDetailSource),
              ),
            if (onEdit != null)
              FilledButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.actionEdit),
              ),
            if (onDiscard != null)
              OutlinedButton.icon(
                onPressed: onDiscard,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.actionDiscard),
              ),
          ],
        ),
      ],
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
            Icon(Icons.construction_outlined, size: 40, color: AppColors.muted),
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
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
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
