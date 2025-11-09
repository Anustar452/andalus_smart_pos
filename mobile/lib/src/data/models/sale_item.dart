class SaleItem {
  final int? id;
  final int saleId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime? createdAt;

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.createdAt,
  });

  // Helper to update quantity
  SaleItem copyWith({int? quantity, required int saleId}) {
    final newQuantity = quantity ?? this.quantity;
    return SaleItem(
      id: id,
      saleId: saleId,
      productId: productId,
      productName: productName,
      quantity: newQuantity,
      unitPrice: unitPrice,
      totalPrice: unitPrice * newQuantity,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'created_at': createdAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'],
      totalPrice: map['total_price'],
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          : null,
    );
  }

  String get formattedUnitPrice => 'ETB ${unitPrice.toStringAsFixed(2)}';
  String get formattedTotalPrice => 'ETB ${totalPrice.toStringAsFixed(2)}';
}
