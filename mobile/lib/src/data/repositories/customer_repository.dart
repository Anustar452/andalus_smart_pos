// src/data/repositories/customer_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local/database.dart';
import '../models/customer.dart';
import '../models/credit_transaction.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

class CustomerRepository {
  static const String customerTable = 'customers';
  static const String creditTransactionTable = 'credit_transactions';

  Future<Database> get _db async => await AppDatabase.database;

  // Credit Control Methods

  Future<CreditSaleResult> createCreditSale({
    required int customerId,
    required double amount,
    required String saleReference,
    int dueDays = 30,
    String? notes,
  }) async {
    final db = await _db;

    return await db.transaction((txn) async {
      // Get customer with lock to prevent race conditions
      final customerMaps = await txn.query(
        customerTable,
        where: 'id = ?',
        whereArgs: [customerId],
      );

      if (customerMaps.isEmpty) {
        return CreditSaleResult(
          success: false,
          error: 'Customer not found',
        );
      }

      final customer = Customer.fromMap(customerMaps.first);

      // Check if customer allows credit
      if (!customer.allowCredit) {
        return CreditSaleResult(
          success: false,
          error: 'Customer does not allow credit purchases',
        );
      }

      // Check credit limit
      if (customer.currentBalance + amount > customer.creditLimit) {
        return CreditSaleResult(
          success: false,
          error:
              'Credit limit exceeded. Available: ETB ${customer.availableCredit.toStringAsFixed(2)}',
        );
      }

      // Calculate due date based on customer's payment terms or default
      final dueDate = _calculateDueDate(customer, dueDays);

      // Update customer balance and due date
      final newBalance = customer.currentBalance + amount;
      await txn.update(
        customerTable,
        {
          'current_balance': newBalance,
          'due_date': dueDate?.millisecondsSinceEpoch,
          'last_transaction_date': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [customerId],
      );

      // Create credit transaction
      final transaction = CreditTransaction(
        localId: 'sale_${DateTime.now().millisecondsSinceEpoch}',
        customerId: customerId,
        customerName: customer.name,
        type: 'sale',
        amount: amount,
        balanceBefore: customer.currentBalance,
        balanceAfter: newBalance,
        reference: saleReference,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await txn.insert(
        creditTransactionTable,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return CreditSaleResult(
        success: true,
        newBalance: newBalance,
        availableCredit: customer.creditLimit - newBalance,
      );
    });
  }

// Helper method to calculate due date based on payment terms
  DateTime? _calculateDueDate(Customer customer, int defaultDueDays) {
    if (customer.paymentTerms == 'none' || !customer.allowCredit) {
      return null;
    }

    int dueDays = defaultDueDays;

    if (customer.paymentTerms != null && customer.paymentTerms != 'custom') {
      dueDays = int.tryParse(customer.paymentTerms!) ?? defaultDueDays;
    }

    return DateTime.now().add(Duration(days: dueDays));
  }

// Add method to get customers with enhanced search
  Future<List<Customer>> searchCustomers(String query) async {
    final db = await _db;
    final maps = await db.query(
      customerTable,
      where: '''
      (name LIKE ? OR 
       business_name LIKE ? OR 
       phone LIKE ? OR 
       whatsapp_number LIKE ? OR 
       email LIKE ? OR 
       tin_number LIKE ?) 
      AND is_active = 1
    ''',
      whereArgs: [
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%'
      ],
      orderBy: 'name',
    );
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  /// Records a payment against customer's balance
  Future<PaymentResult> recordPayment({
    required int customerId,
    required double amount,
    required String paymentReference,
    String? notes,
  }) async {
    final db = await _db;

    return await db.transaction((txn) async {
      // Get customer
      final customerMaps = await txn.query(
        customerTable,
        where: 'id = ?',
        whereArgs: [customerId],
      );

      if (customerMaps.isEmpty) {
        return PaymentResult(
          success: false,
          error: 'Customer not found',
        );
      }

      final customer = Customer.fromMap(customerMaps.first);

      if (amount <= 0) {
        return PaymentResult(
          success: false,
          error: 'Payment amount must be greater than zero',
        );
      }

      if (amount > customer.currentBalance) {
        return PaymentResult(
          success: false,
          error: 'Payment amount cannot exceed current balance',
        );
      }

      // Update customer balance
      final newBalance = customer.currentBalance - amount;
      await txn.update(
        customerTable,
        {
          'current_balance': newBalance,
          'last_transaction_date': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [customerId],
      );

      // Create payment transaction
      final transaction = CreditTransaction(
        localId: 'payment_${DateTime.now().millisecondsSinceEpoch}',
        customerId: customerId,
        customerName: customer.name,
        type: 'payment',
        amount: amount,
        balanceBefore: customer.currentBalance,
        balanceAfter: newBalance,
        reference: paymentReference,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await txn.insert(
        creditTransactionTable,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return PaymentResult(
        success: true,
        newBalance: newBalance,
        amountPaid: amount,
      );
    });
  }

  /// Updates customer's credit limit
  Future<CreditLimitResult> updateCreditLimit({
    required int customerId,
    required double newCreditLimit,
  }) async {
    final db = await _db;

    return await db.transaction((txn) async {
      // Get customer
      final customerMaps = await txn.query(
        customerTable,
        where: 'id = ?',
        whereArgs: [customerId],
      );

      if (customerMaps.isEmpty) {
        return CreditLimitResult(
          success: false,
          error: 'Customer not found',
        );
      }

      final customer = Customer.fromMap(customerMaps.first);

      // Validate new credit limit
      if (newCreditLimit < customer.currentBalance) {
        return CreditLimitResult(
          success: false,
          error:
              'New credit limit cannot be less than current balance (ETB ${customer.currentBalance.toStringAsFixed(2)})',
        );
      }

      // Update credit limit
      await txn.update(
        customerTable,
        {
          'credit_limit': newCreditLimit,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [customerId],
      );

      // Create adjustment transaction
      final transaction = CreditTransaction(
        localId: 'adjustment_${DateTime.now().millisecondsSinceEpoch}',
        customerId: customerId,
        customerName: customer.name,
        type: 'adjustment',
        amount: newCreditLimit - customer.creditLimit,
        balanceBefore: customer.currentBalance,
        balanceAfter: customer.currentBalance,
        reference: 'Credit Limit Adjustment',
        notes:
            'Credit limit changed from ETB ${customer.creditLimit.toStringAsFixed(2)} to ETB ${newCreditLimit.toStringAsFixed(2)}',
        createdAt: DateTime.now(),
      );

      await txn.insert(
        creditTransactionTable,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return CreditLimitResult(
        success: true,
        oldCreditLimit: customer.creditLimit,
        newCreditLimit: newCreditLimit,
      );
    });
  }

  // Existing methods with enhancements
  Future<int> createCustomer(Customer customer) async {
    final db = await _db;
    return await db.insert(
      customerTable,
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCustomer(Customer customer) async {
    final db = await _db;
    await db.update(
      customerTable,
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<void> createSampleCustomers() async {
    final db = await _db;
    final sampleCustomers = [
      Customer(
        name: 'John Doe',
        businessName: 'Doe Enterprises',
        phone: '0912345678',
        email: 'john.doe@example.com',
        localId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Customer(
        name: 'Jane Smith',
        businessName: 'Smith LLC',
        phone: '0987654321',
        email: 'jane.smith@example.com',
        localId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var customer in sampleCustomers) {
      await db.insert(
        customerTable,
        customer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Customer>> getAllCustomers({bool activeOnly = true}) async {
    final db = await _db;
    final where = activeOnly ? 'WHERE is_active = 1' : '';
    final maps = await db.rawQuery('''
      SELECT * FROM $customerTable $where ORDER BY name
    ''');
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await _db;
    final maps = await db.query(
      customerTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Customer>> getCustomersWithBalance() async {
    final db = await _db;
    final maps = await db.query(
      customerTable,
      where: 'current_balance != 0 AND is_active = 1',
      orderBy: 'current_balance DESC',
    );
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<List<Customer>> getOverdueCustomers() async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      // First check if due_date column exists
      final tableInfo = await db.rawQuery("PRAGMA table_info(customers)");
      final hasDueDate = tableInfo.any((col) => col['name'] == 'due_date');

      if (!hasDueDate) {
        print('due_date column does not exist, returning empty list');
        return [];
      }

      final maps = await db.rawQuery('''
      SELECT * FROM customers 
      WHERE current_balance > 0 
        AND due_date IS NOT NULL 
        AND due_date < ?
        AND is_active = 1
      ORDER BY current_balance DESC
    ''', [now]);

      return maps.map((map) => Customer.fromMap(map)).toList();
    } catch (e) {
      print('Error in getOverdueCustomers: $e');
      // If there's an error (like missing column), return empty list
      return [];
    }
  }

  Future<List<CreditTransaction>> getCustomerTransactions(int customerId,
      {int limit = 50}) async {
    final db = await _db;
    final maps = await db.query(
      creditTransactionTable,
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => CreditTransaction.fromMap(map)).toList();
  }

// Add this method to your CustomerRepository class
  Future<void> addCreditTransaction(CreditTransaction transaction) async {
    final db = await _db;

    await db.transaction((txn) async {
      // Insert transaction
      await txn.insert(
        creditTransactionTable,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Update customer balance
      await txn.update(
        customerTable,
        {
          'current_balance': transaction.balanceAfter,
          'last_transaction_date': transaction.createdAt.millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [transaction.customerId],
      );
    });
  }

  // Statistics
  Future<Map<String, dynamic>> getCreditSummary() async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;

    final totalResult = await db.rawQuery('''
      SELECT COUNT(*) as count, COALESCE(SUM(current_balance), 0) as total 
      FROM $customerTable WHERE is_active = 1
    ''');

    final overdueResult = await db.rawQuery('''
      SELECT COUNT(*) as count, COALESCE(SUM(current_balance), 0) as total 
      FROM $customerTable 
      WHERE current_balance > 0 
        AND due_date IS NOT NULL 
        AND due_date < ?
        AND is_active = 1
    ''', [now]);

    final customersWithBalance = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $customerTable 
      WHERE current_balance != 0 AND is_active = 1
    ''');

    return {
      'totalCustomers': (totalResult.first['count'] as num?)?.toInt() ?? 0,
      'totalOutstanding': (totalResult.first['total'] as num?)?.toDouble() ?? 0,
      'overdueCustomers': (overdueResult.first['count'] as num?)?.toInt() ?? 0,
      'overdueAmount': (overdueResult.first['total'] as num?)?.toDouble() ?? 0,
      'customersWithBalance':
          (customersWithBalance.first['count'] as num?)?.toInt() ?? 0,
    };
  }
}

// Result classes for credit operations
class CreditSaleResult {
  final bool success;
  final String? error;
  final double? newBalance;
  final double? availableCredit;

  CreditSaleResult({
    required this.success,
    this.error,
    this.newBalance,
    this.availableCredit,
  });
}

class PaymentResult {
  final bool success;
  final String? error;
  final double? newBalance;
  final double? amountPaid;

  PaymentResult({
    required this.success,
    this.error,
    this.newBalance,
    this.amountPaid,
  });
}

class CreditLimitResult {
  final bool success;
  final String? error;
  final double? oldCreditLimit;
  final double? newCreditLimit;

  CreditLimitResult({
    required this.success,
    this.error,
    this.oldCreditLimit,
    this.newCreditLimit,
  });
}
