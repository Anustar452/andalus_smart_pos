// mobile/lib/src/data/local/database.dart
// my question here for deepseek ai is for optimizing the following for making this app not crushy fast and reliable applying best practices for flutter sqflite database management and  stll keeping all the existing functionalities and migrations
// and also adding any missing functionalities that are important for a pos app database management feasible to the back end laravel api design
import 'package:andalus_smart_pos/src/data/models/otp.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static const _databaseName = "andalus_pos.db";
  // static const _databaseVersion = 6; // Increment version to trigger migration
  static const _databaseVersion = 8; // Increment version to trigger migration

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX idx_sales_created ON sales(created_at)');
    await db
        .execute('CREATE INDEX idx_products_category ON products(category_id)');
    await db.execute('CREATE INDEX idx_customers_phone ON customers(phone)');
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    print('Database path: $path');
    print('Database version: $_databaseVersion');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    print('Creating database with version: $version');
    await _createAllTables(db);
  }

  static Future<void> ensureOTPTable() async {
    final db = await database;

    try {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS otps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        otp_id TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        code TEXT NOT NULL,
        type TEXT NOT NULL,
        is_used INTEGER DEFAULT 0,
        expires_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
      print('✅ OTP table ensured');
    } catch (e) {
      print('❌ Error ensuring OTP table: $e');
    }
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from $oldVersion to $newVersion');

    // Handle incremental migrations
    if (oldVersion < 2) {
      await _createCustomerTables(db);
    }

    if (oldVersion < 3) {
      await _migrateToVersion3(db);
    }

    if (oldVersion < 4) {
      await _migrateToVersion4(db);
    }

    if (oldVersion < 5) {
      await _migrateToVersion5(db);
    }

    if (oldVersion < 6) {
      await _migrateToVersion6(db);
    }
    if (oldVersion < 7) {
      await _migrateToVersion7(db);
    }

    if (oldVersion < 8) {
      await _migrateToVersion8(db);
    }
  }

  static Future<void> _migrateToVersion8(Database db) async {
    print(
        'Migrating to version 8 - Making email column nullable in users table');

    try {
      // Create a temporary table without the UNIQUE constraint on email
      await db.execute('''
      CREATE TABLE users_temp (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        phone TEXT UNIQUE NOT NULL,
        email TEXT,
        password_hash TEXT,
        role TEXT NOT NULL DEFAULT 'cashier',
        is_verified INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        business_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_login_at INTEGER
      )
    ''');

      // Copy data from old table to new table
      await db.execute('''
      INSERT INTO users_temp 
      SELECT * FROM users
    ''');

      // Drop old table
      await db.execute('DROP TABLE users');

      // Rename new table
      await db.execute('ALTER TABLE users_temp RENAME TO users');

      print('✅ Users table updated successfully - email is now nullable');
    } catch (e) {
      print('❌ Error in version 8 migration: $e');
      // If migration fails, the app should still work
    }
  }

  static Future<void> _migrateToVersion7(Database db) async {
    print('Migrating to version 7 - Recreating OTP table with correct schema');

    try {
      // Simply drop and recreate the OTP table
      await db.execute('DROP TABLE IF EXISTS otps');

      await db.execute('''
      CREATE TABLE otps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        otp_id TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        code TEXT NOT NULL,
        type TEXT NOT NULL,
        is_used INTEGER DEFAULT 0,
        expires_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

      print('✅ OTP table recreated successfully in version 7 migration');

      // Add any indexes for better performance
      await db
          .execute('CREATE INDEX IF NOT EXISTS idx_otp_phone ON otps(phone)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_otp_expires ON otps(expires_at)');
    } catch (e) {
      print('❌ Error in version 7 migration: $e');
      rethrow;
    }
  }

  static Future<void> _migrateToVersion6(Database db) async {
    print('Migrating to version 6 - Adding status column to subscriptions');
    await _addStatusColumnToSubscriptions(db);
  }

  static Future<void> _migrateToVersion5(Database db) async {
    print('Migrating to version 5 - Adding user management and OTP tables');
    await _createUserManagementTables(db);
  }

  static Future<void> _migrateToVersion4(Database db) async {
    print('Migrating to version 4 - Adding business and category tables');
    await _createBusinessTables(db);
  }

  static Future<void> _migrateToVersion3(Database db) async {
    print('Migrating to version 3 - No migration steps defined');
  }

  static Future<void> _addStatusColumnToSubscriptions(Database db) async {
    // Check if status column exists
    final tableInfo = await db.rawQuery("PRAGMA table_info(subscriptions)");
    final hasStatusColumn = tableInfo.any((col) => col['name'] == 'status');

    if (!hasStatusColumn) {
      print('Adding status column to subscriptions table');
      await db.execute(
          'ALTER TABLE subscriptions ADD COLUMN status TEXT DEFAULT "active"');
    }

    // Check if payment_reference column exists
    final hasPaymentRefColumn =
        tableInfo.any((col) => col['name'] == 'payment_reference');
    if (!hasPaymentRefColumn) {
      print('Adding payment_reference column to subscriptions table');
      await db.execute(
          'ALTER TABLE subscriptions ADD COLUMN payment_reference TEXT');
    }
  }

  static Future<void> _createAllTables(Database db) async {
    // Create all existing tables
    await _createCustomerTables(db);
    await _createSalesTables(db);
    await _createBusinessTables(db);
    await _createUserManagementTables(db);

    print('All tables created successfully');
  }

  // User Management Tables - Updated with correct schema
  static Future<void> _createUserManagementTables(Database db) async {
    // Enhanced users table without foreign key constraint for now
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        phone TEXT UNIQUE NOT NULL,
        email TEXT,
        password_hash TEXT,
        role TEXT NOT NULL DEFAULT 'cashier',
        is_verified INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        business_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_login_at INTEGER
      )
    ''');

    // OTP table for phone verification
    await db.execute('''
      CREATE TABLE IF NOT EXISTS otps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        otp_id TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        code TEXT NOT NULL,
        type TEXT NOT NULL,
        is_used INTEGER DEFAULT 0,
        expires_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Enhanced subscription table with ALL columns
    await db.execute('''
    CREATE TABLE IF NOT EXISTS subscriptions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      subscription_id TEXT UNIQUE NOT NULL,
      business_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      plan TEXT NOT NULL,
      billing_cycle TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT "active",
      amount REAL NOT NULL,
      start_date INTEGER NOT NULL,
      end_date INTEGER NOT NULL,
      is_active INTEGER DEFAULT 1,
      currency TEXT DEFAULT 'ETB',
      payment_reference TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (business_id) REFERENCES business_profile (business_id),
      FOREIGN KEY (user_id) REFERENCES users (user_id)
    )
  ''');

    print('User management tables created successfully');
  }

// Add this to lib/src/data/local/database.dart
  static Future<void> debugOTPTable() async {
    final db = await database;

    try {
      // Check if table exists
      final tableInfo = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='otps'");
      print('📋 OTP table exists: ${tableInfo.isNotEmpty}');

      if (tableInfo.isNotEmpty) {
        // Check table schema
        final schema = await db.rawQuery("PRAGMA table_info(otps)");
        print('🔍 OTP Table Schema:');
        for (var column in schema) {
          print('   ${column['name']} - ${column['type']}');
        }

        // Check all OTPs in table
        final allOtps = await db.query('otps');
        print('📊 Total OTPs in database: ${allOtps.length}');
        for (var otp in allOtps) {
          print(
              '   OTP: ${otp['otp_id']} - ${otp['phone']} - ${otp['code']} - Used: ${otp['is_used']}');
        }
      }
    } catch (e) {
      print('❌ Error debugging OTP table: $e');
    }
  }

  // ... rest of your existing methods remain the same
  static Future<void> _createSalesTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_id TEXT UNIQUE NOT NULL,
      customer_id INTEGER,
      total_amount REAL NOT NULL,
      final_amount REAL NOT NULL,
      tax_amount REAL DEFAULT 0,
      discount_amount REAL DEFAULT 0,
      payment_method TEXT NOT NULL,
      payment_status TEXT DEFAULT 'completed',
      sale_status TEXT DEFAULT 'completed',
      user_id INTEGER NOT NULL,
      shop_id INTEGER NOT NULL,
      is_synced INTEGER DEFAULT 0,
      sync_attempts INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER,
      FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE SET NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS sale_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_id TEXT NOT NULL,
      product_id TEXT NOT NULL,
      product_name TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      unit_price REAL NOT NULL,
      total_price REAL NOT NULL,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (sale_id) REFERENCES sales (sale_id) ON DELETE CASCADE
    )
  ''');
  }

  static Future<void> _createBusinessTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS business_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        name_am TEXT NOT NULL,
        business_type TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        address TEXT NOT NULL,
        city TEXT,
        region TEXT,
        tin_number TEXT NOT NULL,
        vat_number TEXT,
        business_license TEXT,
        owner_name TEXT,
        owner_phone TEXT,
        owner_email TEXT,
        currency TEXT DEFAULT 'ETB',
        logo_path TEXT,
        receipt_header TEXT,
        receipt_footer TEXT,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS product_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        name_am TEXT NOT NULL,
        description TEXT,
        color TEXT,
        icon TEXT,
        parent_id INTEGER,
        sort_order INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES product_categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        name_am TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        cost_price REAL,
        stock_quantity INTEGER NOT NULL,
        min_stock_level INTEGER,
        barcode TEXT NOT NULL,
        sku TEXT,
        category_id TEXT NOT NULL,
        unit TEXT,
        brand TEXT,
        supplier TEXT,
        weight REAL,
        size TEXT,
        color TEXT,
        image_path TEXT,
        track_inventory INTEGER DEFAULT 1,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES product_categories (category_id)
      )
    ''');
  }

  static Future<void> _createCustomerTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        business_name TEXT,
        phone TEXT NOT NULL,
        whatsapp_number TEXT,
        email TEXT,
        address TEXT,
        tin_number TEXT,
        credit_limit REAL DEFAULT 0,
        current_balance REAL DEFAULT 0,
        due_date INTEGER,
        last_transaction_date INTEGER,
        allow_credit INTEGER DEFAULT 0,
        payment_terms TEXT,
        notes TEXT,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS credit_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_id TEXT UNIQUE NOT NULL,
        customer_id INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        balance_before REAL NOT NULL,
        balance_after REAL NOT NULL,
        reference TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');
  }

// Add to lib/src/data/local/database.dart
  static Future<void> debugUsersTable() async {
    final db = await database;

    try {
      final users = await db.query('users');
      print('👥 Total users in database: ${users.length}');

      for (var user in users) {
        print(
            '📄 User: ${user['user_id']} - ${user['name']} - ${user['phone']} - ${user['role']} - Active: ${user['is_active']}');
      }

      // Check specifically for our test user
      final testUser = await db
          .query('users', where: 'phone = ?', whereArgs: ['+251911223344']);
      print('🔍 Test user query result: ${testUser.length} users found');
    } catch (e) {
      print('❌ Error debugging users table: $e');
    }
  }

// Add to lib/src/data/local/database.dart
  static Future<void> verifyOTPTable() async {
    final db = await database;

    try {
      // Check if table exists
      final tableInfo = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='otps'");

      if (tableInfo.isEmpty) {
        print('❌ OTP table does not exist after migration!');
        return;
      }

      print('✅ OTP table exists');

      // Check schema
      final schema = await db.rawQuery("PRAGMA table_info(otps)");
      final expectedColumns = [
        'id',
        'otp_id',
        'phone',
        'code',
        'type',
        'is_used',
        'expires_at',
        'created_at'
      ];
      final actualColumns = schema.map((col) => col['name'] as String).toList();

      print('📋 OTP Table columns: $actualColumns');

      // Test insert and query
      final testOTP = OTP.create(phone: '+251911223344', type: 'test');
      await db.insert('otps', testOTP.toMap());

      final retrieved = await db.query(
        'otps',
        where: 'phone = ? AND code = ?',
        whereArgs: [testOTP.phone, testOTP.code],
      );

      if (retrieved.isNotEmpty) {
        print('✅ OTP table working correctly - can insert and query');
      } else {
        print('❌ OTP table not working - cannot retrieve inserted data');
      }

      // Clean up test data
      await db.delete('otps', where: 'phone = ?', whereArgs: [testOTP.phone]);
    } catch (e) {
      print('❌ Error verifying OTP table: $e');
    }
  }

  // Helper methods
  static Future<bool> tableExists(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  static Future<void> migrateDatabase() async {
    final db = await database;
    // Check and create missing tables
    final userTableExists = await tableExists('users');
    final otpTableExists = await tableExists('otps');
    final subscriptionTableExists = await tableExists('subscriptions');

    if (!userTableExists || !otpTableExists || !subscriptionTableExists) {
      print('Creating missing user management tables...');
      await _createUserManagementTables(db);
    }

    print('Database migration completed');
  }

  static Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await deleteDatabase(path);
    print('Database reset complete');
    _database = await _initDatabase();
  }

  static Future<void> migrateSalesTable() async {
    final db = await database;

    try {
      // Check if final_amount column exists
      final tableInfo = await db.rawQuery("PRAGMA table_info(sales)");
      final hasFinalAmount =
          tableInfo.any((col) => col['name'] == 'final_amount');

      if (!hasFinalAmount) {
        print('Migrating sales table to add final_amount column...');

        // Create backup
        await db.execute(
            'CREATE TABLE IF NOT EXISTS sales_backup AS SELECT * FROM sales');

        // Drop and recreate table with new schema
        await db.execute('DROP TABLE IF EXISTS sales_old');
        await db.execute('ALTER TABLE sales RENAME TO sales_old');

        await _createSalesTables(db);

        // Copy data with final_amount = total_amount for existing records
        await db.execute('''
        INSERT INTO sales 
        SELECT id, sale_id, customer_id, total_amount, total_amount as final_amount, 
               tax_amount, discount_amount, payment_method, payment_status, sale_status,
               user_id, shop_id, is_synced, sync_attempts, created_at, updated_at
        FROM sales_old
      ''');

        await db.execute('DROP TABLE sales_old');
        print('Sales table migration completed successfully');
      }
    } catch (e) {
      print('Sales table migration error: $e');
      // Try to restore from backup if migration fails
      try {
        await db.execute('DROP TABLE IF EXISTS sales');
        await db.execute('ALTER TABLE sales_backup RENAME TO sales');
      } catch (restoreError) {
        print('Restore from backup failed: $restoreError');
      }
    }
  }
}
