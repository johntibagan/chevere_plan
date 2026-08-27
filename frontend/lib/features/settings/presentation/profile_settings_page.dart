import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/providers.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/widgets/app_form_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_section_label.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/app_toast.dart';
import '../../auth/data/profile.dart';
import '../../auth/domain/profile_public_display.dart';
import '../../auth/domain/username_rules.dart';
import '../../saves/domain/save_policies.dart';

/// Configuración de @usuario y foto de perfil.
///
/// Relaciones (reseñas, fotos, sitios) usan [Profile.id], no el @usuario.
class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({
    super.key,
    this.initial,
    this.requireUsername = false,
  });

  final Profile? initial;
  /// Si true, no se puede salir sin haber elegido @usuario.
  final bool requireUsername;

  static Future<Profile?> open(
    BuildContext context, {
    Profile? initial,
    bool requireUsername = false,
  }) {
    return Navigator.of(context).push<Profile>(
      MaterialPageRoute(
        fullscreenDialog: requireUsername,
        builder: (_) => ProfileSettingsPage(
          initial: initial,
          requireUsername: requireUsername,
        ),
      ),
    );
  }

  @override
  ConsumerState<ProfileSettingsPage> createState() =>
      _ProfileSettingsPageState();
}

enum _AvatarSource { google, custom }

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
  final _usernameCtrl = TextEditingController();
  Timer? _checkTimer;
  Profile? _profile;
  bool _loading = true;
  bool _saving = false;
  bool _checking = false;
  bool _useGoogleAvatar = false;
  UsernameAvailability? _availability;
  List<String> _suggestions = const [];
  double _duplicateRadiusM =
      SavePolicies.defaultDuplicateSearchRadiusM.toDouble();

  bool get _usernameLocked {
    final p = _profile;
    if (p == null) return false;
    return p.hasUsername && !p.canChangeUsername;
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final repo = ref.read(profileRepositoryProvider);
    final p = widget.initial ?? await repo.fetchCurrent();
    if (!mounted) return;
    final existing = p?.username ?? '';
    setState(() {
      _profile = p;
      _useGoogleAvatar = p?.useGoogleAvatar ?? false;
      _duplicateRadiusM = SavePolicies.clampDuplicateSearchRadiusM(
        p?.duplicateSearchRadiusM ??
            SavePolicies.defaultDuplicateSearchRadiusM,
      ).toDouble();
      _usernameCtrl.text = existing;
      _loading = false;
    });
    if (existing.isNotEmpty) {
      if (!_usernameLocked) {
        _scheduleCheck(existing, immediate: true);
      }
    } else {
      final seed = UsernameRules.normalize(p?.displayName) ?? 'user';
      unawaited(_loadSuggestions(seed));
    }
  }

  void _onUsernameChanged(String raw) {
    if (_usernameLocked) return;
    final cleaned = UsernameRules.sanitizeInput(raw);
    if (cleaned != raw) {
      _usernameCtrl.value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
    }
    setState(() {
      _availability = null;
      _suggestions = const [];
    });
    _scheduleCheck(cleaned);
  }

  void _scheduleCheck(String value, {bool immediate = false}) {
    _checkTimer?.cancel();
    final delay = immediate ? Duration.zero : const Duration(milliseconds: 380);
    _checkTimer = Timer(delay, () => _runCheck(value));
  }

  Future<void> _runCheck(String value) async {
    if (_usernameLocked) return;
    final norm = UsernameRules.normalize(value);
    final local = UsernameRules.localIssue(norm);
    if (local != null) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _availability = UsernameAvailability(
          available: false,
          normalized: norm,
          reason: switch (local) {
            UsernameLocalIssue.empty ||
            UsernameLocalIssue.invalid =>
              'invalid',
            UsernameLocalIssue.tooShort ||
            UsernameLocalIssue.tooLong =>
              'length',
            UsernameLocalIssue.reserved => 'reserved',
          },
        );
      });
      if (local == UsernameLocalIssue.reserved ||
          (norm != null && norm.length >= UsernameRules.minLength)) {
        await _loadSuggestions(norm ?? value);
      }
      return;
    }
    if (norm == _profile?.username) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _availability = UsernameAvailability(
          available: true,
          normalized: norm,
          reason: 'ok',
        );
      });
      return;
    }
    if (!mounted) return;
    setState(() => _checking = true);
    try {
      final avail = await ref
          .read(profileRepositoryProvider)
          .checkUsernameAvailable(norm!);
      if (!mounted) return;
      setState(() {
        _checking = false;
        _availability = avail;
      });
      if (!avail.available && avail.reason == 'taken') {
        await _loadSuggestions(norm);
      }
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _checking = false);
      AppToast.error(context, e, stackTrace: st, logContext: 'username_check');
    }
  }

  Future<void> _loadSuggestions(String base) async {
    try {
      final list = await ref
          .read(profileRepositoryProvider)
          .suggestUsernames(base, limit: 5);
      if (!mounted) return;
      setState(() => _suggestions = list);
    } catch (_) {}
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 88,
    );
    if (picked == null || !mounted) return;
    setState(() => _saving = true);
    try {
      final bytes = await picked.readAsBytes();
      final updated = await ref.read(profileRepositoryProvider).uploadAvatar(
            bytes: bytes,
            filename: picked.name,
          );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _useGoogleAvatar = false;
        _saving = false;
      });
      AppToast.show(context, context.l10n.profileSaved);
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(context, e, stackTrace: st, logContext: 'avatar_upload');
      AppToast.show(context, context.l10n.errorProblemToast, error: true);
    }
  }

  Future<void> _removeCustomPhoto() async {
    setState(() => _saving = true);
    try {
      final updated =
          await ref.read(profileRepositoryProvider).clearCustomAvatar();
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _saving = false;
      });
      AppToast.show(context, context.l10n.profileSaved);
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(context, e, stackTrace: st, logContext: 'avatar_clear');
      AppToast.show(context, context.l10n.errorProblemToast, error: true);
    }
  }

  Future<void> _setAvatarSource(_AvatarSource source) async {
    final useGoogle = source == _AvatarSource.google;
    setState(() {
      _useGoogleAvatar = useGoogle;
      _saving = true;
    });
    try {
      final updated = await ref.read(profileRepositoryProvider).updateMyProfile(
            useGoogleAvatar: useGoogle,
          );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _useGoogleAvatar = updated.useGoogleAvatar;
        _saving = false;
      });
    } catch (e, st) {
      if (!mounted) return;
      setState(() {
        _useGoogleAvatar = !useGoogle;
        _saving = false;
      });
      AppToast.error(context, e, stackTrace: st, logContext: 'avatar_source');
      AppToast.show(context, context.l10n.errorProblemToast, error: true);
    }
  }

  Future<void> _toggleGoogleOnly(bool value) async {
    await _setAvatarSource(
      value ? _AvatarSource.google : _AvatarSource.custom,
    );
  }

  Future<void> _clearActiveAvatar() async {
    final profile = _profile;
    if (profile == null) return;
    final hasCustom =
        profile.avatarUrl != null && profile.avatarUrl!.trim().isNotEmpty;
    if (hasCustom && !_useGoogleAvatar) {
      await _removeCustomPhoto();
      return;
    }
    if (_useGoogleAvatar) {
      await _toggleGoogleOnly(false);
    }
  }

  bool get _canClearAvatar {
    final profile = _profile;
    if (profile == null) return false;
    final hasCustom =
        profile.avatarUrl != null && profile.avatarUrl!.trim().isNotEmpty;
    if (hasCustom && !_useGoogleAvatar) return true;
    if (_useGoogleAvatar) return true;
    return false;
  }

  Future<void> _saveUsername() async {
    final l10n = context.l10n;
    final locked = _usernameLocked;
    final current = _profile?.username;
    final norm = UsernameRules.normalize(_usernameCtrl.text);

    if (!locked) {
      if (!UsernameRules.isFormatValid(norm)) {
        AppToast.show(context, l10n.profileSaveUsernameFirst, error: true);
        return;
      }
      if (norm != current && _availability?.available != true) {
        AppToast.show(context, l10n.profileSaveUsernameFirst, error: true);
        return;
      }
    } else if (widget.requireUsername && (current == null || current.isEmpty)) {
      AppToast.show(context, l10n.profileUsernameRequired, error: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final shouldSendUsername = !locked &&
          norm != null &&
          UsernameRules.isFormatValid(norm) &&
          norm != current;
      final repo = ref.read(profileRepositoryProvider);
      var updated = await repo.updateMyProfile(
            username: shouldSendUsername ? norm : null,
            useGoogleAvatar: _useGoogleAvatar,
          );
      final radius = SavePolicies.clampDuplicateSearchRadiusM(
        _duplicateRadiusM.round(),
      );
      if (radius != updated.duplicateSearchRadiusM) {
        updated = await repo.updateDuplicateSearchRadius(radius);
      }
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _duplicateRadiusM = updated.duplicateSearchRadiusM.toDouble();
        _saving = false;
      });
      AppToast.show(context, l10n.profileSaved);
      if (!widget.requireUsername || updated.hasUsername) {
        Navigator.of(context).pop(updated);
      }
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _saving = false);
      final msg = e.toString();
      if (msg.contains('username change cooldown')) {
        AppToast.show(context, l10n.profileUsernameCooldownToast, error: true);
      } else {
        AppToast.error(context, e, stackTrace: st, logContext: 'profile_save');
        AppToast.show(context, l10n.errorProblemToast, error: true);
      }
    }
  }

  String? _statusMessage() {
    if (_usernameLocked) return null;
    final l10n = context.l10n;
    final a = _availability;
    if (_checking) return l10n.profileUsernameChecking;
    if (a == null) return null;
    if (a.available) return l10n.profileUsernameAvailable;
    return switch (a.reason) {
      'taken' => l10n.profileUsernameTaken,
      'length' => l10n.profileUsernameLength,
      'reserved' => l10n.profileUsernameReserved,
      _ => l10n.profileUsernameInvalid,
    };
  }

  String _initialLetter(String handle, String fallback) {
    final bare = handle.startsWith('@') ? handle.substring(1) : handle;
    if (bare.isEmpty || bare == fallback) return 'U';
    return bare[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    final profile = _profile;
    final avatarUrl = ProfilePublicDisplay.effectiveAvatarUrl(
      customAvatarUrl: profile?.avatarUrl,
      googleAvatarUrl: profile?.googleAvatarUrl,
      useGoogleAvatar: _useGoogleAvatar,
    );
    final typed = _usernameCtrl.text.trim();
    final handle = typed.isEmpty
        ? l10n.defaultUserDisplayName
        : ProfilePublicDisplay.handle(username: typed);
    final initial = _initialLetter(handle, l10n.defaultUserDisplayName);
    final hasCustom =
        (profile?.avatarUrl != null && profile!.avatarUrl!.trim().isNotEmpty);
    final hasGoogle = (profile?.googleAvatarUrl != null &&
        profile!.googleAvatarUrl!.trim().isNotEmpty);
    final status = _statusMessage();
    final statusOk = _availability?.available == true;
    final locked = _usernameLocked;
    final nextAt = profile?.usernameChangeAvailableAt;
    final canLeave =
        !widget.requireUsername || (profile?.hasUsername ?? false);

    return PopScope(
      canPop: canLeave,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileSettingsTitle),
          automaticallyImplyLeading: canLeave,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  if (widget.requireUsername &&
                      !(profile?.hasUsername ?? false)) ...[
                    AppFormCard(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        l10n.profileUsernameMustSet,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _AvatarPreview(
                              initial: initial,
                              avatarUrl: avatarUrl,
                            ),
                            SizedBox(width: 12),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: l10n.profileChangePhoto,
                                  onPressed: _saving ? null : _pickPhoto,
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.surfaceElevated,
                                    foregroundColor: AppColors.primary,
                                  ),
                                  icon: Icon(Icons.edit_outlined),
                                ),
                                SizedBox(height: 4),
                                IconButton(
                                  tooltip: l10n.profileRemoveCustomPhoto,
                                  onPressed: _saving || !_canClearAvatar
                                      ? null
                                      : _clearActiveAvatar,
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.surfaceElevated,
                                    foregroundColor: AppColors.muted,
                                  ),
                                  icon: Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          handle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.foreground,
                          ),
                        ),
                        if (avatarUrl == null) ...[
                          SizedBox(height: 4),
                          Text(
                            l10n.profileNoPhoto,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (!widget.requireUsername) ...[
                    AppSectionLabel(text: l10n.profileDuplicateRadiusSection),
                    SizedBox(height: 8),
                    AppFormCard(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.profileDuplicateRadiusHelp,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            l10n.profileDuplicateRadiusLabel(
                              _duplicateRadiusM.round(),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground,
                            ),
                          ),
                          Slider(
                            min: SavePolicies.minDuplicateSearchRadiusM
                                .toDouble(),
                            max: SavePolicies.maxDuplicateSearchRadiusM
                                .toDouble(),
                            divisions: ((SavePolicies
                                        .maxDuplicateSearchRadiusM -
                                    SavePolicies
                                        .minDuplicateSearchRadiusM) /
                                    10)
                                .round(),
                            label: '${_duplicateRadiusM.round()} m',
                            value: _duplicateRadiusM,
                            onChanged: _saving
                                ? null
                                : (v) =>
                                    setState(() => _duplicateRadiusM = v),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                  AppSectionLabel(text: l10n.profileUsernameLabel),
                  SizedBox(height: 8),
                  AppFormCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _usernameCtrl,
                          enabled: !locked,
                          readOnly: locked,
                          inputFormatters: [UsernameInputFormatter()],
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          onChanged: locked ? null : _onUsernameChanged,
                          decoration: InputDecoration(
                            prefixText: '@',
                            prefixStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            ),
                            hintText: l10n.profileUsernameHint,
                            filled: locked,
                            fillColor: locked
                                ? AppColors.surfaceElevated
                                : null,
                            suffixIcon: locked
                                ? Icon(
                                    Icons.lock_outline,
                                    color: AppColors.muted,
                                  )
                                : _checking
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : statusOk
                                        ? Icon(
                                            Icons.check_circle,
                                            color: AppColors.success,
                                          )
                                        : (_availability != null &&
                                                !_availability!.available)
                                            ? Icon(
                                                Icons.error_outline,
                                                color: AppColors.warning,
                                              )
                                            : null,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          locked && nextAt != null
                              ? l10n.profileUsernameLocked(
                                  formatDateDmY(nextAt),
                                )
                              : l10n.profileUsernameHelp,
                          style: TextStyle(
                            fontSize: 12,
                            color: locked
                                ? AppColors.warning
                                : AppColors.muted,
                            height: 1.35,
                            fontWeight:
                                locked ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        if (!locked && status != null) ...[
                          SizedBox(height: 8),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusOk
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                        if (!locked && _suggestions.isNotEmpty) ...[
                          SizedBox(height: 10),
                          Text(
                            l10n.profileUsernameSuggestions,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mutedDark,
                            ),
                          ),
                          SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final s in _suggestions)
                                ActionChip(
                                  label: Text('@$s'),
                                  onPressed: () {
                                    _usernameCtrl.text = s;
                                    _onUsernameChanged(s);
                                  },
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (hasGoogle) ...[
                    SizedBox(height: 20),
                    AppSectionLabel(text: l10n.profileAvatarSection),
                    SizedBox(height: 8),
                    if (hasCustom)
                      AppFormCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.profileAvatarSourceLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.mutedDark,
                              ),
                            ),
                            SizedBox(height: 8),
                            AppSegmentedControl<_AvatarSource>(
                              value: _useGoogleAvatar
                                  ? _AvatarSource.google
                                  : _AvatarSource.custom,
                              options: [
                                AppSegmentOption(
                                  value: _AvatarSource.google,
                                  label: l10n.profileAvatarSourceGoogle,
                                ),
                                AppSegmentOption(
                                  value: _AvatarSource.custom,
                                  label: l10n.profileAvatarSourceCustom,
                                ),
                              ],
                              onChanged: _saving
                                  ? (_) {}
                                  : (v) => _setAvatarSource(v),
                            ),
                          ],
                        ),
                      )
                    else
                      AppFormCard(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SwitchListTile.adaptive(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          title: Text(l10n.profileUseGoogleAvatar),
                          subtitle: Text(
                            l10n.profileUseGoogleAvatarHint,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                          value: _useGoogleAvatar,
                          onChanged:
                              _saving ? null : (v) => _toggleGoogleOnly(v),
                        ),
                      ),
                  ],
                ],
              ),
        bottomNavigationBar: _loading
            ? null
            : Material(
                color: AppColors.surface,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: FilledButton(
                      onPressed: _saving ? null : _saveUsername,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.actionSave),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.initial, this.avatarUrl});

  final String initial;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    return CircleAvatar(
      radius: 44,
      backgroundColor: AppColors.primary.withValues(alpha: 0.18),
      child: url != null && url.isNotEmpty
          ? ClipOval(
              child: AppNetworkImage(
                url: url,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
              ),
            )
          : Text(
              initial,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
    );
  }
}
