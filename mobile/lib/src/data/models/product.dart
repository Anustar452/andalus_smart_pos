// lib/src/data/models/product.dart
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

class Product {
  final int? id;
  final String productId;
  final String name;
  final String nameAm;
  final String? description;
  final double price;
  final double? costPrice;
  final int stockQuantity;
  final int? minStockLevel;
  final String barcode;
  final String? sku;
  final String categoryId;
  final String? categoryName;
  final String? unit;
  final String? brand;
  final String? supplier;
  final double? weight;
  final String? size;
  final String? color;
  final String? imagePath;
  final bool trackInventory;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  late final String checksum; // For data integrity
  final int version; // For optimistic locking

  Product({
    this.id,
    required this.productId,
    required this.name,
    required this.nameAm,
    this.description,
    required double price,
    this.costPrice,
    required int stockQuantity,
    int? minStockLevel,
    required String barcode,
    this.sku,
    required this.categoryId,
    this.categoryName,
    this.unit,
    this.brand,
    this.supplier,
    this.weight,
    this.size,
    this.color,
    this.imagePath,
    this.trackInventory = true,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.checksum = '',
    this.version = 1,
  })  : price = _validatePrice(price),
        stockQuantity = _validateStock(stockQuantity),
        barcode = _validateBarcode(barcode),
        minStockLevel = _validateMinStock(minStockLevel) {
    // Generate checksum
    checksum = _generateChecksum();
  }

  // === VALIDATION METHODS ===
  static double _validatePrice(double price) {
    if (price < 0) throw ArgumentError('Price cannot be negative: $price');
    if (price > 10000000) {
      throw ArgumentError('Price exceeds maximum allowed: $price');
    }
    return double.parse(price.toStringAsFixed(2)); // Round to 2 decimals
  }

  static int _validateStock(int stock) {
    if (stock < 0) throw ArgumentError('Stock cannot be negative: $stock');
    if (stock > 1000000)
      throw ArgumentError('Stock exceeds maximum allowed: $stock');
    return stock;
  }

  static String _validateBarcode(String barcode) {
    if (barcode.isEmpty) throw ArgumentError('Barcode cannot be empty');
    barcode = barcode.trim();

    // Validate common barcode formats
    final validFormats = [
      RegExp(r'^[0-9]{12,13}$'), // EAN-13, UPC-A
      RegExp(r'^[0-9]{8}$'), // EAN-8
      RegExp(r'^[0-9]{14}$'), // GTIN-14
    ];

    final isValid = validFormats.any((regex) => regex.hasMatch(barcode));
    if (!isValid) {
      throw ArgumentError('Invalid barcode format: $barcode');
    }

    return barcode;
  }

  static int? _validateMinStock(int? minStock) {
    if (minStock != null) {
      if (minStock < 0)
        throw ArgumentError('Minimum stock cannot be negative: $minStock');
      if (minStock > 1000000)
        throw ArgumentError('Minimum stock exceeds maximum: $minStock');
    }
    return minStock;
  }

