import 'dart:ui';

import 'package:flutter/material.dart';

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

  Product({
    this.id,
    required this.productId,
    required this.name,
    required this.nameAm,
    this.description,
    required this.price,
    this.costPrice,
    required this.stockQuantity,
    this.minStockLevel,
    required this.barcode,
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
  });

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
    );
  }

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
    );
  }

  // Helper methods
  String get formattedPrice => 'ETB ${price.toStringAsFixed(2)}';
  String get formattedCostPrice =>
      costPrice != null ? 'ETB ${costPrice!.toStringAsFixed(2)}' : 'N/A';

  bool get isLowStock =>
      trackInventory &&
      minStockLevel != null &&
      stockQuantity <= minStockLevel!;
  bool get isOutOfStock => trackInventory && stockQuantity <= 0;

  double get profitMargin {
    if (costPrice == null || costPrice == 0) return 0;
    return ((price - costPrice!) / costPrice!) * 100;
  }

  String get stockStatus {
    if (!trackInventory) return 'Not Tracked';
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  Color get stockStatusColor {
    if (!trackInventory) return Colors.grey;
    if (isOutOfStock) return Colors.red;
    if (isLowStock) return Colors.orange;
    return Colors.green;
  }

  factory Product.createSample() {
    return Product(
      productId: 'prod_sample_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Sample Product',
      nameAm: 'ናሙና ምርት',
      description: 'This is a sample product for testing',
      price: 99.99,
      costPrice: 50.00,
      stockQuantity: 25,
      minStockLevel: 10,
      barcode: '1234567890123',
      sku: 'SKU-001',
      categoryId: 'cat_001',
      unit: 'pcs',
      brand: 'Sample Brand',
      supplier: 'Sample Supplier',
      trackInventory: true,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory Product.createSampleWithIndex(int index) {
    final products = [
      {'name': 'Coca Cola', 'nameAm': 'ኮካ ኮላ', 'price': 25.0, 'stock': 50},
      {'name': 'Mirinda', 'nameAm': 'ሚሪንዳ', 'price': 25.0, 'stock': 30},
      {'name': 'Ambo Water', 'nameAm': 'አምቦ ውሃ', 'price': 15.0, 'stock': 100},
      {'name': 'Biscuit', 'nameAm': 'ብስኩት', 'price': 10.0, 'stock': 75},
      {'name': 'Bread', 'nameAm': 'ዳቦ', 'price': 20.0, 'stock': 25},
    ];

    final productData = products[index % products.length];

    return Product(
      productId: 'prod_sample_${DateTime.now().millisecondsSinceEpoch}_$index',
      name: productData['name'] as String,
      nameAm: productData['nameAm'] as String,
      description: 'Sample product description',
      price: productData['price'] as double,
      costPrice: (productData['price'] as double) * 0.6,
      stockQuantity: productData['stock'] as int,
      minStockLevel: 10,
      barcode: '1234567890${index.toString().padLeft(3, '0')}',
      sku: 'SKU-${index.toString().padLeft(3, '0')}',
      categoryId: 'cat_${(index % 3 + 1).toString().padLeft(3, '0')}',
      unit: 'pcs',
      brand: 'Sample Brand',
      supplier: 'Sample Supplier',
      trackInventory: true,
      isActive: true,
      createdAt: DateTime.now().subtract(Duration(days: index * 2)),
      updatedAt: DateTime.now(),
    );
  }
}
