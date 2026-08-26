import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Versión de la app (`pubspec` / build), p. ej. `1.0.0+1`.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  final build = info.buildNumber.trim();
  if (build.isEmpty) return info.version;
  return '${info.version}+$build';
});
