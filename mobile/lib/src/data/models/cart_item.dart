// mobile/lib/src/data/models/cart_item.dart
// Model representing an item in the shopping cart.
class CartItem {
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get totalPrice => unitPrice * quantity;

  String get formattedUnitPrice => 'ETB ${unitPrice.toStringAsFixed(2)}';
  String get formattedTotalPrice => 'ETB ${totalPrice.toStringAsFixed(2)}';

  CartItem copyWith({
    int? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}
