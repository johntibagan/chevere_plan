import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_version.dart';
import '../config/env.dart';
import '../di/providers.dart';
import '../l10n/context_l10n.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../theme/theme_rebuild.dart';
import 'app_menu_avatar_button.dart';
import 'app_segmented_control.dart';

/// Menú lateral derecho (estilo Google): cuenta arriba, acciones, salir al final.
class AppMoreMenuDrawer extends ConsumerWidget {
  const AppMoreMenuDrawer({
    super.key,
    required this.displayName,
    required this.initial,
    this.email,
    this.avatarUrl,
    required this.isStaff,
    required this.onProfile,
    required this.onCards,
    required this.onProximity,
    required this.onDuplicateRadius,
    required this.onDistanceUnit,
    required this.onAdmin,
    required this.onReports,
    required this.onSignOut,
  });

  final String displayName;
  final String initial;
  final String? email;
  final String? avatarUrl;
  final bool isStaff;
  final VoidCallback onProfile;
  final VoidCallback onCards;
  final VoidCallback onProximity;
  final VoidCallback onDuplicateRadius;
  final VoidCallback onDistanceUnit;
  final VoidCallback onAdmin;
  final VoidCallback onReports;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width * 0.86;
    final themeMode = ref.watch(appThemeModeProvider);

    return Drawer(
      backgroundColor: AppColors.surface,
      width: width.clamp(280.0, 360.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: AppColors.surfaceElevated,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  onProfile();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 16, 18),
                  child: Row(
                    children: [
                      AppUserAvatar(
                        initial: initial,
                        avatarUrl: avatarUrl,
                        size: 52,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.cardTitle(),
                            ),
                            if (email != null && email!.trim().isNotEmpty) ...[
                              SizedBox(height: 2),
                              Text(
                                email!.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                            SizedBox(height: 4),
                            Text(
                              l10n.moreMenuManageAccount,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.moreMenuTheme,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                        SizedBox(height: 10),
                        AppSegmentedControl<ThemeMode>(
                          value: themeMode,
                          options: [
                            AppSegmentOption(
                              value: ThemeMode.light,
                              label: l10n.moreMenuThemeLight,
                            ),
                            AppSegmentOption(
                              value: ThemeMode.dark,
                              label: l10n.moreMenuThemeDark,
                            ),
                            AppSegmentOption(
                              value: ThemeMode.system,
                              label: l10n.moreMenuThemeSystem,
                            ),
                          ],
                          onChanged: (mode) {
                            unawaited(
                              ref
                                  .read(appThemeModeProvider.notifier)
                                  .setMode(mode),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  _MenuTile(
                    icon: Icons.style_outlined,
                    label: l10n.homeCardsSection,
                    subtitle: l10n.moreMenuCardsSubtitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        onCards();
                      });
                    },
                  ),
                  _MenuTile(
                    icon: Icons.notifications_active_outlined,
                    label: l10n.proximityTitle,
                    subtitle: l10n.moreMenuProximitySubtitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        onProximity();
                      });
                    },
                  ),
                  _MenuTile(
                    icon: Icons.control_point_duplicate_outlined,
                    label: l10n.duplicateRadiusTitle,
                    subtitle: l10n.moreMenuDuplicateRadiusSubtitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        onDuplicateRadius();
                      });
                    },
                  ),
                  _MenuTile(
                    icon: Icons.straighten_rounded,
                    label: l10n.moreMenuDistanceUnit,
                    subtitle: l10n.moreMenuDistanceUnitSubtitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        onDistanceUnit();
                      });
                    },
                  ),
                  if (isStaff) ...[
                    _MenuTile(
                      icon: Icons.admin_panel_settings_outlined,
                      label: l10n.adminTitle,
                      onTap: () {
                        Navigator.of(context).pop();
                        onAdmin();
                      },
                    ),
                    _MenuTile(
                      icon: Icons.flag_outlined,
                      label: l10n.moreMenuReports,
                      onTap: () {
                        Navigator.of(context).pop();
                        onReports();
                      },
                    ),
                  ],
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: ref.watch(appVersionProvider).when(
                    data: (version) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.moreMenuAppVersion(version),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          l10n.moreMenuAppEnvironment(Env.appEnvironmentLabel),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.mutedDark,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
            ),
            _MenuTile(
              icon: Icons.logout_rounded,
              label: l10n.moreMenuSignOut,
              destructive: true,
              onTap: () {
                Navigator.of(context).pop();
                onSignOut();
              },
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.accent : AppColors.foreground;
    final iconColor = destructive ? AppColors.accent : AppColors.muted;
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
