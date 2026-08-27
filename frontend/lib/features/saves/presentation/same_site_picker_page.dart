import 'package:flutter/material.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/prefs/feed_layout.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_form_card.dart';
import '../../../core/widgets/site_cover.dart';
import '../../../core/widgets/site_origin_tags.dart';
import '../../../core/widgets/visibility_badge.dart';
import '../../home/presentation/home_cards.dart';
import '../data/save_models.dart';
import '../data/site_review_models.dart';
import 'open_site_detail.dart';
import 'site_look_cover.dart';

/// Grilla de coincidencias: en cada tarjeta Ver ficha / Usarlo; confirmación al usar.
class SameSitePickerPage extends StatefulWidget {
  const SameSitePickerPage({
    super.key,
    required this.matches,
    required this.allowCreateAnyway,
  });

  final List<PossibleDuplicate> matches;
  final bool allowCreateAnyway;

  @override
  State<SameSitePickerPage> createState() => _SameSitePickerPageState();
}

class _SameSitePickerPageState extends State<SameSitePickerPage> {
  String? _useConfirmSiteId;
  SameSiteAction? _selectedUseAction;

  PossibleDuplicate? _matchFor(String? siteId) {
    if (siteId == null) return null;
    for (final m in widget.matches) {
      if (m.siteId == siteId) return m;
    }
    return null;
  }

  void _pop(SameSitePick? result) => Navigator.of(context).pop(result);

  void _openUseConfirm(PossibleDuplicate d) {
    setState(() {
      _useConfirmSiteId = d.siteId;
      _selectedUseAction = null;
    });
  }

  Future<void> _openFicha(PossibleDuplicate d) async {
    await openSiteDetail(context, siteId: d.siteId);
  }

  bool _canSelect(SameSiteAction action, PossibleDuplicate match) {
    switch (action) {
      case SameSiteAction.reviewPublic:
        return match.canReviewPublic;
      case SameSiteAction.journalPrivate:
      case SameSiteAction.addFavorite:
        return true;
      case SameSiteAction.saveAnyway:
        return false;
    }
  }

  Future<void> _confirmUse(PossibleDuplicate match) async {
    final action = _selectedUseAction;
    if (action == null || !_canSelect(action, match)) return;

    final l10n = context.l10n;
    final body = switch (action) {
      SameSiteAction.reviewPublic => l10n.sameSiteDiscardConfirmBodyReview,
      SameSiteAction.journalPrivate => l10n.sameSiteDiscardConfirmBodyJournal,
      SameSiteAction.addFavorite => l10n.sameSiteDiscardConfirmBodyFavorite,
      _ => l10n.sameSiteDiscardConfirmBodyGeneric,
    };

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.sameSiteDiscardConfirmTitle,
          style: TextStyle(color: AppColors.foreground),
        ),
        content: Text(
          body,
          style: TextStyle(color: AppColors.muted, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.sameSiteUseConfirmSave),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _pop(SameSitePick(action: action, siteId: match.siteId));
  }

