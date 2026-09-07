import 'package:flutter/material.dart';

import 'bootstrap.dart';

/// Arranque: [createRootApp] inicializa Firebase y registra Crashlytics
/// (`FlutterError.onError` + `PlatformDispatcher.onError`) antes de [runApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = await createRootApp();
  runApp(app);
}
