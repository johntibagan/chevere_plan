import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';
import '../l10n/context_l10n.dart';
import '../theme/app_typography.dart';
import '../theme/app_theme.dart';
import 'app_network_image.dart';

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
    required this.onProximity,
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
  final VoidCallback onProximity;
  final VoidCallback onAdmin;
  final VoidCallback onReports;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width * 0.86;
    final isDark = ref.watch(appThemeModeProvider) == ThemeMode.dark;

    return Drawer(
      backgroundColor: AppColors.surface,
      width: width.clamp(280.0, 360.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  onProfile();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                  child: Row(
                    children: [
                      _Avatar(initial: initial, avatarUrl: avatarUrl),
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
                        color: AppColors.mutedDark,
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
                  SwitchListTile(
                    secondary: Icon(
                      isDark
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: AppColors.muted,
                      size: 22,
                    ),
                    title: Text(
                      l10n.moreMenuDarkMode,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    subtitle: Text(
                      isDark
                          ? l10n.moreMenuDarkModeOn
                          : l10n.moreMenuDarkModeOff,
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    value: isDark,
                    activeThumbColor: AppColors.onPrimary,
                    activeTrackColor: AppColors.primary,
                    inactiveThumbColor: AppColors.muted,
                    inactiveTrackColor: AppColors.surfaceElevated,
                    onChanged: (value) {
                      unawaited(
                        ref.read(appThemeModeProvider.notifier).setDark(value),
                      );
                    },
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  ),
                  _MenuTile(
                    icon: Icons.notifications_active_outlined,
                    label: l10n.proximityTitle,
                    subtitle: l10n.moreMenuProximitySubtitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      onProximity();
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, this.avatarUrl});

  final String initial;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    return ClipOval(
      child: SizedBox(
        width: 48,
        height: 48,
        child: url != null && url.isNotEmpty
            ? AppNetworkImage(url: url, width: 48, height: 48)
            : ColoredBox(
                color: AppColors.primary.withValues(alpha: 0.2),
                child: Center(
                  child: Text(
                    initial,
                    style: AppTypography.cardTitle(color: AppColors.primary),
                  ),
                ),
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
