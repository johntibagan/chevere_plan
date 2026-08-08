import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../admin/data/admin_repository.dart';
import '../../admin/presentation/admin_page.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/profile.dart';
import '../../auth/data/profile_repository.dart';

/// Home del Ciclo 0/1: sesión + acceso admin si staff.
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
  Profile? _profile;
  String? _profileError;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileRepo.fetchCurrent();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loadingProfile = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profileError = e.toString();
        _loadingProfile = false;
      });
    }
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $name',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            if (_loadingProfile)
              const LinearProgressIndicator()
            else if (_profileError != null)
              Text(
                'No se pudo cargar el perfil. ¿Aplicaste las migraciones SQL?\n$_profileError',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (_profile == null)
              Text(
                'Sin fila en profiles. Ejecuta el backfill SQL del backend/README.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else
              Text(
                'Rol: ${_profile!.role.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 24),
            Text(
              'Ciclo 1: esquema y panel admin (categorías / vehículos). '
              'Guardados y planes llegan en ciclos siguientes.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (isStaff) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          AdminPage(repository: AdminRepository()),
                    ),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Abrir panel administrador'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
