// mobile/lib/src/data/models/category.dart
// Model representing a product category.
// Includes sample categories for different business types.
// later on we can extend this to support hierarchical categories if needed. and supporting different business types with default categories
class ProductCategory {
  final int? id;
  final String categoryId;
  final String name;
  final String nameAm;
  final String? description;
  final String? color;
  final String? icon;
  final int? parentId;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductCategory({
    this.id,
    required this.categoryId,
    required this.name,
    required this.nameAm,
    this.description,
    this.color,
    this.icon,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'name_am': nameAm,
      'description': description,
      'color': color,
      'icon': icon,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    return ProductCategory(
      id: map['id'],
      categoryId: map['category_id'],
      name: map['name'],
      nameAm: map['name_am'],
      description: map['description'],
      color: map['color'],
      icon: map['icon'],
      parentId: map['parent_id'],
      sortOrder: map['sort_order'] ?? 0,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  ProductCategory copyWith({
    String? name,
    String? nameAm,
    String? description,
    String? color,
    String? icon,
    int? parentId,
    int? sortOrder,
    bool? isActive,
  }) {
    return ProductCategory(
      id: id,
      categoryId: categoryId,
      name: name ?? this.name,
      nameAm: nameAm ?? this.nameAm,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get hasParent => parentId != null;
}

// Sample categories for different business types
class DefaultCategories {
  static List<ProductCategory> forBusinessType(String businessType) {
    switch (businessType) {
      case 'retail':
      case 'supermarket':
        return [
          ProductCategory(
            categoryId: 'food_beverages',
            name: 'Food & Beverages',
            nameAm: 'ምግብ እና መጠጥ',
            description: 'Food items and beverages',
            color: '#4CAF50',
            icon: 'local_grocery_store',
            sortOrder: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          ProductCategory(
            categoryId: 'personal_care',
            name: 'Personal Care',
            nameAm: 'የግሌ እንክብካቤ',
            description: 'Personal hygiene and care products',
            color: '#2196F3',
            icon: 'spa',
            sortOrder: 2,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          ProductCategory(
            categoryId: 'household',
            name: 'Household Items',
            nameAm: 'የቤት እቃዎች',
            description: 'Household and cleaning supplies',
            color: '#FF9800',
            icon: 'home',
            sortOrder: 3,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

      case 'restaurant':
        return [
          ProductCategory(
            categoryId: 'main_courses',
            name: 'Main Courses',
            nameAm: 'ዋና ምግቦች',
            description: 'Main dishes and entrees',
            color: '#F44336',
            icon: 'restaurant',
            sortOrder: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          ProductCategory(
            categoryId: 'beverages',
            name: 'Beverages',
            nameAm: 'መጠጦች',
            description: 'Drinks and beverages',
            color: '#4CAF50',
            icon: 'local_cafe',
            sortOrder: 2,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          ProductCategory(
            categoryId: 'desserts',
            name: 'Desserts',
            nameAm: 'ምንጣፎች',
            description: 'Sweets and desserts',
            color: '#9C27B0',
            icon: 'cake',
            sortOrder: 3,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

      case 'pharmacy':
        return [
          ProductCategory(
            categoryId: 'prescription',
            name: 'Prescription Drugs',
            nameAm: 'የዶክተር እዘዝ መድሃኒቶች',
            description: 'Prescription medications',
            color: '#F44336',
            icon: 'medical_services',
            sortOrder: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          ProductCategory(
            categoryId: 'otc',
            name: 'Over-the-Counter',
            nameAm: 'ያለ እዘዝ መድሃኒቶች',
            description: 'Non-prescription medications',
            color: '#2196F3',
            icon: 'local_pharmacy',
            sortOrder: 2,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          ProductCategory(
            categoryId: 'personal_care',
            name: 'Personal Care',
            nameAm: 'የግሌ እንክብካቤ',
            description: 'Health and personal care',
            color: '#4CAF50',
            icon: 'spa',
            sortOrder: 3,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

      default:
        return [
          ProductCategory(
            categoryId: 'general',
            name: 'General',
            nameAm: 'አጠቃላይ',
            description: 'General products',
            color: '#607D8B',
            icon: 'category',
            sortOrder: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
    }
  }
}
