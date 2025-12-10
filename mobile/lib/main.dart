// mobile/lib/main.dart
import 'package:andalus_smart_pos/src/data/local/database.dart';
// import 'package:andalus_smart_pos/src/data/models/product.dart';
// import 'package:andalus_smart_pos/src/data/repositories/customer_repository.dart';
// import 'package:andalus_smart_pos/src/data/repositories/product_repository.dart';
// import 'package:andalus_smart_pos/src/data/repositories/sale_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';
import 'src/utils/database_init.dart';
// import 'src/utils/date_utils.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // final productRepo = ProductRepository();
//   // final customerRepo = CustomerRepository();
//   // final saleRepo = SaleRepository();
//   FlutterError.onError = (FlutterErrorDetails details) {
//     FlutterError.presentError(details);
//     print('Flutter Error: ${details.exception}');
//   };

//   // Initialize and migrate database
//   try {
//     await AppDatabase.migrateDatabase();
//     await AppDatabase.verifyOTPTable();
//     await AppDatabase.migrateSalesTable();
//     await DatabaseInitializer.initializeDefaultData();
//     // await productRepo.createProduct(
//     //   // Sample product for testing
//     //   Product(
//     //     id: 1,
//     //     name: 'Sample Product',
//     //     price: 9.99,
//     //     categoryId: 'cat1',
//     //     isActive: true,
//     //     createdAt: DateTime.now(),
//     //     updatedAt: DateTime.now(),
//     //     productId: '',
//     //     nameAm: '',
//     //     stockQuantity: 100,
//     //     barcode: '',
//     //   ),
//     // );
//     // await customerRepo.createSampleCustomers();
//     // await saleRepo.createSampleSales();

//     // Initialize calendar and date utilities
//     // await AppDateUtils.initialize();

//     print('App initialization completed successfully');
//   } catch (e) {
//     print('App initialization error: $e');
//   }

//   runApp(const ProviderScope(child: AndalusApp()));
// }
// In main.dart - fix the initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
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
