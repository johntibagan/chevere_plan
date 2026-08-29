import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/env.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/logging/app_log.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/beta_release.dart';

enum BetaUpdateStatus { upToDate, updateRequired }

class BetaUpdateState {
  const BetaUpdateState({
    required this.status,
    this.release,
    required this.localVersionLabel,
  });

  final BetaUpdateStatus status;
  final BetaRelease? release;
  final String localVersionLabel;
}

final betaUpdateStateProvider = FutureProvider<BetaUpdateState>((ref) async {
  if (!Env.isBetaRelease) {
    return const BetaUpdateState(
      status: BetaUpdateStatus.upToDate,
      localVersionLabel: '',
    );
  }

  final info = await PackageInfo.fromPlatform();
  final localBuild = int.tryParse(info.buildNumber.trim()) ?? 0;
  final localVersionLabel = info.buildNumber.trim().isEmpty
      ? info.version
      : '${info.version}+${info.buildNumber.trim()}';

  try {
    final release =
        await ref.read(betaReleaseRepositoryProvider).fetchCurrent();
    if (release == null || !release.hasMinimumBuild) {
      return BetaUpdateState(
        status: BetaUpdateStatus.upToDate,
        localVersionLabel: localVersionLabel,
      );
    }
    if (localBuild < release.build!) {
      return BetaUpdateState(
        status: BetaUpdateStatus.updateRequired,
        release: release,
        localVersionLabel: localVersionLabel,
      );
    }
    return BetaUpdateState(
      status: BetaUpdateStatus.upToDate,
      release: release,
      localVersionLabel: localVersionLabel,
    );
  } catch (e, st) {
    AppLog.error('beta update check', name: 'beta', error: e, stackTrace: st);
    rethrow;
  }
});

/// Bloquea el APK beta/PDN si hay build más reciente en `beta_release` (PDN).
class BetaUpdateGate extends ConsumerWidget {
  const BetaUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Env.isBetaRelease) return child;

    final check = ref.watch(betaUpdateStateProvider);
    return check.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => child,
      data: (state) {
        if (state.status == BetaUpdateStatus.updateRequired &&
            state.release != null) {
          return BetaUpdateRequiredPage(
            release: state.release!,
            localVersionLabel: state.localVersionLabel,
          );
        }
        return child;
      },
    );
  }
}

class BetaUpdateRequiredPage extends ConsumerWidget {
  const BetaUpdateRequiredPage({
    super.key,
    required this.release,
    required this.localVersionLabel,
  });

  final BetaRelease release;
  final String localVersionLabel;

  Future<void> _openDownload(BuildContext context) async {
    final url = release.apkUrl?.trim();
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final remoteLabel = release.build != null && release.build! > 0
        ? '${release.version}+${release.build}'
        : release.version;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Icon(
                  Icons.system_update_alt,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.betaUpdateTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.betaUpdateBody(remoteLabel),
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.betaUpdateCurrentVersion(localVersionLabel),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                FilledButton(
                  onPressed: release.hasDownload
                      ? () => unawaited(_openDownload(context))
                      : null,
                  child: Text(l10n.betaUpdateDownload),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(betaUpdateStateProvider),
                  child: Text(l10n.betaUpdateRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
