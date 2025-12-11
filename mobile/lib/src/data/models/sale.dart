// mobile/lib/src/data/models/sale.dart
import 'dart:convert';
import 'package:andalus_smart_pos/src/data/models/sale_item.dart';
import 'package:crypto/crypto.dart';

class Sale {
  final int? id;
  final String saleId;
  final String localId;
  final int? customerId;
  final String? customerName;
  final double totalAmount;
  final double finalAmount;
  final double taxAmount;
  final double discountAmount;
  final String paymentMethod;
  final String paymentReference;
  final String paymentStatus;
  final String saleStatus;
  final int userId;
  final String? userName;
  final int shopId;
  final bool isSynced;
  final int syncAttempts;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;
  late final String checksum;
  final String? notes;
  final bool isRefunded;
  final String? refundReason;
  final DateTime? refundedAt;

  Sale({
    this.id,
    required this.saleId,
    required this.localId,
    this.customerId,
    this.customerName,
    required this.totalAmount,
    required this.finalAmount,
    this.taxAmount = 0,
    this.discountAmount = 0,
    required this.paymentMethod,
    this.paymentReference = '',
    this.paymentStatus = 'completed',
    this.saleStatus = 'completed',
    required this.userId,
    this.userName,
    required this.shopId,
    this.isSynced = false,
    this.syncAttempts = 0,
    required this.createdAt,
    this.updatedAt,
    this.syncedAt,
    this.checksum = '',
    this.notes,
    this.isRefunded = false,
    this.refundReason,
    this.refundedAt,
  })  : assert(totalAmount >= 0, 'Total amount cannot be negative'),
        assert(finalAmount >= 0, 'Final amount cannot be negative'),
        assert(taxAmount >= 0, 'Tax amount cannot be negative'),
        assert(discountAmount >= 0, 'Discount amount cannot be negative'),
        assert(paymentMethod.isNotEmpty, 'Payment method required'),
        assert(userId > 0, 'User ID must be positive'),
        assert(shopId > 0, 'Shop ID must be positive') {
    // Generate checksum if not provided
    if (checksum.isEmpty) {
      checksum = _generateChecksum();
    }
  }

