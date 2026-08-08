import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/auth_repository.dart';

/// Home vacío del Ciclo 0: confirma sesión, sin funcionalidad de negocio.
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.authRepository,
    required this.session,
  });

  final AuthRepository authRepository;
  final Session session;

  @override
  Widget build(BuildContext context) {
    final user = session.user;
    final email = user.email ?? 'sin email';
    final name = user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String? ??
        'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chevere Plan'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => authRepository.signOut(),
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
            const SizedBox(height: 24),
            Text(
              'Sesión activa. Aún no hay guardados ni planes '
              '(llegan en ciclos siguientes).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
