import 'package:flutter/material.dart';
import 'package:watch_it/app.dart';
import 'package:watch_it/core/services/service_locator.dart';

Future<void> main() async {
  // Required before touching SharedPreferences / platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Build the object graph once, before the first frame.
  await initServiceLocator();

  runApp(const WatchItApp());
}
