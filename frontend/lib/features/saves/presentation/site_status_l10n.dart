import '../../../l10n/app_localizations.dart';
import '../data/save_models.dart';

extension SiteStatusL10n on SiteStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case SiteStatus.pendingLocation:
        return l10n.statusPendingLocation;
      case SiteStatus.complete:
        return l10n.statusComplete;
      case SiteStatus.draft:
        return l10n.statusDraft;
    }
  }
}
