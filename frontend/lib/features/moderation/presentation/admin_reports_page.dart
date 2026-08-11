import 'package:flutter/material.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_list_card.dart';
import '../../../core/widgets/app_network_image.dart';
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
        _error = userFacingError(e);
        _loading = false;
      });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: AppAsyncBody(
        loading: _loading,
        error: _error,
        isEmpty: _reports.isEmpty,
        emptyMessage: l10n.reportsEmpty,
        onRefresh: _load,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _reports.length,
          itemBuilder: (context, index) {
            final r = _reports[index];
            return AppListCard(
              child: ListTile(
                isThreeLine: true,
                leading: _photoUrls[r.id] != null
                    ? AppNetworkImage(
                        url: _photoUrls[r.id]!,
                        cacheKey: r.photoPath ?? r.id,
                        width: 56,
                        height: 56,
                        borderRadius: BorderRadius.circular(6),
                      )
                    : const Icon(Icons.flag_outlined),
                title: Text(r.siteName ?? l10n.reportsPhotoFallback),
                subtitle: Text(
                  [
                    l10n.reportsBy(r.reporterName),
                    formatDateDmY(r.createdAt),
                    if (r.reason != null && r.reason!.isNotEmpty) r.reason!,
                  ].join(' · '),
                ),
                trailing: PopupMenuButton<String>(
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
              ),
            );
          },
        ),
      ),
    );
  }
}
