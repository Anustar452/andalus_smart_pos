// mobile/lib/src/services/local_db_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/models.dart';

class LocalDbService {
  static const String _dbName = 'andalus_pos.db';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        barcode TEXT,
        description TEXT,
        price REAL NOT NULL,
        cost_price REAL,
        stock_quantity INTEGER NOT NULL,
        min_stock INTEGER,
        category TEXT,
        image TEXT,
        is_active INTEGER NOT NULL,
        shop_id INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        transaction_number TEXT NOT NULL,
        total_amount REAL NOT NULL,
        tax_amount REAL NOT NULL,
        discount_amount REAL NOT NULL,
        paid_amount REAL NOT NULL,
        change_amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        payment_reference TEXT,
        status TEXT NOT NULL,
        is_online INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Transaction items table
    await db.execute('''
      CREATE TABLE transaction_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
    await db.execute(
      'CREATE INDEX idx_transactions_created_at ON transactions(created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_sync_queue_created_at ON sync_queue(created_at)',
    );
  }

  // Product operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toJson());
  }

  Future<List<Product>> getProducts({String? search}) async {
    final db = await database;
    var where = 'is_active = 1';
    var whereArgs = [];

    if (search != null && search.isNotEmpty) {
      where += ' AND (name LIKE ? OR barcode = ?)';
      whereArgs.add('%$search%');
      whereArgs.add(search);
    }

    final results = await db.query(
      'products',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );

    return results.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final results = await db.query(
      'products',
      where: 'barcode = ? AND is_active = 1',
      whereArgs: [barcode],
    );

    if (results.isNotEmpty) {
      return Product.fromJson(results.first);
    }
    return null;
  }

  // Transaction operations
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    final transactionId = await db.insert('transactions', {
      'transaction_number': transaction.transactionNumber,
      'total_amount': transaction.totalAmount,
      'tax_amount': transaction.taxAmount,
      'discount_amount': transaction.discountAmount,
      'paid_amount': transaction.paidAmount,
      'change_amount': transaction.changeAmount,
      'payment_method': transaction.paymentMethod,
      'payment_reference': transaction.paymentReference,
      'status': transaction.status,
      'is_online': 0,
      'created_at': transaction.createdAt.toIso8601String(),
      'is_synced': 0,
    });

    // Insert transaction items
    for (final item in transaction.items) {
      await db.insert('transaction_items', {
        'transaction_id': transactionId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'total_price': item.totalPrice,
      });
    }

    return transactionId;
  }

  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    var where = '1=1';
    var whereArgs = [];

    if (startDate != null) {
      where += ' AND DATE(created_at) >= ?';
      whereArgs.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      where += ' AND DATE(created_at) <= ?';
      whereArgs.add(endDate.toIso8601String().split('T')[0]);
    }

    final transactionResults = await db.query(
      'transactions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    final transactions = <Transaction>[];

    for (final txData in transactionResults) {
      final items = await db.query(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: [txData['id']],
      );

      final productIds = items.map((item) => item['product_id']).toList();
      final products = await db.query(
        'products',
        where: 'id IN (${List.filled(productIds.length, '?').join(',')})',
        whereArgs: productIds,
      );

      final transactionItems = items.map((item) {
        final productData = products.firstWhere(
          (p) => p['id'] == item['product_id'],
        );

        return TransactionItem(
          id: item['id'] as int,
          productId: item['product_id'] as int,
          product: Product.fromJson(productData),
          quantity: item['quantity'] as int,
          unitPrice: (item['unit_price'] as num).toDouble(),
          totalPrice: (item['total_price'] as num).toDouble(),
        );
      }).toList();

      transactions.add(
        Transaction(
          id: txData['id'] as int,
          transactionNumber: txData['transaction_number'] as String,
          totalAmount: (txData['total_amount'] as num).toDouble(),
          taxAmount: (txData['tax_amount'] as num).toDouble(),
          discountAmount: (txData['discount_amount'] as num).toDouble(),
          paidAmount: (txData['paid_amount'] as num).toDouble(),
          changeAmount: (txData['change_amount'] as num).toDouble(),
          paymentMethod: txData['payment_method'] as String,
          paymentReference: txData['payment_reference'] as String?,
          status: txData['status'] as String,
          createdAt: DateTime.parse(txData['created_at'] as String),
          items: transactionItems.toList(),
        ),
      );
    }

    return transactions;
  }

  // Sync operations
  Future<void> addToSyncQueue({
    required String tableName,
    required int recordId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<void> removeFromSyncQueue(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }
}

final localDbServiceProvider = Provider<LocalDbService>(
  (ref) => LocalDbService(),
);
