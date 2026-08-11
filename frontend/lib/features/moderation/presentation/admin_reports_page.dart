import 'package:flutter/material.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/widgets/app_async_body.dart';
import '../../../core/widgets/app_list_card.dart';
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
      if (!mounted) return;
      setState(() {
        _reports = reports;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes de contenido')),
      body: AppAsyncBody(
        loading: _loading,
        error: _error,
        isEmpty: _reports.isEmpty,
        emptyMessage: 'No hay reportes abiertos.',
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
                leading: r.photoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          widget.repository.publicPhotoUrl(r.photoPath!),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.photo),
                        ),
                      )
                    : const Icon(Icons.flag_outlined),
                title: Text(r.siteName ?? 'Foto reportada'),
                subtitle: Text(
                  [
                    'Por ${r.reporterName}',
                    formatDateDmY(r.createdAt),
                    if (r.reason != null && r.reason!.isNotEmpty) r.reason!,
                  ].join(' · '),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => _setStatus(r, v),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'reviewed',
                      child: Text('Marcar revisado'),
                    ),
                    PopupMenuItem(
                      value: 'dismissed',
                      child: Text('Descartar'),
                    ),
                    PopupMenuItem(
                      value: 'actioned',
                      child: Text('Acción tomada'),
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
