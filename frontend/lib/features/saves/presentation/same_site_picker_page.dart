import 'package:flutter/material.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_form_card.dart';
import '../data/save_models.dart';
import '../data/site_review_models.dart';
import 'open_site_detail.dart';
import 'site_look_cover.dart';

/// Lista de coincidencias: ver la ficha (como en Explorar) y luego usarla.
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
  String? _selectedId;

  void _pop(SameSitePick? result) => Navigator.of(context).pop(result);

  Future<void> _openFicha(PossibleDuplicate d) async {
    await openSiteDetail(context, siteId: d.siteId);
    if (!mounted) return;
    setState(() => _selectedId = d.siteId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selectedId != null;
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
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: widget.matches.length,
              separatorBuilder: (_, _) => SizedBox(height: 8),
              itemBuilder: (context, i) {
                final d = widget.matches[i];
                final on = d.siteId == _selectedId;
                return AppFormCard(
                  key: WidgetKeys.dupeMatch(d.siteId),
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: l10n.sameSiteMarkThis,
                        onPressed: () =>
                            setState(() => _selectedId = d.siteId),
                        icon: Icon(
                          on
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: on ? AppColors.primary : AppColors.muted,
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: d.siteId.isEmpty
                              ? null
                              : () => _openFicha(d),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: SiteLookCover(siteId: d.siteId),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.siteName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.foreground,
                                      ),
                                    ),
                                    if (_meta(d).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          _meta(d),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        l10n.sameSiteTapForDetail,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.mutedDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    key: WidgetKeys.dupeReview,
                    onPressed: !selected
                        ? null
                        : () => _pop(
                              SameSitePick(
                                action: SameSiteAction.reviewPublic,
                                siteId: _selectedId,
                              ),
                            ),
                    child: Text(l10n.sameSiteReviewPublic),
                  ),
                  SizedBox(height: 8),
                  OutlinedButton(
                    key: WidgetKeys.dupeJournal,
                    onPressed: !selected
                        ? null
                        : () => _pop(
                              SameSitePick(
                                action: SameSiteAction.journalPrivate,
                                siteId: _selectedId,
                              ),
                            ),
                    child: Text(l10n.sameSiteJournalPrivate),
                  ),
                  TextButton(
                    key: WidgetKeys.dupeKeepEditing,
                    onPressed: () => _pop(null),
                    child: Text(l10n.sameSiteKeepEditing),
                  ),
                  if (widget.allowCreateAnyway)
                    TextButton(
                      key: WidgetKeys.dupeSaveAnyway,
                      onPressed: () => _pop(
                        const SameSitePick(action: SameSiteAction.saveAnyway),
                      ),
                      child: Text(l10n.sameSiteSaveAnyway),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _meta(PossibleDuplicate d) {
    final l10n = context.l10n;
    final parts = <String>[
      if (d.city != null && d.city!.trim().isNotEmpty) d.city!.trim(),
      if (d.distanceM != null)
        l10n.sameSiteMetersAway(d.distanceM!.round()),
    ];
    return parts.join(' · ');
  }
}
