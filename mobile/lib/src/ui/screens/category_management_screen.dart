// src/ui/screens/category_management_screen.dart
// Screen for managing product categories including viewing, searching, adding, editing, and toggling active
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/category.dart';
import 'package:andalus_smart_pos/src/data/repositories/category_repository.dart';
import 'package:andalus_smart_pos/src/widgets/common/custom_card.dart';
import 'package:andalus_smart_pos/src/widgets/common/loading_shimmer.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen> {
  final _searchController = TextEditingController();
  List<ProductCategory> _categories = [];
  List<ProductCategory> _filteredCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categoryRepo = ref.read(categoryRepositoryProvider);
      final categories = await categoryRepo.getAllCategories();
      setState(() {
        _categories = categories;
        _filteredCategories = categories;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading categories: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredCategories = _categories.where((category) {
        return category.name.toLowerCase().contains(_searchQuery) ||
            category.nameAm.toLowerCase().contains(_searchQuery) ||
            (category.description?.toLowerCase().contains(_searchQuery) ??
                false);
      }).toList();
    });
  }

  void _showAddCategoryDialog({ProductCategory? existingCategory}) {
    final isEdit = existingCategory != null;
    final nameController =
        TextEditingController(text: existingCategory?.name ?? '');
    final nameAmController =
        TextEditingController(text: existingCategory?.nameAm ?? '');
    final descriptionController =
        TextEditingController(text: existingCategory?.description ?? '');
    final colorController =
        TextEditingController(text: existingCategory?.color ?? '#4CAF50');
    final iconController =
        TextEditingController(text: existingCategory?.icon ?? 'category');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Category' : 'Add New Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                controller: nameController,
                label: 'Category Name (English) *',
                hintText: 'e.g., Beverages',
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: nameAmController,
                label: 'Category Name (Amharic) *',
                hintText: 'e.g., መጠጦች',
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: descriptionController,
                label: 'Description',
                hintText: 'Category description',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDialogTextField(
                      controller: colorController,
                      label: 'Color',
                      hintText: '#4CAF50',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDialogTextField(
                      controller: iconController,
                      label: 'Icon',
                      hintText: 'local_cafe',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  nameAmController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category name is required')),
                );
                return;
              }

              try {
                final categoryRepo = ref.read(categoryRepositoryProvider);
                final category = ProductCategory(
                  id: existingCategory?.id,
                  categoryId: existingCategory?.categoryId ??
                      'cat_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  nameAm: nameAmController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  color: colorController.text.trim().isEmpty
                      ? null
                      : colorController.text.trim(),
                  icon: iconController.text.trim().isEmpty
                      ? null
                      : iconController.text.trim(),
                  sortOrder: existingCategory?.sortOrder ?? _categories.length,
                  isActive: existingCategory?.isActive ?? true,
                  createdAt: existingCategory?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                if (isEdit) {
                  await categoryRepo.updateCategory(category);
                } else {
                  await categoryRepo.createCategory(category);
                }

                if (mounted) {
                  Navigator.pop(context);
                  _loadCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Category ${isEdit ? 'updated' : 'created'} successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving category: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  Future<void> _toggleCategoryStatus(ProductCategory category) async {
    try {
      final categoryRepo = ref.read(categoryRepositoryProvider);
      await categoryRepo
          .updateCategory(category.copyWith(isActive: !category.isActive));
      _loadCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Categories'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Categories List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredCategories.isEmpty
                    ? _buildEmptyState()
                    : _buildCategoriesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ListItemShimmer(hasLeading: true, hasTrailing: true),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No categories yet' : 'No categories found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Add your first product category to get started'
                : 'Try adjusting your search terms',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            ElevatedButton(
              onPressed: () => _showAddCategoryDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add First Category'),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(ProductCategory category) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showAddCategoryDialog(existingCategory: category),
      child: Row(
        children: [
          // Category Icon/Color
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _parseColor(category.color ?? '#4CAF50').withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(category.icon ?? 'category'),
              color: _parseColor(category.color ?? '#4CAF50'),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Category Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.nameAm,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                if (category.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    category.description!,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Status and Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Active/Inactive Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: category.isActive
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: category.isActive
                        ? Colors.green.shade200
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  category.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: category.isActive
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Toggle Button
              IconButton(
                icon: Icon(
                  category.isActive ? Icons.toggle_on : Icons.toggle_off,
                  color:
                      category.isActive ? const Color(0xFF10B981) : Colors.grey,
                  size: 30,
                ),
                onPressed: () => _toggleCategoryStatus(category),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF4CAF50);
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'local_grocery_store':
        return Icons.local_grocery_store;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'medical_services':
        return Icons.medical_services;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      case 'spa':
        return Icons.spa;
      case 'home':
        return Icons.home;
      case 'cake':
        return Icons.cake;
      default:
        return Icons.category;
    }
  }
}