  String _generateChecksum() {
    final data =
        '$productId$name$nameAm$price$stockQuantity$barcode$categoryId';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool verifyChecksum() {
    return checksum == _generateChecksum();
  }

  // === BUSINESS METHODS ===
  bool canSellQuantity(int quantity) {
    if (!trackInventory) return true;
    if (quantity <= 0) return false;
    if (quantity > stockQuantity) return false;
    if (!isActive) return false;
    return true;
  }

  Product reduceStock(int quantity) {
    if (!canSellQuantity(quantity)) {
      throw StateError(
          'Cannot sell $quantity of $name. Available: $stockQuantity');
    }

    return copyWith(
      stockQuantity: stockQuantity - quantity,
      version: version + 1,
    );
  }

  Product increaseStock(int quantity) {
    if (quantity <= 0)
      throw ArgumentError('Quantity must be positive: $quantity');

    return copyWith(
      stockQuantity: stockQuantity + quantity,
      version: version + 1,
    );
  }

  double getPriceWithTax(double taxRate) {
    return double.parse((price * (1 + taxRate)).toStringAsFixed(2));
  }

  double getProfit() {
    if (costPrice == null) return 0;
    return double.parse((price - costPrice!).toStringAsFixed(2));
  }

  double getProfitPercentage() {
    if (costPrice == null || costPrice == 0) return 0;
    return double.parse(
        (((price - costPrice!) / costPrice!) * 100).toStringAsFixed(2));
  }

  // === COPY WITH METHOD (ENHANCED) ===
  Product copyWith({
    String? name,
    String? nameAm,
    String? description,
    double? price,
    double? costPrice,
    int? stockQuantity,
    int? minStockLevel,
    String? barcode,
    String? sku,
    String? categoryId,
    String? unit,
    String? brand,
    String? supplier,
    double? weight,
    String? size,
    String? color,
    String? imagePath,
    bool? trackInventory,
    bool? isActive,
    int? version,
  }) {
    return Product(
      id: id,
      productId: productId,
      name: name ?? this.name,
      nameAm: nameAm ?? this.nameAm,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      categoryId: categoryId ?? this.categoryId,
      unit: unit ?? this.unit,
      brand: brand ?? this.brand,
      supplier: supplier ?? this.supplier,
      weight: weight ?? this.weight,
      size: size ?? this.size,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      trackInventory: trackInventory ?? this.trackInventory,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      version: version ?? this.version + 1,
    );
  }

  // === TO/FROM MAP ===
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'name_am': nameAm,
      'description': description,
      'price': price,
      'cost_price': costPrice,
      'stock_quantity': stockQuantity,
      'min_stock_level': minStockLevel,
      'barcode': barcode,
      'sku': sku,
      'category_id': categoryId,
      'unit': unit,
      'brand': brand,
      'supplier': supplier,
      'weight': weight,
      'size': size,
      'color': color,
      'image_path': imagePath,
      'track_inventory': trackInventory ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'checksum': checksum,
      'version': version,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      productId: map['product_id'],
      name: map['name'],
      nameAm: map['name_am'],
      description: map['description'],
      price: map['price'],
      costPrice: map['cost_price'],
      stockQuantity: map['stock_quantity'],
      minStockLevel: map['min_stock_level'],
      barcode: map['barcode'],
      sku: map['sku'],
      categoryId: map['category_id'],
      unit: map['unit'],
      brand: map['brand'],
      supplier: map['supplier'],
      weight: map['weight'],
      size: map['size'],
      color: map['color'],
      imagePath: map['image_path'],
      trackInventory: map['track_inventory'] == 1,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      checksum: map['checksum'] ?? '',
      version: map['version'] ?? 1,
    );
  }

  // === HELPER PROPERTIES ===
  String get formattedPrice => 'ETB ${price.toStringAsFixed(2)}';
  String get formattedCostPrice =>
      costPrice != null ? 'ETB ${costPrice!.toStringAsFixed(2)}' : 'N/A';

  bool get isLowStock =>
      trackInventory &&
      minStockLevel != null &&
      stockQuantity <= minStockLevel!;

  bool get isOutOfStock => trackInventory && stockQuantity <= 0;

  String get stockStatus {
    if (!trackInventory) return 'Not Tracked';
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  Color get stockStatusColor {
    if (!trackInventory) return Colors.grey;
    if (isOutOfStock) return const Color(0xFFEF4444);
    if (isLowStock) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  // === FACTORY METHODS ===
  factory Product.create({
    required String name,
    required String nameAm,
    required double price,
    required int stockQuantity,
    required String barcode,
    required String categoryId,
    String? description,
    double? costPrice,
    int? minStockLevel,
    String? unit,
    String? brand,
    String? supplier,
  }) {
    return Product(
      productId: 'PROD_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      nameAm: nameAm,
      description: description,
      price: price,
      costPrice: costPrice,
      stockQuantity: stockQuantity,
      minStockLevel: minStockLevel,
      barcode: barcode,
      categoryId: categoryId,
      unit: unit,
      brand: brand,
      supplier: supplier,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, stock: $stockQuantity, barcode: $barcode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.productId == productId &&
        other.version == version;
  }

  @override
  int get hashCode => productId.hashCode ^ version.hashCode;
}
