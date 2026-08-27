import 'package:flutter/material.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../auth/data/profile.dart';
import '../../auth/data/profile_repository.dart';
import '../../saves/domain/save_policies.dart';

/// Radio anti-dupe al guardar (siempre en metros; no usa la unidad preferida).
Future<Profile?> showDuplicateRadiusPrefsSheet({
  required BuildContext context,
  required Profile profile,
  required ProfileRepository profileRepository,
}) {
  return showModalBottomSheet<Profile>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => _DuplicateRadiusPrefsSheet(
      profile: profile,
      profileRepository: profileRepository,
    ),
  );
}

class _DuplicateRadiusPrefsSheet extends StatefulWidget {
  const _DuplicateRadiusPrefsSheet({
    required this.profile,
    required this.profileRepository,
  });

  final Profile profile;
  final ProfileRepository profileRepository;

  @override
  State<_DuplicateRadiusPrefsSheet> createState() =>
      _DuplicateRadiusPrefsSheetState();
}

class _DuplicateRadiusPrefsSheetState extends State<_DuplicateRadiusPrefsSheet> {
  late double _radiusM;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _radiusM = SavePolicies.clampDuplicateSearchRadiusM(
      widget.profile.duplicateSearchRadiusM,
    ).toDouble();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final meters = SavePolicies.clampDuplicateSearchRadiusM(_radiusM.round());
      final updated =
          await widget.profileRepository.updateDuplicateSearchRadius(meters);
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(context, e, logContext: 'duplicate_radius_prefs');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final meters = _radiusM.round();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.duplicateRadiusTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.duplicateRadiusSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.profileDuplicateRadiusLabel(meters),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Tooltip(
                  message: l10n.duplicateRadiusMetersInfo,
                  triggerMode: TooltipTriggerMode.tap,
                  child: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            Slider(
              min: SavePolicies.minDuplicateSearchRadiusM.toDouble(),
              max: SavePolicies.maxDuplicateSearchRadiusM.toDouble(),
              divisions: ((SavePolicies.maxDuplicateSearchRadiusM -
                          SavePolicies.minDuplicateSearchRadiusM) /
                      10)
                  .round(),
              label: '$meters m',
              value: _radiusM.clamp(
                SavePolicies.minDuplicateSearchRadiusM.toDouble(),
                SavePolicies.maxDuplicateSearchRadiusM.toDouble(),
              ),
              onChanged: _saving ? null : (v) => setState(() => _radiusM = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }
}
