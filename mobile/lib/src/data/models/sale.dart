class Sale {
  final int? id;
  final String saleId;
  final int? customerId;
  final double totalAmount;
  final double finalAmount;
  final double taxAmount;
  final double discountAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String saleStatus;
  final int userId;
  final int shopId;
  final bool isSynced;
  final int syncAttempts;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Sale({
    this.id,
    required this.saleId,
    this.customerId,
    required this.totalAmount,
    required this.finalAmount,
    this.taxAmount = 0,
    this.discountAmount = 0,
    required this.paymentMethod,
    this.paymentStatus = 'completed',
    this.saleStatus = 'completed',
    required this.userId,
    required this.shopId,
    this.isSynced = false,
    this.syncAttempts = 0,
    required this.createdAt,
    this.updatedAt,
    required String localId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'customer_id': customerId,
      'total_amount': totalAmount,
      'final_amount': finalAmount,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'sale_status': saleStatus,
      'user_id': userId,
      'shop_id': shopId,
      'is_synced': isSynced ? 1 : 0,
      'sync_attempts': syncAttempts,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      saleId: map['sale_id'],
      customerId: map['customer_id'],
      totalAmount: map['total_amount'],
      finalAmount: map['final_amount'] ?? map['total_amount'], // Fallback
      taxAmount: map['tax_amount'] ?? 0,
      discountAmount: map['discount_amount'] ?? 0,
      paymentMethod: map['payment_method'],
      paymentStatus: map['payment_status'] ?? 'completed',
      saleStatus: map['sale_status'] ?? 'completed',
      userId: map['user_id'],
      shopId: map['shop_id'],
      isSynced: map['is_synced'] == 1,
      syncAttempts: map['sync_attempts'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
      localId: '',
    );
  }

  String get formattedTotal => 'ETB ${finalAmount.toStringAsFixed(2)}';
  String get formattedDate =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get formattedTime =>
      '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

  // Helper method to create sample data
  static Sale createSample() {
    final now = DateTime.now();
    return Sale(
      saleId: 'SALE-${now.millisecondsSinceEpoch}',
      totalAmount: 150.0,
      finalAmount: 150.0,
      paymentMethod: 'cash',
      userId: 1,
      shopId: 1,
      createdAt: now,
      localId: '',
    );
  }
}
