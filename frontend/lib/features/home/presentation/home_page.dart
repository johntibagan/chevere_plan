import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cache/session_cache_cleanup.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/widgets/app_retry_callout.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/prefetch/site_prefetch.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/widgets/app_feed_layout_toggle.dart';
import '../../admin/presentation/admin_page.dart';
import '../../auth/data/profile.dart';
import '../../moderation/presentation/admin_reports_page.dart';
import '../../plans/presentation/plans_list_page.dart';
import '../../proximity/presentation/proximity_prefs_sheet.dart';
import '../../routes/presentation/my_routes_page.dart';
import '../../search/data/search_models.dart';
import '../../search/presentation/search_page.dart';
import '../../saves/data/save_models.dart';
import 'home_cards.dart';
import '../../saves/data/site_ficha.dart';
import '../../saves/domain/save_policies.dart';
import '../../saves/presentation/open_site_detail.dart';
import '../../saves/presentation/save_place_page.dart';

/// Shell Figma: Inicio | Explorar | [+] Guardar | Planes | Rutas
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.session});

  final Session session;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Profile? _profile;
  List<UserSave> _saves = [];
  String? _error;
  bool _loading = true;
  int _tab = 0; // 0 inicio, 1 explorar, 2 planes, 3 rutas
  DateTime? _exitArmedAt;
  static const _exitWindow = Duration(seconds: 2);

  /// Instancias cacheadas: se crean al primer toque (lazy) y se reutilizan.
  Widget? _exploreTab;
  Widget? _plansTab;
  Widget? _routesTab;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  void _onRootBack() {
    if (_tab != 0) {
      _selectTab(0);
      return;
    }
    final now = DateTime.now();
    if (_exitArmedAt != null &&
        now.difference(_exitArmedAt!) < _exitWindow) {
      SystemNavigator.pop();
      return;
    }
    _exitArmedAt = now;
    AppToast.show(
      context,
      context.l10n.navPressBackAgainToExit,
      duration: _exitWindow,
    );
  }

  void _selectTab(int i) {
    _exitArmedAt = null;
    setState(() {
      _tab = i;
      switch (i) {
        case 1:
          _exploreTab ??= SearchPage(
            repository: ref.read(searchRepositoryProvider),
          );
        case 2:
          _plansTab ??= PlansListPage(
            repository: ref.read(plansRepositoryProvider),
          );
        case 3:
          _routesTab ??= MyRoutesPage(
            repository: ref.read(routesRepositoryProvider),
          );
      }
    });
  }

  Widget _tabSlot({required int slot, required Widget? page}) {
    // Placeholder a tamaño completo: SizedBox.shrink() colapsaba el IndexedStack
    // y dejaba el body vacío / la barra “flotando” al centro.
    if (page == null) {
      return const ColoredBox(
        color: AppColors.background,
        child: SizedBox.expand(),
      );
    }
    return KeyedSubtree(key: ValueKey('tab-$slot'), child: page);
  }

  Future<void> _bootstrap({bool forceRefresh = false}) async {
    final hasSaves =
        (ref.read(mySavesProvider).valueOrNull?.items.isNotEmpty ?? false) ||
            _saves.isNotEmpty;
    if (!hasSaves) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() => _error = null);
    }
    try {
      if (forceRefresh) {
        unawaited(ref.read(mySavesProvider.notifier).refresh(force: true));
      }

      // Guardados primero (caché SWR). Perfil y geofence no bloquean la lista.
      final page = await ref.read(mySavesProvider.future);
      final saves = page.items;
      if (!mounted) return;
      setState(() {
        _saves = saves;
        _loading = false;
      });
      ref.read(sitePrefetchProvider).scheduleVisibleSites(
            saves.map((s) => s.siteId),
          );
      ref.read(sitePrefetchProvider).warmupCoverPaths([
        for (final s in saves.take(8)) s.coverStoragePath,
      ]);

      unawaited(_loadProfileAndGeofence());

      final cutoff =
          DateTime.now().toUtc().subtract(SavePolicies.draftRemindAfter);
      final stale = saves
          .where(
            (s) =>
                s.isIncomplete &&
                s.createdAt != null &&
                s.createdAt!.toUtc().isBefore(cutoff),
          )
          .toList();
      if (stale.isNotEmpty && mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.homeStaleDraftsSnack(stale.length)),
            action: SnackBarAction(
              label: l10n.actionComplete,
              onPressed: () {
                final drafts = _saves.where((s) => s.isIncomplete).toList();
                if (drafts.isNotEmpty) _openSave(existing: drafts.first);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'retry';
      });
      AppToast.error(context, e, logContext: 'home_load');
    }
  }

  Future<void> _loadProfileAndGeofence() async {
    try {
      final profile = await ref.read(profileRepositoryProvider).fetchCurrent();
      if (!mounted) return;
      setState(() => _profile = profile);
      if (profile != null) {
        await ref.read(geofenceSyncServiceProvider).syncFromProfile(
              profile: profile,
            );
      }
    } catch (_) {}
  }

  Future<void> _openProximityPrefs() async {
    final profile = _profile;
    if (profile == null) return;
    final updated = await showProximityPrefsSheet(
      context: context,
      profile: profile,
      profileRepository: ref.read(profileRepositoryProvider),
      geofenceSync: ref.read(geofenceSyncServiceProvider),
    );
    if (updated != null && mounted) {
      setState(() => _profile = updated);
    }
  }

  Future<void> _openSite({UserSave? existing}) async {
    if (existing == null) return;
    final outcome = await openSiteDetail(context, save: existing);
    if (outcome != SiteDetailOutcome.none) {
      await _bootstrap(forceRefresh: true);
    }
  }

  Future<void> _openHit(SearchHit hit) async {
    final outcome = await openSiteDetail(context, hit: hit);
    if (outcome != SiteDetailOutcome.none) {
      await _bootstrap(forceRefresh: true);
    }
  }

  Future<void> _openSave({String? shared, UserSave? existing}) async {
    final result = await Navigator.of(context).push<UserSave>(
      MaterialPageRoute(
        builder: (_) => SavePlacePage(
          initialSharedText: shared,
          existingSaveId: existing?.id,
          savesRepository: ref.read(savesRepositoryProvider),
        ),
      ),
    );
    if (result != null) await _bootstrap(forceRefresh: true);
  }

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.greetingMorning;
    if (h < 19) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    // Mantener lista al día si SWR refresca en background.
    ref.listen(mySavesProvider, (prev, next) {
      next.whenData((page) {
        if (!mounted) return;
        setState(() {
          _saves = page.items;
          _loading = false;
        });
        ref.read(sitePrefetchProvider).scheduleVisibleSites(
              page.items.map((s) => s.siteId),
            );
        ref.read(sitePrefetchProvider).warmupCoverPaths([
          for (final s in page.items.take(8)) s.coverStoragePath,
        ]);
      });
    });

    ref.listen(homeNearbyProvider, (prev, next) {
      next.whenData((snap) {
        if (!mounted) return;
        ref.read(sitePrefetchProvider).warmupCoverPaths([
          for (final h in snap.hits.take(8)) h.coverStoragePath,
        ]);
      });
    });

    final l10n = context.l10n;
    final user = widget.session.user;
    final name = _profile?.displayName ??
        user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String? ??
        'Usuario';
    final isStaff = _profile?.role.isStaff ?? false;
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

    final adminRepo = ref.read(adminRepositoryProvider);
    final moderationRepo = ref.read(moderationRepositoryProvider);

    final nearbyAsync = ref.watch(homeNearbyProvider);
    final nearbySnap = nearbyAsync.valueOrNull;
    final nearbyHits = nearbySnap?.hits ?? const <SearchHit>[];
    final nearbyLoading =
        nearbyAsync.isLoading && (nearbySnap == null || nearbySnap.hits.isEmpty);
    final nearbyNeedGps = nearbySnap?.needGps ?? false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onRootBack();
      },
      child: Scaffold(
        key: const Key('home_shell'),
        backgroundColor: AppColors.background,
        extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          sizing: StackFit.expand,
          children: [
            _InicioTab(
              greeting: _greeting(l10n),
              name: name,
              initial: initial,
              isStaff: isStaff,
              loading: _loading,
              error: _error,
              saves: _saves,
              nearby: nearbyHits,
              nearbyLoading: nearbyLoading,
              nearbyNeedGps: nearbyNeedGps,
              profile: _profile,
              onRefresh: () async {
                await Future.wait([
                  _bootstrap(forceRefresh: true),
                  ref.read(homeNearbyProvider.notifier).refresh(force: true),
                ]);
              },
              onOpenSave: _openSave,
              onOpenSite: _openSite,
              onOpenHit: _openHit,
              onProximity: _openProximityPrefs,
              onAdmin: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AdminPage(repository: adminRepo),
                  ),
                );
              },
              onReports: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        AdminReportsPage(repository: moderationRepo),
                  ),
                );
              },
              onSignOut: () async {
                await clearSessionCaches(
                  invalidate: ref.invalidate,
                  read: ref.read,
                );
                await ref.read(authRepositoryProvider).signOut();
              },
              onExplore: () => _selectTab(1),
            ),
            _tabSlot(slot: 1, page: _exploreTab),
            _tabSlot(slot: 2, page: _plansTab),
            _tabSlot(slot: 3, page: _routesTab),
          ],
        ),
      ),
      bottomNavigationBar: _ChevereBottomNav(
        index: _tab,
        onChanged: _selectTab,
        onGuardar: () => _openSave(),
      ),
    ),
    );
  }
}