  String _generateChecksum() {
    final data =
        '$saleId$totalAmount$finalAmount$paymentMethod$userId$shopId${createdAt.millisecondsSinceEpoch}';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool verifyChecksum() {
    return checksum == _generateChecksum();
  }

  // === BUSINESS VALIDATION ===
  bool isValid() {
    return saleId.isNotEmpty &&
        localId.isNotEmpty &&
        totalAmount >= 0 &&
        finalAmount >= 0 &&
        paymentMethod.isNotEmpty &&
        userId > 0 &&
        shopId > 0 &&
        verifyChecksum();
  }

  bool get isTotalValid {
    // Allow small rounding differences (0.01)
    final calculated = totalAmount + taxAmount - discountAmount;
    return (finalAmount - calculated).abs() < 0.01;
  }

  bool get canBeRefunded {
    return !isRefunded &&
        saleStatus == 'completed' &&
        paymentStatus == 'completed' &&
        createdAt.isAfter(DateTime.now()
            .subtract(const Duration(days: 30))); // 30-day refund window
  }

  // === FACTORY METHODS ===
  factory Sale.createNew({
    required List<SaleItem> items,
    required int userId,
    required String userName,
    required int shopId,
    String paymentMethod = 'cash',
    String? paymentReference,
    int? customerId,
    String? customerName,
    double taxRate = 0.15,
    double discountAmount = 0,
    String? notes,
  }) {
    // Calculate amounts
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final taxAmount = subtotal * taxRate;
    final totalAmount = subtotal + taxAmount;
    final finalAmount = totalAmount - discountAmount;

    // Validate amounts
    if (finalAmount < 0) {
      throw ArgumentError('Final amount cannot be negative after discount');
    }

    final now = DateTime.now();
    final saleId =
        'SALE_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.millisecondsSinceEpoch}';

    return Sale(
      saleId: saleId,
      localId: 'LOCAL_${now.millisecondsSinceEpoch}',
      customerId: customerId,
      customerName: customerName,
      totalAmount: double.parse(totalAmount.toStringAsFixed(2)),
      finalAmount: double.parse(finalAmount.toStringAsFixed(2)),
      taxAmount: double.parse(taxAmount.toStringAsFixed(2)),
      discountAmount: double.parse(discountAmount.toStringAsFixed(2)),
      paymentMethod: paymentMethod,
      paymentReference: paymentReference ?? '',
      userId: userId,
      userName: userName,
      shopId: shopId,
      createdAt: now,
      updatedAt: now,
      notes: notes,
    );
  }

  Sale markAsSynced() {
    return copyWith(
      isSynced: true,
      syncedAt: DateTime.now(),
    );
  }

  Sale markAsRefunded(String reason) {
    return copyWith(
      isRefunded: true,
      refundReason: reason,
      refundedAt: DateTime.now(),
      saleStatus: 'refunded',
    );
  }

  // === COPY WITH ===
  Sale copyWith({
    int? id,
    String? saleId,
    String? localId,
    int? customerId,
    String? customerName,
    double? totalAmount,
    double? finalAmount,
    double? taxAmount,
    double? discountAmount,
    String? paymentMethod,
    String? paymentReference,
    String? paymentStatus,
    String? saleStatus,
    int? userId,
    String? userName,
    int? shopId,
    bool? isSynced,
    int? syncAttempts,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    String? checksum,
    String? notes,
    bool? isRefunded,
    String? refundReason,
    DateTime? refundedAt,
  }) {
    return Sale(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      localId: localId ?? this.localId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      saleStatus: saleStatus ?? this.saleStatus,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      shopId: shopId ?? this.shopId,
      isSynced: isSynced ?? this.isSynced,
      syncAttempts: syncAttempts ?? this.syncAttempts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncedAt: syncedAt ?? this.syncedAt,
      checksum: checksum ?? this.checksum,
      notes: notes ?? this.notes,
      isRefunded: isRefunded ?? this.isRefunded,
      refundReason: refundReason ?? this.refundReason,
      refundedAt: refundedAt ?? this.refundedAt,
    );
  }

  // === TO/FROM MAP ===
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'local_id': localId,
      'customer_id': customerId,
      'customer_name': customerName,
      'total_amount': totalAmount,
      'final_amount': finalAmount,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'payment_status': paymentStatus,
      'sale_status': saleStatus,
      'user_id': userId,
      'user_name': userName,
      'shop_id': shopId,
      'is_synced': isSynced ? 1 : 0,
      'sync_attempts': syncAttempts,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'synced_at': syncedAt?.millisecondsSinceEpoch,
      'checksum': checksum,
      'notes': notes,
      'is_refunded': isRefunded ? 1 : 0,
      'refund_reason': refundReason,
      'refunded_at': refundedAt?.millisecondsSinceEpoch,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      saleId: map['sale_id'],
      localId: map['local_id'] ?? '',
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      totalAmount: map['total_amount'],
      finalAmount: map['final_amount'] ?? map['total_amount'],
      taxAmount: map['tax_amount'] ?? 0,
      discountAmount: map['discount_amount'] ?? 0,
      paymentMethod: map['payment_method'],
      paymentReference: map['payment_reference'] ?? '',
      paymentStatus: map['payment_status'] ?? 'completed',
      saleStatus: map['sale_status'] ?? 'completed',
      userId: map['user_id'],
      userName: map['user_name'],
      shopId: map['shop_id'],
      isSynced: map['is_synced'] == 1,
      syncAttempts: map['sync_attempts'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
      syncedAt: map['synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['synced_at'])
          : null,
      checksum: map['checksum'] ?? '',
      notes: map['notes'],
      isRefunded: map['is_refunded'] == 1,
      refundReason: map['refund_reason'],
      refundedAt: map['refunded_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['refunded_at'])
          : null,
    );
  }

  // === HELPER METHODS ===
  String get formattedTotal => 'ETB ${finalAmount.toStringAsFixed(2)}';
  String get formattedDate =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get formattedTime =>
      '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  String get formattedDateTime => '$formattedDate $formattedTime';

  double get subtotal => totalAmount - taxAmount + discountAmount;

  @override
  String toString() {
    return 'Sale(id: $id, saleId: $saleId, total: $formattedTotal, status: $saleStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sale && other.saleId == saleId;
  }

  @override
  int get hashCode => saleId.hashCode;
}
