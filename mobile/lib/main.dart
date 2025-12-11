// mobile/lib/main.dart
// Main entry point for Andalus Smart POS application.
import 'dart:ui';

import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';
import 'src/utils/database_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    print('Platform Error: $error');
    return true;
  };
  // Initialize and migrate database
  try {
    await AppDatabase.migrateDatabase();
    await AppDatabase.verifyOTPTable();
    await AppDatabase.migrateSalesTable();
    await DatabaseInitializer.initializeDefaultData();
    print('App initialization completed successfully');
  } catch (e) {
    print('App initialization error: $e');
  }

  runApp(const ProviderScope(child: AndalusApp()));
}
