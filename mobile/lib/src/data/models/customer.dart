// src/data/models/customer.dart
class Customer {
  final int? id;
  final String localId;
  final String name;
  final String? businessName;
  final String phone;
  final String? whatsappNumber;
  final String? email;
  final String? address;
  final String? tinNumber;
  final double creditLimit;
  final double currentBalance;
  final DateTime? dueDate;
  final DateTime? lastTransactionDate;
  final bool allowCredit;
  final String? paymentTerms;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    this.id,
    required this.localId,
    required this.name,
    this.businessName,
    required this.phone,
    this.whatsappNumber,
    this.email,
    this.address,
    this.tinNumber,
    this.creditLimit = 0,
    this.currentBalance = 0,
    this.dueDate,
    this.lastTransactionDate,
    this.allowCredit = false,
    this.paymentTerms,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'local_id': localId,
      'name': name,
      'business_name': businessName,
      'phone': phone,
      'whatsapp_number': whatsappNumber,
      'email': email,
      'address': address,
      'tin_number': tinNumber,
      'credit_limit': creditLimit,
      'current_balance': currentBalance,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'last_transaction_date': lastTransactionDate?.millisecondsSinceEpoch,
      'allow_credit': allowCredit ? 1 : 0,
      'payment_terms': paymentTerms,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      localId: map['local_id'],
      name: map['name'],
      businessName: map['business_name'],
      phone: map['phone'],
      whatsappNumber: map['whatsapp_number'],
      email: map['email'],
      address: map['address'],
      tinNumber: map['tin_number'],
      creditLimit: map['credit_limit'] ?? 0,
      currentBalance: map['current_balance'] ?? 0,
      dueDate: map['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'])
          : null,
      lastTransactionDate: map['last_transaction_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_transaction_date'])
          : null,
      allowCredit: map['allow_credit'] == 1,
      paymentTerms: map['payment_terms'],
      notes: map['notes'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  // Helper methods
  bool get hasCredit => allowCredit && creditLimit > 0;

  double get overdueAmount {
    if (currentBalance <= 0) return 0;
    if (dueDate == null) return 0;
    if (DateTime.now().isAfter(dueDate!)) {
      return currentBalance;
    }
    return 0;
  }

  bool get isOverdue => overdueAmount > 0;

  double get availableCredit => hasCredit ? creditLimit - currentBalance : 0;

  bool get canMakeCreditSale => availableCredit > 0;

  String get balanceStatus {
    if (currentBalance == 0) return 'Paid';
    if (isOverdue) return 'Overdue: ETB ${currentBalance.toStringAsFixed(2)}';
    if (currentBalance > 0)
      return 'Owes: ETB ${currentBalance.toStringAsFixed(2)}';
    return 'Credit: ETB ${(-currentBalance).toStringAsFixed(2)}';
  }

  String get formattedBalance {
    if (currentBalance >= 0) {
      return 'ETB ${currentBalance.toStringAsFixed(2)}';
    } else {
      return 'ETB ${(-currentBalance).toStringAsFixed(2)}';
    }
  }

  Customer copyWith({
    int? id,
    String? localId,
    String? name,
    String? businessName,
    String? phone,
    String? whatsappNumber,
    String? email,
    String? address,
    String? tinNumber,
    double? creditLimit,
    double? currentBalance,
    DateTime? dueDate,
    DateTime? lastTransactionDate,
    bool? allowCredit,
    String? paymentTerms,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      tinNumber: tinNumber ?? this.tinNumber,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      dueDate: dueDate ?? this.dueDate,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      allowCredit: allowCredit ?? this.allowCredit,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
