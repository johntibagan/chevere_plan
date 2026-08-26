import 'package:flutter/material.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_form_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_stat_card.dart';
import '../data/moderation_models.dart';
import '../data/moderation_repository.dart';

/// Listado de reportes abiertos para admin/root (§9: alarma desde el 1.er reporte).
class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key, required this.repository});

  final ModerationRepository repository;

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  bool _loading = true;
  String? _error;
  List<ContentReport> _reports = const [];
  final Map<String, String> _photoUrls = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reports = await widget.repository.listOpenReports();
      final withPath = reports
          .where((r) => r.photoPath != null && r.photoPath!.isNotEmpty)
          .map((r) => (id: r.id, storagePath: r.photoPath!));
      final urls =
          await widget.repository.signedPhotoUrlsParallel(withPath);
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _photoUrls
          ..clear()
          ..addAll(urls);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'retry';
        _loading = false;
      });
      AppToast.error(context, e, logContext: 'admin_reports');
    }
  }

  Future<void> _setStatus(ContentReport report, String status) async {
    try {
      await widget.repository.updateReportStatus(
        reportId: report.id,
        status: status,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: AppAsyncBody(
        loading: _loading,
        hasError: _error != null,
        isEmpty: _reports.isEmpty,
        emptyMessage: l10n.reportsEmpty,
        onRefresh: _load,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _reports.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppStatCard(
                  value: '${_reports.length}',
                  label: l10n.adminStatReports,
                  valueColor: AppColors.accent,
                  icon: Icons.flag_outlined,
                ),
              );
            }
            final r = _reports[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppFormCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    SizedBox(width: 10),
                    if (_photoUrls[r.id] != null)
                      AppNetworkImage(
                        url: _photoUrls[r.id]!,
                        cacheKey: r.photoPath ?? r.id,
                        width: 56,
                        height: 56,
                        borderRadius: BorderRadius.circular(8),
                      )
                    else
                      Icon(
                        r.targetType == 'review'
                            ? Icons.rate_review_outlined
                            : Icons.flag_outlined,
                        color: AppColors.accent,
                      ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.siteName ??
                                (r.targetType == 'review'
                                    ? l10n.reportsReviewFallback
                                    : l10n.reportsPhotoFallback),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.foreground,
                            ),
                          ),
                          Text(
                            [
                              r.targetType == 'review'
                                  ? l10n.reportsReviewLabel
                                  : l10n.reportsPhotoLabel,
                              l10n.reportsBy(r.reporterName),
                              formatDateDmY(r.createdAt),
                              if (r.reason != null && r.reason!.isNotEmpty)
                                r.reason!,
                            ].join(' · '),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          if (r.snippet != null && r.snippet!.isNotEmpty) ...[
                            SizedBox(height: 4),
                            Text(
                              r.snippet!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.foreground,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) => _setStatus(r, v),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'reviewed',
                          child: Text(l10n.reportsMarkReviewed),
                        ),
                        PopupMenuItem(
                          value: 'dismissed',
                          child: Text(l10n.reportsDismiss),
                        ),
                        PopupMenuItem(
                          value: 'actioned',
                          child: Text(l10n.reportsActioned),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
