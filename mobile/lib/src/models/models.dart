// mobile/lib/src/models/models.dart
class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final int shopId;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.shopId,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      shopId: json['shop_id'],
      isActive: json['is_active'],
    );
  }
}

class Product {
  final int id;
  final String name;
  final String? barcode;
  final String? description;
  final double price;
  final double costPrice;
  final int stockQuantity;
  final int minStock;
  final String? category;
  final String? image;
  final bool isActive;
  final int shopId;

  Product({
    required this.id,
    required this.name,
    this.barcode,
    this.description,
    required this.price,
    required this.costPrice,
    required this.stockQuantity,
    required this.minStock,
    this.category,
    this.image,
    required this.isActive,
    required this.shopId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      barcode: json['barcode'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      costPrice: double.parse(json['cost_price']?.toString() ?? '0'),
      stockQuantity: json['stock_quantity'],
      minStock: json['min_stock'],
      category: json['category'],
      image: json['image'],
      isActive: json['is_active'],
      shopId: json['shop_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'description': description,
      'price': price,
      'cost_price': costPrice,
      'stock_quantity': stockQuantity,
      'min_stock': minStock,
      'category': category,
      'image': image,
      'is_active': isActive,
      'shop_id': shopId,
    };
  }
}

class CartItem {
  final Product product;
  int quantity;
  final double unitPrice;

  CartItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  CartItem copyWith({Product? product, int? quantity, double? unitPrice}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

class Transaction {
  final int id;
  final String transactionNumber;
  final double totalAmount;
  final double taxAmount;
  final double discountAmount;
  final double paidAmount;
  final double changeAmount;
  final String paymentMethod;
  final String? paymentReference;
  final String status;
  final DateTime createdAt;
  final List<TransactionItem> items;
  final User? user;

  Transaction({
    required this.id,
    required this.transactionNumber,
    required this.totalAmount,
    required this.taxAmount,
    required this.discountAmount,
    required this.paidAmount,
    required this.changeAmount,
    required this.paymentMethod,
    this.paymentReference,
    required this.status,
    required this.createdAt,
    required this.items,
    this.user,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      transactionNumber: json['transaction_number'],
      totalAmount: double.parse(json['total_amount'].toString()),
      taxAmount: double.parse(json['tax_amount'].toString()),
      discountAmount: double.parse(json['discount_amount'].toString()),
      paidAmount: double.parse(json['paid_amount'].toString()),
      changeAmount: double.parse(json['change_amount'].toString()),
      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      items: List<TransactionItem>.from(
        json['items'].map((x) => TransactionItem.fromJson(x)),
      ),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class TransactionItem {
  final int id;
  final int productId;
  final Product product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  TransactionItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      productId: json['product_id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
    );
  }
}
