class BetaRelease {
  const BetaRelease({
    required this.version,
    required this.build,
    required this.apkUrl,
  });

  final String version;
  final int? build;
  final String? apkUrl;

  factory BetaRelease.fromJson(Map<String, dynamic> json) {
    final buildRaw = json['build'];
    int? build;
    if (buildRaw is int) {
      build = buildRaw;
    } else if (buildRaw != null) {
      build = int.tryParse(buildRaw.toString());
    }
    return BetaRelease(
      version: (json['version'] as String? ?? '').trim(),
      build: build,
      apkUrl: (json['apk_url'] as String?)?.trim(),
    );
  }

  bool get hasDownload => (apkUrl ?? '').isNotEmpty;

  bool get hasMinimumBuild => (build ?? 0) > 0;
}
