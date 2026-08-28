import '../../features/saves/data/save_models.dart';
import '../../l10n/app_localizations.dart';

/// Motivos concretos devueltos por `site_privacy_blockers` (orden fijo).
List<String> privacyBlockReasons(
  AppLocalizations l10n,
  SitePrivacyBlockers blockers,
) {
  final reasons = <String>[];
  if (blockers.isCatalog) {
    reasons.add(l10n.privacyBlockReasonCatalog);
  }
  if (blockers.otherSaves > 0) {
    reasons.add(l10n.privacyBlockReasonSaves(blockers.otherSaves));
  }
  if (blockers.otherContributors > 0) {
    reasons.add(l10n.privacyBlockReasonContributors(blockers.otherContributors));
  }
  if (blockers.otherPlanStops > 0) {
    reasons.add(l10n.privacyBlockReasonPlanStops(blockers.otherPlanStops));
  }
  if (blockers.otherReviews > 0) {
    reasons.add(l10n.privacyBlockReasonReviews(blockers.otherReviews));
  }
  return reasons;
}

String formatPrivacyBlockBody(
  AppLocalizations l10n,
  SitePrivacyBlockers blockers,
) {
  return privacyBlockReasons(l10n, blockers).join('\n');
}
