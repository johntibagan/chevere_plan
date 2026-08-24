import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cache/session_cache_cleanup.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/prefetch/site_prefetch.dart';
import '../../../core/theme/app_theme.dart';
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
import '../../saves/presentation/site_status_l10n.dart';

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
  bool _hasMoreSaves = false;
  bool _loadingMoreSaves = false;
  String? _error;
  bool _loading = true;
  int _tab = 0; // 0 inicio, 1 explorar, 2 planes, 3 rutas
  List<SearchHit> _nearby = [];
  bool _nearbyLoading = false;
  bool _nearbyNeedGps = false;
  bool _showAllRecent = false;

  /// Instancias cacheadas: se crean al primer toque (lazy) y se reutilizan.
  Widget? _exploreTab;
  Widget? _plansTab;
  Widget? _routesTab;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  void _selectTab(int i) {
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
    setState(() {
      if (!hasSaves) _loading = true;
      _error = null;
    });
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final geofenceSync = ref.read(geofenceSyncServiceProvider);

      if (forceRefresh) {
        await ref.read(mySavesProvider.notifier).refresh(force: true);
      }

      final profile = await profileRepo.fetchCurrent();
      // SWR: sirve caché fresca/stale de inmediato; red en background si aplica.
      final page = await ref.read(mySavesProvider.future);
      final saves = page.items;
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
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _saves = saves;
        _hasMoreSaves = page.hasMore;
        _loadingMoreSaves = page.loadingMore;
        _loading = false;
      });
      _loadNearby();
      ref.read(sitePrefetchProvider).scheduleVisibleSites(
            saves.map((s) => s.siteId),
          );
      if (stale.isNotEmpty) {
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
      if (profile != null) {
        await geofenceSync.syncFromProfile(profile: profile);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'failed';
      });
      AppToast.error(context, e, logContext: 'home_load');
    }
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

  Future<void> _loadNearby() async {
    if (!mounted) return;
    setState(() {
      _nearbyLoading = true;
      _nearbyNeedGps = false;
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _nearby = [];
          _nearbyLoading = false;
          _nearbyNeedGps = true;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      final hits = await ref.read(searchRepositoryProvider).search(
            SearchFilters(
              includePublic: true,
              lat: pos.latitude,
              lng: pos.longitude,
              radiusKm: 25,
            ),
          );
      if (!mounted) return;
      setState(() {
        _nearby = hits.where((h) => h.isPublic).take(4).toList();
        _nearbyLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _nearby = [];
        _nearbyLoading = false;
      });
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
          _hasMoreSaves = page.hasMore;
          _loadingMoreSaves = page.loadingMore;
          _loading = false;
        });
        ref.read(sitePrefetchProvider).scheduleVisibleSites(
              page.items.map((s) => s.siteId),
            );
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

    return Scaffold(
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
              hasMoreSaves: _hasMoreSaves,
              loadingMoreSaves: _loadingMoreSaves,
              nearby: _nearby,
              nearbyLoading: _nearbyLoading,
              nearbyNeedGps: _nearbyNeedGps,
              showAllRecent: _showAllRecent,
              profile: _profile,
              onRefresh: () async {
                await _bootstrap(forceRefresh: true);
              },
              onLoadMoreSaves: () =>
                  ref.read(mySavesProvider.notifier).loadMore(),
              onOpenSave: _openSave,
              onOpenSite: _openSite,
              onOpenHit: _openHit,
              onSeeAllRecent: () =>
                  setState(() => _showAllRecent = !_showAllRecent),
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
    return Expanded(
      child: InkWell(
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

class _InicioTab extends StatelessWidget {
  const _InicioTab({
    required this.greeting,
    required this.name,
    required this.initial,
    required this.isStaff,
    required this.loading,
    required this.error,
    required this.saves,
    required this.hasMoreSaves,
    required this.loadingMoreSaves,
    required this.nearby,
    required this.nearbyLoading,
    required this.nearbyNeedGps,
    required this.showAllRecent,
    required this.profile,
    required this.onRefresh,
    required this.onLoadMoreSaves,
    required this.onOpenSave,
    required this.onOpenSite,
    required this.onOpenHit,
    required this.onSeeAllRecent,
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
  final bool hasMoreSaves;
  final bool loadingMoreSaves;
  final List<SearchHit> nearby;
  final bool nearbyLoading;
  final bool nearbyNeedGps;
  final bool showAllRecent;
  final Profile? profile;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMoreSaves;
  final Future<void> Function({String? shared, UserSave? existing}) onOpenSave;
  final Future<void> Function({UserSave? existing}) onOpenSite;
  final Future<void> Function(SearchHit hit) onOpenHit;
  final VoidCallback onSeeAllRecent;
  final VoidCallback onProximity;
  final VoidCallback onAdmin;
  final VoidCallback onReports;
  final VoidCallback onSignOut;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final drafts = saves.where((s) => s.isIncomplete).toList();

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
            child: HomeSectionHeader(
              title: l10n.homeRecentSaves,
              actionLabel: saves.isEmpty ? null : l10n.homeSeeAll,
              onAction: saves.isEmpty ? null : onSeeAllRecent,
            ),
          ),
          if (loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  error!,
                  style: const TextStyle(color: AppColors.accent),
                ),
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
              child: SizedBox(
                height: 208,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: (showAllRecent ? saves : saves.take(5)).length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final subset =
                        showAllRecent ? saves : saves.take(5).toList();
                    final s = subset[i];
                    return HomeRecentRailCard(
                      save: s,
                      onTap: () => onOpenSite(existing: s),
                    );
                  },
                ),
              ),
            ),
          if (showAllRecent && saves.length > 5)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              sliver: SliverList.separated(
                itemCount: (saves.length - 5) + (hasMoreSaves ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final rest = saves.skip(5).toList();
                  if (i >= rest.length) {
                    return Center(
                      child: loadingMoreSaves
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TextButton(
                              onPressed: onLoadMoreSaves,
                              child: Text(context.l10n.actionLoadMore),
                            ),
                    );
                  }
                  final s = rest[i];
                  return _SaveCard(
                    save: s,
                    onTap: () => onOpenSite(existing: s),
                  );
                },
              ),
            ),
          SliverToBoxAdapter(
            child: HomeSectionHeader(
              title: l10n.homePopularNearby,
              actionLabel: l10n.homeExploreLink,
              onAction: onExplore,
            ),
          ),
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
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: nearby.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.05,
                              ),
                              itemBuilder: (context, i) {
                                final hit = nearby[i];
                                return HomePopularCard(
                                  hit: hit,
                                  onTap: () => onOpenHit(hit),
                                );
                              },
                            ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeQuickActions,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
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
                          onTap: onSeeAllRecent,
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
                ],
              ),
            ),
          ),
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

class _SaveCard extends StatelessWidget {
  const _SaveCard({
    required this.save,
    required this.onTap,
  });

  final UserSave save;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = save.isPublic ? AppColors.success : AppColors.purple;
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          save.isIncomplete
                              ? Icons.edit_note_rounded
                              : Icons.place_outlined,
                          color: save.isIncomplete
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              save.siteName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  [
                                    save.status.label(l10n),
                                    if (save.city != null &&
                                        save.city!.isNotEmpty)
                                      save.city!,
                                    if (save.categoryNames.isNotEmpty)
                                      save.categoryNames.first,
                                  ].join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
