import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/distance/distance_unit.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/widgets/app_toast.dart';

/// Elige unidad de distancia (catálogo admin). Persiste en perfil + local.
Future<void> showDistanceUnitPrefsSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => const _DistanceUnitPrefsSheet(),
  );
}

class _DistanceUnitPrefsSheet extends ConsumerStatefulWidget {
  const _DistanceUnitPrefsSheet();

  @override
  ConsumerState<_DistanceUnitPrefsSheet> createState() =>
      _DistanceUnitPrefsSheetState();
}

class _DistanceUnitPrefsSheetState
    extends ConsumerState<_DistanceUnitPrefsSheet> {
  bool _saving = false;

  Future<void> _select(String slug) async {
    setState(() => _saving = true);
    try {
      await ref.read(preferredDistanceUnitSlugProvider.notifier).setSlug(slug);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(context, e, logContext: 'distance_unit_prefs');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final unitsAsync = ref.watch(distanceUnitsProvider);
    final selectedSlug = ref.watch(preferredDistanceUnitSlugProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.distanceUnitSheetTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.distanceUnitSheetHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            unitsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Text(l10n.errorGenericLead),
              data: (all) {
                final units = all.where((u) => u.isActive).toList()
                  ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                if (units.isEmpty) {
                  return ListTile(
                    title: Text(DistanceUnit.fallbackKm.nameEs),
                    subtitle: Text(DistanceUnit.fallbackKm.symbol),
                    selected: true,
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final u in units)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          selectedSlug == u.slug
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: selectedSlug == u.slug
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                        title: Text(u.nameEs),
                        subtitle: Text(u.symbol),
                        enabled: !_saving,
                        onTap: _saving ? null : () => unawaited(_select(u.slug)),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
