import 'package:flutter/material.dart';

import 'app.dart';
import 'core/background/background.dart';
import 'core/sync/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final services = await AppServices.bootstrap();
  await setupBackgroundSync();
  await services.startForeground();

  runApp(NotesApp(services: services));
}
