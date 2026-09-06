import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/distance/distance_unit.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';

/// Elige unidad de distancia (catálogo admin). Persiste vía [onSelect].
/// Sin Consumer/ref en el sheet (inyectar datos/callbacks como proximidad).
Future<void> showDistanceUnitPrefsSheet({
  required BuildContext context,
  required List<DistanceUnit> units,
  required String selectedSlug,
  required Future<void> Function(String slug) onSelect,
  Future<List<DistanceUnit>> Function()? onRefresh,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => _DistanceUnitPrefsSheet(
      initialUnits: units,
      selectedSlug: selectedSlug,
      onSelect: onSelect,
      onRefresh: onRefresh,
    ),
  );
}

class _DistanceUnitPrefsSheet extends StatefulWidget {
  const _DistanceUnitPrefsSheet({
    required this.initialUnits,
    required this.selectedSlug,
    required this.onSelect,
    this.onRefresh,
  });

  final List<DistanceUnit> initialUnits;
  final String selectedSlug;
  final Future<void> Function(String slug) onSelect;
  final Future<List<DistanceUnit>> Function()? onRefresh;

  @override
  State<_DistanceUnitPrefsSheet> createState() =>
      _DistanceUnitPrefsSheetState();
}

class _DistanceUnitPrefsSheetState extends State<_DistanceUnitPrefsSheet> {
  bool _saving = false;
  bool _loading = false;
  bool _loadFailed = false;
  String? _pendingSlug;
  late List<DistanceUnit> _units;

  @override
  void initState() {
    super.initState();
    _units = List<DistanceUnit>.from(widget.initialUnits);
    if (_units.isEmpty && widget.onRefresh != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_refreshUnits());
      });
    }
  }

  Future<void> _refreshUnits() async {
    final refresh = widget.onRefresh;
    if (refresh == null) return;
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final next = await refresh();
      if (!mounted) return;
      setState(() {
        _units = next;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
      AppToast.error(context, e, logContext: 'distance_unit_prefs_load');
    }
  }

  Future<void> _select(String slug) async {
    if (_saving || slug.trim().isEmpty) return;
    setState(() {
      _saving = true;
      _pendingSlug = slug;
    });
    try {
      await widget.onSelect(slug);
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
    final l10n = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.55;
    final selectedSlug = _pendingSlug ?? widget.selectedSlug;

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
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _loadFailed
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.errorGenericLead),
                            TextButton(
                              onPressed: () => unawaited(_refreshUnits()),
                              child: Text(l10n.errorRetryAction),
                            ),
                          ],
                        )
                      : _buildList(selectedSlug),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String selectedSlug) {
    final units = _units.where((u) => u.isActive).toList()
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
  }
}
