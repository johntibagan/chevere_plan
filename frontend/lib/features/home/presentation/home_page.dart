import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../admin/presentation/admin_page.dart';
import '../../auth/data/profile.dart';
import '../../moderation/data/moderation_repository.dart';
import '../../moderation/presentation/admin_reports_page.dart';
import '../../moderation/presentation/site_photos_sheet.dart';
import '../../plans/presentation/plans_list_page.dart';
import '../../proximity/presentation/proximity_prefs_sheet.dart';
import '../../routes/presentation/my_routes_page.dart';
import '../../search/presentation/search_page.dart';
import '../../saves/data/save_models.dart';
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

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final savesRepo = ref.read(savesRepositoryProvider);
      final geofenceSync = ref.read(geofenceSyncServiceProvider);

      final profile = await profileRepo.fetchCurrent();
      final saves = await savesRepo.listMine();
      final stale = await savesRepo.listStaleDrafts();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _saves = saves;
        _loading = false;
      });
      if (stale.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tienes ${stale.length} borrador(es) por completar.',
            ),
            action: SnackBarAction(
              label: 'Completar',
              onPressed: () {
                final drafts = _saves
                    .where((s) => s.status == SiteStatus.draft)
                    .toList();
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
        _error = userFacingError(e);
        _loading = false;
      });
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
    if (result != null) await _bootstrap();
  }

  Future<void> _discard(UserSave save) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar guardado'),
        content: Text('¿Eliminar "${save.siteName}" de tu lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(draftReminderServiceProvider).cancelForSave(save.id);
    await ref.read(savesRepositoryProvider).discardSave(save.id);
    await _bootstrap();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.session.user;
    final name = _profile?.displayName ??
        user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String? ??
        'Usuario';
    final isStaff = _profile?.role.isStaff ?? false;
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

    final searchRepo = ref.watch(searchRepositoryProvider);
    final plansRepo = ref.watch(plansRepositoryProvider);
    final routesRepo = ref.watch(routesRepositoryProvider);
    final adminRepo = ref.watch(adminRepositoryProvider);
    final moderationRepo = ref.watch(moderationRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: [
            _InicioTab(
              greeting: _greeting,
              name: name,
              initial: initial,
              isStaff: isStaff,
              loading: _loading,
              error: _error,
              saves: _saves,
              profile: _profile,
              onRefresh: _bootstrap,
              onOpenSave: _openSave,
              onDiscard: _discard,
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
              onSignOut: () => ref.read(authRepositoryProvider).signOut(),
              onExplore: () => setState(() => _tab = 1),
              moderationRepository: moderationRepo,
            ),
            SearchPage(repository: searchRepo),
            PlansListPage(repository: plansRepo),
            MyRoutesPage(repository: routesRepo),
          ],
        ),
      ),
      bottomNavigationBar: _ChevereBottomNav(
        index: _tab,
        onChanged: (i) => setState(() => _tab = i),
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.paddingOf(context).bottom + 8,
      ),
      child: Row(
        children: [
          _navItem(0, Icons.home_rounded, 'Inicio'),
          _navItem(1, Icons.explore_outlined, 'Explorar'),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onGuardar,
                child: Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 22,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 28),
                ),
              ),
            ),
          ),
          _navItem(2, Icons.map_outlined, 'Planes'),
          _navItem(3, Icons.route_outlined, 'Rutas'),
        ],
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
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
    required this.profile,
    required this.onRefresh,
    required this.onOpenSave,
    required this.onDiscard,
    required this.onProximity,
    required this.onAdmin,
    required this.onReports,
    required this.onSignOut,
    required this.onExplore,
    required this.moderationRepository,
  });

  final String greeting;
  final String name;
  final String initial;
  final bool isStaff;
  final bool loading;
  final String? error;
  final List<UserSave> saves;
  final Profile? profile;
  final Future<void> Function() onRefresh;
  final Future<void> Function({String? shared, UserSave? existing}) onOpenSave;
  final Future<void> Function(UserSave) onDiscard;
  final VoidCallback onProximity;
  final VoidCallback onAdmin;
  final VoidCallback onReports;
  final VoidCallback onSignOut;
  final VoidCallback onExplore;
  final ModerationRepository moderationRepository;

  @override
  Widget build(BuildContext context) {
    final drafts = saves.where((s) => s.isIncomplete).toList();
    final recent = saves.take(8).toList();

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
                          'Chevere Plan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.foreground,
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _roundIcon(
                    icon: Icons.notifications_none_rounded,
                    onTap: onProximity,
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
          if (drafts.isNotEmpty)
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
                    onTap: () => onOpenSave(existing: drafts.first),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PENDIENTE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black.withValues(alpha: 0.55),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Text(
                                  '${drafts.length} guardado(s) por completar',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (profile != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.radar_rounded,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Radio ${profile!.proximityRadiusM} m'
                      '${profile!.remindPublicSites ? ' · públicos' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onProximity,
                      child: const Text('Ajustar'),
                    ),
                  ],
                ),
              ),
            ),
          if (isStaff)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: OutlinedButton.icon(
                  onPressed: onReports,
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Reportes abiertos'),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Row(
                children: [
                  Text(
                    'Mis guardados',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.foreground,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onExplore,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Explorar'),
                        Icon(Icons.chevron_right, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  error!,
                  style: const TextStyle(color: AppColors.accent),
                ),
              ),
            )
          else if (saves.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 80),
                child: Text(
                  'Aún no tienes lugares. Usa el botón + o comparte un link desde IG/TikTok/FB.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList.separated(
                itemCount: recent.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final s = recent[i];
                  return _SaveCard(
                    save: s,
                    onTap: () => onOpenSave(existing: s),
                    onPhotos: () {
                      showSitePhotosSheet(
                        context: context,
                        siteId: s.siteId,
                        siteName: s.siteName,
                        repository: moderationRepository,
                      );
                    },
                    onDiscard: () => onDiscard(s),
                  );
                },
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
    required this.onPhotos,
    required this.onDiscard,
  });

  final UserSave save;
  final VoidCallback onTap;
  final VoidCallback onPhotos;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
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
                  color:
                      save.isIncomplete ? AppColors.primary : AppColors.muted,
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
                    const SizedBox(height: 4),
                    Text(
                      [
                        save.status.labelEs,
                        if (save.city != null && save.city!.isNotEmpty)
                          save.city!,
                        if (save.categoryNames.isNotEmpty)
                          save.categoryNames.first,
                        save.isPublic ? 'Público' : 'Privado',
                      ].join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onPhotos,
                icon: const Icon(Icons.photo_library_outlined, size: 20),
                color: AppColors.muted,
              ),
              IconButton(
                onPressed: onDiscard,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
