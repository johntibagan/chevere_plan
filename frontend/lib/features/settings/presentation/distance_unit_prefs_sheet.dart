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
  String? _pendingSlug;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(distanceUnitsProvider.notifier).refresh());
    });
  }

  Future<void> _select(String slug) async {
    if (_saving || slug.trim().isEmpty) return;
    setState(() {
      _saving = true;
      _pendingSlug = slug;
    });
    try {
      await ref.read(preferredDistanceUnitSlugProvider.notifier).setSlug(slug);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _pendingSlug = null;
      });
      AppToast.error(context, e, logContext: 'distance_unit_prefs');
      AppToast.show(context, context.l10n.errorProblemToast, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.55;
    final unitsAsync = ref.watch(distanceUnitsProvider);
    final selectedSlug =
        _pendingSlug ?? ref.watch(preferredDistanceUnitSlugProvider);

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
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: unitsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.errorGenericLead),
                    TextButton(
                      onPressed: () => unawaited(
                        ref.read(distanceUnitsProvider.notifier).refresh(),
                      ),
                      child: Text(l10n.errorRetryAction),
                    ),
                  ],
                ),
                data: (all) {
                  final units = all.where((u) => u.isActive).toList()
                    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                  final list = units.isEmpty
                      ? <DistanceUnit>[DistanceUnit.fallbackKm]
                      : units;
                  return RadioGroup<String>(
                    groupValue: selectedSlug,
                    onChanged: (slug) {
                      if (slug == null || _saving) return;
                      unawaited(_select(slug));
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final u = list[index];
                        return RadioListTile<String>(
                          value: u.slug,
                          title: Text(u.nameEs),
                          subtitle: Text(u.symbol),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          enabled: !_saving,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
