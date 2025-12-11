// mobile/lib/src/data/models/sale_item.dart
// Model representing an item in a sale transaction.
class SaleItem {
  final int? id;
  final String saleId;
  final String productId;
  final String productName;
  final String? productNameAm;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double? costPrice;
  final double discount;
  final String? barcode;
  final String? unit;
  final DateTime createdAt;
  final bool isSynced;

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    this.productNameAm,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.costPrice,
    this.discount = 0,
    this.barcode,
    this.unit,
    required this.createdAt,
    this.isSynced = false,
  })  : assert(quantity > 0, 'Quantity must be positive: $quantity'),
        assert(unitPrice >= 0, 'Unit price cannot be negative: $unitPrice'),
        assert(totalPrice >= 0, 'Total price cannot be negative: $totalPrice');

  SaleItem copyWith({
    int? id,
    String? saleId,
    String? productId,
    String? productName,
    String? productNameAm,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    double? costPrice,
    double? discount,
    String? barcode,
    String? unit,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productNameAm: productNameAm ?? this.productNameAm,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      costPrice: costPrice ?? this.costPrice,
      discount: discount ?? this.discount,
      barcode: barcode ?? this.barcode,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  factory SaleItem.create({
    required String saleId,
    required String productId,
    required String productName,
    String? productNameAm,
    required int quantity,
    required double unitPrice,
    double? costPrice,
    double discount = 0,
    String? barcode,
    String? unit,
  }) {
    final totalPrice = (unitPrice * quantity) - discount;

    return SaleItem(
      saleId: saleId,
      productId: productId,
      productName: productName,
      productNameAm: productNameAm,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      costPrice: costPrice,
      discount: discount,
      barcode: barcode,
      unit: unit,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'product_name_am': productNameAm,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'cost_price': costPrice,
      'discount': discount,
      'barcode': barcode,
      'unit': unit,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      productNameAm: map['product_name_am'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'],
      totalPrice: map['total_price'],
      costPrice: map['cost_price'],
      discount: map['discount'] ?? 0,
      barcode: map['barcode'],
      unit: map['unit'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isSynced: map['is_synced'] == 1,
    );
  }

  double get profit {
    if (costPrice == null) return 0;
    return totalPrice - (costPrice! * quantity);
  }

  String get formattedUnitPrice => 'ETB ${unitPrice.toStringAsFixed(2)}';
  String get formattedTotal => 'ETB ${totalPrice.toStringAsFixed(2)}';
}
