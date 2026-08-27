import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/widgets/app_feed_layout_toggle.dart';
import '../../../core/widgets/app_retry_callout.dart';
import '../../../core/widgets/non_physical_card_banner.dart';
import '../../saves/data/save_models.dart';
import '../../saves/presentation/open_site_detail.dart';
import 'home_cards.dart';

/// Lista de guardados que no son lugar físico (menú ☰ → Tarjetas).
class CardsListPage extends ConsumerStatefulWidget {
  const CardsListPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const CardsListPage()),
    );
  }

  @override
  ConsumerState<CardsListPage> createState() => _CardsListPageState();
}

class _CardsListPageState extends ConsumerState<CardsListPage> {
  @override
  Widget build(BuildContext context) {
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    final layout = ref.watch(feedLayoutProvider);
    final async = ref.watch(mySavesProvider);
    final all = async.valueOrNull?.items ?? const <UserSave>[];
    final cards =
        all.where((s) => !s.isPhysicalPlace).toList(growable: false);
    final loading = async.isLoading && all.isEmpty;
    final failed = async.hasError && all.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeCardsSection),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppFeedLayoutToggle(
              value: layout,
              onChanged: (v) =>
                  ref.read(feedLayoutProvider.notifier).setLayout(v),
              listTooltip: l10n.feedLayoutList,
              grid2Tooltip: l10n.feedLayoutGrid2,
              grid3Tooltip: l10n.feedLayoutGrid3,
              grid4Tooltip: l10n.feedLayoutGrid4,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            ref.read(mySavesProvider.notifier).refresh(force: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: NonPhysicalCardBanner(),
              ),
            ),
            if (loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (failed)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppRetryCallout(
                  onRetry: () {
                    unawaited(
                      ref.read(mySavesProvider.notifier).refresh(force: true),
                    );
                  },
                ),
              )
            else if (cards.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.homeCardsEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: HomeFeedHits(
                    hits: [for (final s in cards) hitFromSave(s)],
                    layout: layout,
                    onTap: (hit) async {
                      final save = cards.firstWhere(
                        (s) => s.siteId == hit.siteId,
                      );
                      final outcome =
                          await openSiteDetail(context, save: save);
                      if (outcome != SiteDetailOutcome.none && mounted) {
                        await ref
                            .read(mySavesProvider.notifier)
                            .refresh(force: true);
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
