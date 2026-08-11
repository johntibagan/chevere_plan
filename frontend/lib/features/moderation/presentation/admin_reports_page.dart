import 'package:flutter/material.dart';

import '../../../core/errors/user_facing_error.dart';
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
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                    ],
                  )
                : _reports.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(24),
                        children: const [
                          SizedBox(height: 48),
                          Text(
                            'No hay reportes abiertos.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          final r = _reports[index];
                          final when = r.createdAt.toLocal();
                          final date =
                              '${when.day.toString().padLeft(2, '0')}/'
                              '${when.month.toString().padLeft(2, '0')}/'
                              '${when.year}';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              isThreeLine: true,
                              leading: r.photoPath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        widget.repository
                                            .publicPhotoUrl(r.photoPath!),
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) =>
                                            const Icon(Icons.photo),
                                      ),
                                    )
                                  : const Icon(Icons.flag_outlined),
                              title: Text(
                                r.siteName ?? 'Foto reportada',
                              ),
                              subtitle: Text(
                                [
                                  'Por ${r.reporterName}',
                                  date,
                                  if (r.reason != null && r.reason!.isNotEmpty)
                                    r.reason!,
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