class _ChevereBottomNav extends StatelessWidget {
  const _ChevereBottomNav({
    required this.index,
    required this.onChanged,
    required this.onGuardar,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onGuardar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.sidebar,
      elevation: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  _navItem(0, Icons.home_rounded, l10n.navHome),
                  _navItem(1, Icons.explore_outlined, l10n.navExplore),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        key: WidgetKeys.homeFabSave,
                        onTap: onGuardar,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.45),
                                blurRadius: 22,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.background,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _navItem(2, Icons.map_outlined, l10n.navPlans),
                  _navItem(3, Icons.route_outlined, l10n.navRoutes),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final active = index == i;
    final color = active ? AppColors.primary : AppColors.mutedDark;
    const tabKeys = [
      WidgetKeys.homeTabInicio,
      WidgetKeys.homeTabExplorar,
      WidgetKeys.homeTabPlanes,
      WidgetKeys.homeTabRutas,
    ];
    return Expanded(
      child: InkWell(
        key: tabKeys[i],
        onTap: () => onChanged(i),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InicioTab extends ConsumerWidget {
  const _InicioTab({
    required this.greeting,
    required this.name,
    required this.initial,
    required this.isStaff,
    required this.loading,
    required this.error,
    required this.saves,
    required this.nearby,
    required this.nearbyLoading,
    required this.nearbyNeedGps,
    required this.profile,
    required this.onRefresh,
    required this.onOpenSave,
    required this.onOpenSite,
    required this.onOpenHit,
    required this.onProximity,
    required this.onAdmin,
    required this.onReports,
    required this.onSignOut,
    required this.onExplore,
  });

  final String greeting;
  final String name;
  final String initial;
  final bool isStaff;
  final bool loading;
  final String? error;
  final List<UserSave> saves;
  final List<SearchHit> nearby;
  final bool nearbyLoading;
  final bool nearbyNeedGps;
  final Profile? profile;
  final Future<void> Function() onRefresh;
  final Future<void> Function({String? shared, UserSave? existing}) onOpenSave;
  final Future<void> Function({UserSave? existing}) onOpenSite;
  final Future<void> Function(SearchHit hit) onOpenHit;
  final VoidCallback onProximity;
  final VoidCallback onAdmin;
  final VoidCallback onReports;
  final VoidCallback onSignOut;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final drafts = saves.where((s) => s.isIncomplete).toList();
    final sections = ref.watch(homeSectionsOpenProvider);
    final layout = ref.watch(feedLayoutProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.mutedDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          l10n.appTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _roundIcon(
                        icon: Icons.notifications_none_rounded,
                        onTap: onProximity,
                      ),
                      if (profile != null)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  if (isStaff) ...[
                    GestureDetector(
                      onTap: onAdmin,
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          initial,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _roundIcon(icon: Icons.logout_rounded, onTap: onSignOut),
                ],
              ),
            ),
          ),
          if (profile != null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onProximity,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.background.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: AppColors.background,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.homeNearbyMemoryLabel.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: AppColors.background
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  l10n.homeNearbyMemoryTitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.background,
                                  ),
                                ),
                                Text(
                                  '${l10n.homeProximityRadius(profile!.proximityRadiusM)}'
                                  '${profile!.remindPublicSites ? l10n.homeProximityPublicSuffix : ''}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.background
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.background.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (drafts.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primarySoft.withValues(alpha: 0.19),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onOpenSave(existing: drafts.first),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: AppColors.primarySoft,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.homeDraftsToComplete(drafts.length),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primarySoft,
                                  ),
                                ),
                                Text(
                                  l10n.homeDraftsHint,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: AppColors.primarySoft,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.homeFeedView,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedDark,
                      ),
                    ),
                  ),
                  AppFeedLayoutToggle(
                    value: layout,
                    onChanged: (v) =>
                        ref.read(feedLayoutProvider.notifier).setLayout(v),
                    listTooltip: l10n.feedLayoutList,
                    grid2Tooltip: l10n.feedLayoutGrid2,
                    grid3Tooltip: l10n.feedLayoutGrid3,
                    grid4Tooltip: l10n.feedLayoutGrid4,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: HomeSectionHeader(
              title: l10n.homeRecentSaves,
              expanded: sections.recent,
              onToggleExpanded: () => ref
                  .read(homeSectionsOpenProvider.notifier)
                  .setOpen(sections.copyWith(recent: !sections.recent)),
              actionLabel: l10n.homeSeeAll,
              onAction: onExplore,
            ),
          ),
          if (sections.recent) ...[
            if (loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (error != null)
              SliverToBoxAdapter(
                child: AppRetryCallout(
                  onRetry: () {
                    onRefresh();
                  },
                ),
              )
            else if (saves.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    l10n.homeEmptySaves,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: HomeFeedHits(
                    hits: [
                      for (final s in saves.take(5)) hitFromSave(s),
                    ],
                    layout: layout,
                    onTap: (hit) {
                      final save = saves.firstWhere(
                        (s) => s.siteId == hit.siteId,
                      );
                      onOpenSite(existing: save);
                    },
                  ),
                ),
              ),
          ],
          SliverToBoxAdapter(
            child: HomeSectionHeader(
              title: l10n.homePopularNearby,
              expanded: sections.popular,
              onToggleExpanded: () => ref
                  .read(homeSectionsOpenProvider.notifier)
                  .setOpen(sections.copyWith(popular: !sections.popular)),
              actionLabel: l10n.homeSeeAll,
              onAction: onExplore,
            ),
          ),
          if (sections.popular)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: nearbyLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : nearbyNeedGps
                        ? Text(
                            l10n.homeNearbyNeedGps,
                            style: const TextStyle(color: AppColors.muted),
                          )
                        : nearby.isEmpty
                            ? Text(
                                l10n.homeNearbyEmpty,
                                style: const TextStyle(color: AppColors.muted),
                              )
                            : HomeFeedHits(
                                hits: nearby,
                                layout: layout,
                                onTap: onOpenHit,
                              ),
              ),
            ),
          SliverToBoxAdapter(
            child: HomeSectionHeader(
              title: l10n.homeQuickActions,
              expanded: sections.quick,
              onToggleExpanded: () => ref
                  .read(homeSectionsOpenProvider.notifier)
                  .setOpen(sections.copyWith(quick: !sections.quick)),
            ),
          ),
          if (sections.quick)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: HomeQuickAction(
                        icon: Icons.near_me_rounded,
                        color: AppColors.accent,
                        label: l10n.homeActionNearMe,
                        onTap: onExplore,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: HomeQuickAction(
                        icon: Icons.trending_up_rounded,
                        color: AppColors.primary,
                        label: l10n.homeActionMostSaved,
                        onTap: onExplore,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: HomeQuickAction(
                        icon: Icons.sell_outlined,
                        color: AppColors.purple,
                        label: l10n.homeActionByCategory,
                        onTap: onExplore,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _roundIcon({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.muted),
        ),
      ),
    );
  }
}
