import 'package:andalus_smart_pos/src/data/local/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';
import 'src/utils/database_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize and migrate database
  try {
    await AppDatabase.migrateDatabase();
    await AppDatabase.migrateSalesTable();
    await DatabaseInitializer.initializeDefaultData(); // Add this line
    print('Database initialization completed successfully');
  } catch (e) {
    print('Database initialization error: $e');
    await AppDatabase.resetDatabase();
    await AppDatabase.migrateDatabase();
    await AppDatabase.migrateSalesTable();
    await DatabaseInitializer.initializeDefaultData(); // And this line
  }

  runApp(const ProviderScope(child: AndalusApp()));
}
