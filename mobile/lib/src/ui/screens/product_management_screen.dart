import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/product.dart';
import 'package:andalus_smart_pos/src/data/repositories/product_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/category_repository.dart';
import 'package:andalus_smart_pos/src/data/models/category.dart';
import 'package:andalus_smart_pos/src/widgets/common/custom_card.dart';
import 'package:andalus_smart_pos/src/widgets/common/loading_shimmer.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState
    extends ConsumerState<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  List<Product> _allProducts = [];
  List<ProductCategory> _categories = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'active', 'low_stock', 'out_of_stock'
  String _categoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final productRepo = ref.read(productRepositoryProvider);
      final categoryRepo = ref.read(categoryRepositoryProvider);

      // Load both products and categories concurrently
      final results = await Future.wait([
        productRepo.getAllProducts(),
        categoryRepo.getAllCategories(),
      ], eagerError: true); // eagerError: true will throw on first error

      // Type casting with null safety
      final products = results[0] as List<Product>? ?? [];
      final categories = results[1] as List<ProductCategory>? ?? [];

      // Ensure we have at least one category for the filter
      if (categories.isNotEmpty && _categoryFilter == 'all') {
        _categoryFilter = categories.first.categoryId;
      }

      setState(() {
        _allProducts = products;
        _categories = categories;
        _filteredProducts = _applyFilters(products, _filter, _categoryFilter);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _allProducts = [];
        _categories = [];
        _filteredProducts = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  List<Product> _applyFilters(
      List<Product> products, String statusFilter, String categoryFilter) {
    return products.where((product) {
      // Status filter
      final statusMatch = switch (statusFilter) {
        'active' => product.isActive,
        'inactive' => !product.isActive,
        'low_stock' => product.isLowStock,
        'out_of_stock' => product.isOutOfStock,
        _ => true,
      };

      // Category filter
      final categoryMatch =
          categoryFilter == 'all' || product.categoryId == categoryFilter;

      return statusMatch && categoryMatch;
    }).toList();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredProducts =
            _applyFilters(_allProducts, _filter, _categoryFilter);
      } else {
        final searched = _allProducts.where((product) {
          return product.name.toLowerCase().contains(query) ||
              product.nameAm.toLowerCase().contains(query) ||
              product.barcode.toLowerCase().contains(query) ||
              product.sku?.toLowerCase().contains(query) == true;
        }).toList();
        _filteredProducts = _applyFilters(searched, _filter, _categoryFilter);
      }
    });
  }

  void _changeStatusFilter(String newFilter) {
    setState(() => _filter = newFilter);
    _filteredProducts = _applyFilters(_allProducts, newFilter, _categoryFilter);
  }

  void _changeCategoryFilter(String newCategory) {
    setState(() => _categoryFilter = newCategory);
    _filteredProducts = _applyFilters(_allProducts, _filter, newCategory);
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        categories: _categories,
        onProductAdded: _loadData,
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => EditProductDialog(
        product: product,
        categories: _categories,
        onProductUpdated: _loadData,
      ),
    );
  }

  Future<void> _toggleProductStatus(Product product) async {
    try {
      final repository = ref.read(productRepositoryProvider);
      await repository.updateProduct(
        product.copyWith(isActive: !product.isActive),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.name} ${product.isActive ? 'deactivated' : 'activated'} successfully',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateStock(Product product, int newStock) async {
    try {
      final repository = ref.read(productRepositoryProvider);
      await repository.updateStockQuantity(product.id!, newStock);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock updated successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating stock: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Statistics
  int get _totalProducts => _allProducts.length;
  int get _activeProducts => _allProducts.where((p) => p.isActive).length;
  int get _lowStockProducts => _allProducts.where((p) => p.isLowStock).length;
  int get _outOfStockProducts =>
      _allProducts.where((p) => p.isOutOfStock).length;
  double get _totalInventoryValue => _allProducts.fold(
      0, (sum, product) => sum + (product.price * product.stockQuantity));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProductDialog,
            tooltip: 'Add Product',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          _buildSearchSection(),

          // Statistics
          if (_allProducts.isNotEmpty) _buildStatisticsSection(),

          // Products List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchSection() {
    return CustomCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),

          // Filters Row
          Row(
            children: [
              // Status Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filter,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Products')),
                    DropdownMenuItem(
                        value: 'active', child: Text('Active Only')),
                    DropdownMenuItem(
                        value: 'inactive', child: Text('Inactive')),
                    DropdownMenuItem(
                        value: 'low_stock', child: Text('Low Stock')),
                    DropdownMenuItem(
                        value: 'out_of_stock', child: Text('Out of Stock')),
                  ],
                  onChanged: (value) => _changeStatusFilter(value!),
                ),
              ),
              const SizedBox(width: 12),

              // Category Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _categoryFilter,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: 'all', child: Text('All Categories')),
                    ..._categories.map((category) {
                      return DropdownMenuItem(
                        value: category.categoryId,
                        child: Text(category.name),
                      );
                    }),
                  ],
                  onChanged: (value) => _changeCategoryFilter(value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return CustomCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', _totalProducts.toString(),
                  Icons.inventory_2, const Color(0xFF10B981)),
              _buildStatItem('Active', _activeProducts.toString(),
                  Icons.check_circle, Colors.green),
              _buildStatItem('Low Stock', _lowStockProducts.toString(),
                  Icons.warning, Colors.orange),
              _buildStatItem('Out of Stock', _outOfStockProducts.toString(),
                  Icons.error, Colors.red),
            ],
          ),
          const SizedBox(height: 12),

          // Inventory Value
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.attach_money,
                    color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Total Inventory Value: ${AppFormatters.formatCurrency(_totalInventoryValue)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LoadingShimmer(height: 120, borderRadius: 12),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(),
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add First Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    if (_searchController.text.isNotEmpty) {
      return 'No products match your search criteria.\nTry adjusting your search terms.';
    }

    switch (_filter) {
      case 'active':
        return 'No active products found.';
      case 'inactive':
        return 'No inactive products found.';
      case 'low_stock':
        return 'No low stock products.\nGreat job managing inventory!';
      case 'out_of_stock':
        return 'No out of stock products.';
      default:
        return 'No products in inventory.\nAdd your first product to get started!';
    }
  }

  Widget _buildProductsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final category = _categories.firstWhere(
      (c) => c.categoryId == product.categoryId,
      orElse: () => ProductCategory(
        categoryId: '',
        name: 'Unknown',
        nameAm: 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Status Badges
                        Row(
                          children: [
                            if (!product.isActive)
                              _buildStatusBadge('INACTIVE', Colors.grey),
                            if (product.isOutOfStock)
                              _buildStatusBadge('OUT OF STOCK', Colors.red),
                            if (product.isLowStock)
                              _buildStatusBadge('LOW STOCK', Colors.orange),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.name,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details
          Row(
            children: [
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.formatCurrency(product.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${product.stockQuantity}',
                      style: TextStyle(
                        color:
                            product.isLowStock ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (product.barcode.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Barcode: ${product.barcode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (product.sku != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'SKU: ${product.sku}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  // Stock Update Button
                  OutlinedButton(
                    onPressed: () => _showStockUpdateDialog(product),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Update Stock'),
                  ),
                  const SizedBox(height: 8),

                  // Edit and Toggle Buttons
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _showEditProductDialog(product),
                        tooltip: 'Edit Product',
                      ),
                      IconButton(
                        icon: Icon(
                          product.isActive ? Icons.toggle_on : Icons.toggle_off,
                          size: 18,
                          color: product.isActive
                              ? const Color(0xFF10B981)
                              : Colors.grey,
                        ),
                        onPressed: () => _toggleProductStatus(product),
                        tooltip: product.isActive ? 'Deactivate' : 'Activate',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showStockUpdateDialog(Product product) {
    final stockController =
        TextEditingController(text: product.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: TextField(
          controller: stockController,
          decoration: const InputDecoration(
            labelText: 'New Stock Quantity',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null && newStock >= 0) {
                Navigator.pop(context);
                _updateStock(product, newStock);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid stock quantity'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

// Add Product Dialog
class AddProductDialog extends ConsumerStatefulWidget {
  final List<ProductCategory> categories;
  final VoidCallback onProductAdded;

  const AddProductDialog({
    super.key,
    required this.categories,
    required this.onProductAdded,
  });

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameAmController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '10');
  final _barcodeController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitController = TextEditingController();
  final _brandController = TextEditingController();
  final _supplierController = TextEditingController();

  String _selectedCategory = '';
  bool _trackInventory = true;

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first.categoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameAmController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _barcodeController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _brandController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final repository = ref.read(productRepositoryProvider);

      final product = Product(
        productId: 'prod_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        nameAm: _nameAmController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        costPrice: _costPriceController.text.isEmpty
            ? null
            : double.parse(_costPriceController.text),
        stockQuantity: int.parse(_stockController.text),
        minStockLevel: _minStockController.text.isEmpty
            ? null
            : int.parse(_minStockController.text),
        barcode: _barcodeController.text.trim(),
        sku: _skuController.text.trim().isEmpty
            ? null
            : _skuController.text.trim(),
        categoryId: _selectedCategory,
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        supplier: _supplierController.text.trim().isEmpty
            ? null
            : _supplierController.text.trim(),
        trackInventory: _trackInventory,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProduct(product);

      if (mounted) {
        Navigator.pop(context);
        widget.onProductAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF10B981)),
                  SizedBox(width: 8),
                  Text(
                    'Add New Product',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Basic Information
              const Text(
                'Basic Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTextField(_nameController, 'Product Name (English) *',
                  validator: _validateRequired),
              const SizedBox(height: 12),
              _buildTextField(_nameAmController, 'Product Name (Amharic) *',
                  validator: _validateRequired),
              const SizedBox(height: 12),
              _buildTextField(_descriptionController, 'Description',
                  maxLines: 2),

              const SizedBox(height: 20),
              const Text(
                'Pricing & Inventory',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_priceController, 'Price (ETB) *',
                          keyboardType: TextInputType.number,
                          validator: _validatePrice)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(
                          _costPriceController, 'Cost Price (ETB)',
                          keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          _stockController, 'Stock Quantity *',
                          keyboardType: TextInputType.number,
                          validator: _validateStock)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(
                          _minStockController, 'Min Stock Level',
                          keyboardType: TextInputType.number)),
                ],
              ),

              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Track Inventory'),
                value: _trackInventory,
                onChanged: (value) => setState(() => _trackInventory = value),
              ),

              const SizedBox(height: 20),
              const Text(
                'Categorization',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.categoryId,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),

              const SizedBox(height: 20),
              const Text(
                'Additional Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_barcodeController, 'Barcode')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(_skuController, 'SKU')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          _unitController, 'Unit (e.g., pcs, kg)')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(_brandController, 'Brand')),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_supplierController, 'Supplier'),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add Product'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stock quantity is required';
    }
    final stock = int.tryParse(value);
    if (stock == null || stock < 0) {
      return 'Please enter a valid stock quantity';
    }
    return null;
  }
}

// Edit Product Dialog (similar structure but for editing)
class EditProductDialog extends ConsumerStatefulWidget {
  final Product product;
  final List<ProductCategory> categories;
  final VoidCallback onProductUpdated;

  const EditProductDialog({
    super.key,
    required this.product,
    required this.categories,
    required this.onProductUpdated,
  });

  @override
  ConsumerState<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends ConsumerState<EditProductDialog> {
  // Similar structure to AddProductDialog but pre-filled with product data
  // Implementation follows same pattern as AddProductDialog
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Product'),
      content: const Text('Edit product form goes here...'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Save changes logic
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