  Widget _infoTip(String message, {required Key key}) {
    return Tooltip(
      key: key,
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 8),
      waitDuration: Duration.zero,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.info_outline, size: 20, color: AppColors.muted),
      ),
    );
  }

  Widget _useOptionTile({
    required Key key,
    required SameSiteAction action,
    required String title,
    required String info,
    required Key infoKey,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Radio<SameSiteAction>(
          value: action,
          groupValue: _selectedUseAction,
          onChanged: (v) => setState(() => _selectedUseAction = v),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: InkWell(
            key: key,
            onTap: () => setState(() => _selectedUseAction = action),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ),
        ),
        _infoTip(info, key: infoKey),
      ],
    );
  }

  Widget _useConfirmCard(PossibleDuplicate match) {
    final l10n = context.l10n;
    final canConfirm = _selectedUseAction != null &&
        _canSelect(_selectedUseAction!, match);
    return AppFormCard(
      key: WidgetKeys.dupeUseConfirm,
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SiteCardOriginRow(
            isPublic: match.isPublic,
            isOwn: match.isOwn,
            isLinked: match.isLinked,
            isCatalog: match.isCatalog,
          ),
          SizedBox(height: 6),
          SiteCardPlaceTexts(
            name: match.siteName,
            department: match.department,
            city: match.city,
            addressLine: match.addressLine,
            nameSize: 15,
          ),
          SizedBox(height: 8),
          Text(
            l10n.sameSiteUsePickOption,
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          if (match.canReviewPublic)
            _useOptionTile(
              key: WidgetKeys.dupeReview,
              action: SameSiteAction.reviewPublic,
              title: l10n.sameSiteOptionReviewPublic,
              info: l10n.sameSiteReviewPublicHint,
              infoKey: WidgetKeys.dupeReviewInfo,
            ),
          _useOptionTile(
            key: WidgetKeys.dupeJournal,
            action: SameSiteAction.journalPrivate,
            title: l10n.sameSiteOptionReviewPrivate,
            info: l10n.sameSiteReviewPrivateHint,
            infoKey: WidgetKeys.dupeJournalInfo,
          ),
          _useOptionTile(
            key: WidgetKeys.dupeFavorite,
            action: SameSiteAction.addFavorite,
            title: l10n.sameSiteOptionFavorite,
            info: l10n.sameSiteFavoriteHint,
            infoKey: WidgetKeys.dupeFavoriteInfo,
          ),
          SizedBox(height: 4),
          FilledButton(
            key: WidgetKeys.dupeConfirmSave,
            onPressed: canConfirm ? () => _confirmUse(match) : null,
            child: Text(l10n.sameSiteUseConfirmSave),
          ),
        ],
      ),
    );
  }

  Widget _siteGridCard(PossibleDuplicate d) {
    final l10n = context.l10n;
    final isActive = _useConfirmSiteId == d.siteId;
    final vis = d.isPublic ? AppColors.success : AppColors.purple;
    final cardBg = isActive
        ? Color.alphaBlend(
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.surface,
          )
        : AppColors.surface;

    return Material(
      key: WidgetKeys.dupeMatch(d.siteId),
      color: cardBg,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? AppColors.primary : vis.withValues(alpha: 0.55),
          width: isActive ? 3 : 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Textos ≈ 40% de la celda (fijos). CTA compactos restan solo a la portada.
          const actionH = 30.0;
          final textH = constraints.maxHeight * 0.4;
          final imageRaw = constraints.maxHeight - textH - actionH;
          final imageH = imageRaw < 0 ? 0.0 : imageRaw;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: imageH,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SiteLookCover(siteId: d.siteId),
                    const SiteCoverScrim(),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: VisibilityStripe(isPublic: d.isPublic),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: textH,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SiteCardOriginRow(
                        isPublic: d.isPublic,
                        isOwn: d.isOwn,
                        isLinked: d.isLinked,
                        isCatalog: d.isCatalog,
                      ),
                      SizedBox(height: 2),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: SiteCardPlaceTexts(
                            name: d.siteName,
                            department: d.department,
                            city: d.city,
                            addressLine: d.addressLine,
                            nameSize: 12,
                          ),
                        ),
                      ),
                      if (d.distanceM != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            l10n.sameSiteMetersAway(d.distanceM!.round()),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.mutedDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: actionH,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: TextButton(
                          key: WidgetKeys.dupeViewFicha(d.siteId),
                          onPressed:
                              d.siteId.isEmpty ? null : () => _openFicha(d),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.muted,
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            minimumSize: Size.zero,
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.sameSiteTapForDetail,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: FilledButton(
                          key: WidgetKeys.dupeUseIt(d.siteId),
                          onPressed: d.siteId.isEmpty
                              ? null
                              : () => _openUseConfirm(d),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: isActive
                                ? AppColors.surface
                                : AppColors.primary,
                            foregroundColor: isActive
                                ? AppColors.foreground
                                : AppColors.onPrimary,
                            side: isActive
                                ? BorderSide(
                                    color: AppColors.foreground,
                                    width: 1.5,
                                  )
                                : BorderSide.none,
                          ),
                          child: Text(
                            l10n.sameSiteUseIt,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _secondaryActionRow({
    required Key actionKey,
    required Key infoKey,
    required String label,
    required String info,
    required VoidCallback onAction,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextButton(
            key: actionKey,
            onPressed: onAction,
            child: Text(label),
          ),
        ),
        _infoTip(info, key: infoKey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final confirmMatch = _matchFor(_useConfirmSiteId);

    return Scaffold(
      key: WidgetKeys.dupePicker,
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.sameSiteTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              widget.allowCreateAnyway
                  ? l10n.sameSiteHardPickHint
                  : l10n.sameSitePickHint,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final ratio = SiteCardGridMetrics.twoColumnAspectRatio(
                  constraints.maxWidth,
                  horizontalPadding: 32,
                  crossAxisSpacing: 12,
                  footerEstimate: 132,
                );
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: ratio,
                  ),
                  itemCount: widget.matches.length,
                  itemBuilder: (context, i) =>
                      _siteGridCard(widget.matches[i]),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (confirmMatch != null) ...[
                    _useConfirmCard(confirmMatch),
                    SizedBox(height: 4),
                  ],
                  if (widget.allowCreateAnyway)
                    _secondaryActionRow(
                      actionKey: WidgetKeys.dupeSaveAnyway,
                      infoKey: WidgetKeys.dupeSaveAnywayInfo,
                      label: l10n.sameSiteSaveAnyway,
                      info: l10n.sameSiteSaveAnywayHint,
                      onAction: () => _pop(
                        const SameSitePick(action: SameSiteAction.saveAnyway),
                      ),
                    ),
                  if (!widget.allowCreateAnyway)
                    _secondaryActionRow(
                      actionKey: WidgetKeys.dupeKeepEditing,
                      infoKey: WidgetKeys.dupeKeepEditingInfo,
                      label: l10n.sameSiteKeepEditing,
                      info: l10n.sameSiteKeepEditingHint,
                      onAction: () => _pop(null),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
