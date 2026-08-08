import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../admin/data/admin_repository.dart';
import '../../admin/presentation/admin_page.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/profile.dart';
import '../../auth/data/profile_repository.dart';
import '../../proximity/data/geofence_sync_service.dart';
import '../../proximity/presentation/proximity_prefs_sheet.dart';
import '../../saves/data/draft_reminder_service.dart';
import '../../saves/data/save_models.dart';
import '../../saves/data/saves_repository.dart';
import '../../saves/presentation/save_place_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.authRepository,
    required this.session,
  });

  final AuthRepository authRepository;
  final Session session;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _profileRepo = ProfileRepository();
  final _savesRepo = SavesRepository();
  final _geofenceSync = GeofenceSyncService();
  Profile? _profile;
  List<UserSave> _saves = [];
  String? _error;
  bool _loading = true;

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
      final profile = await _profileRepo.fetchCurrent();
      final saves = await _savesRepo.listMine();
      final stale = await _savesRepo.listStaleDrafts();
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
              label: 'Ver',
              onPressed: () {},
            ),
          ),
        );
      }
      if (profile != null) {
        await _geofenceSync.syncFromProfile(profile: profile);
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
      profileRepository: _profileRepo,
      geofenceSync: _geofenceSync,
    );
    if (updated != null && mounted) {
      setState(() => _profile = updated);
    }
  }

  Future<void> _openSave({String? shared}) async {
    final result = await Navigator.of(context).push<UserSave>(
      MaterialPageRoute(
        builder: (_) => SavePlacePage(
          initialSharedText: shared,
          savesRepository: _savesRepo,
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
    await DraftReminderService.instance.cancelForSave(save.id);
    await _savesRepo.discardSave(save.id);
    await _bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.session.user;
    final email = user.email ?? 'sin email';
    final name = _profile?.displayName ??
        user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String? ??
        'Usuario';
    final isStaff = _profile?.role.isStaff ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chevere Plan'),
        actions: [
          IconButton(
            tooltip: 'Recuerdos cercanos',
            onPressed: _profile == null ? null : _openProximityPrefs,
            icon: const Icon(Icons.near_me_outlined),
          ),
          if (isStaff)
            IconButton(
              tooltip: 'Administración',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AdminPage(repository: AdminRepository()),
                  ),
                );
              },
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => widget.authRepository.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSave(),
        icon: const Icon(Icons.add),
        label: const Text('Guardar'),
      ),
      body: RefreshIndicator(
        onRefresh: _bootstrap,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: [
            Text('Hola, $name', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (_profile != null) ...[
              const SizedBox(height: 4),
              Text('Rol: ${_profile!.role.name}'),
              Text(
                'Radio de recuerdos: ${_profile!.proximityRadiusM} m'
                '${_profile!.remindPublicSites ? ' · incluye públicos' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Mis guardados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (_saves.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Aún no tienes lugares. Usa Guardar o comparte un link desde IG/TikTok/FB hacia Chevere Plan.',
                ),
              )
            else
              ..._saves.map(
                (s) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(s.siteName),
                    subtitle: Text(
                      [
                        s.status.labelEs,
                        if (s.isPossibleDuplicate) 'Posible duplicado',
                        if (s.city != null && s.city!.isNotEmpty) s.city!,
                        if (s.categoryNames.isNotEmpty)
                          s.categoryNames.join(', '),
                        s.isPublic ? 'Público' : 'Privado',
                        if (s.alsoSharedBy.isNotEmpty)
                          'También por: ${s.alsoSharedBy.join(', ')}',
                      ].join(' · '),
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'Descartar',
                      onPressed: () => _discard(s),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
