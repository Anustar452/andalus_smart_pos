import 'package:andalus_smart_pos/src/data/models/customer.dart';
import 'package:andalus_smart_pos/src/data/repositories/customer_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/product.dart';
import 'package:andalus_smart_pos/src/data/repositories/product_repository.dart';
import 'package:andalus_smart_pos/src/providers/cart_provider.dart';
import 'package:andalus_smart_pos/src/data/models/cart_item.dart';
import 'package:andalus_smart_pos/src/data/models/sale.dart';
import 'package:andalus_smart_pos/src/data/models/sale_item.dart';
import 'package:andalus_smart_pos/src/data/repositories/sale_repository.dart';
import 'package:andalus_smart_pos/src/ui/screens/sales_history_screen.dart';
import 'package:andalus_smart_pos/src/widgets/common/custom_card.dart';
import 'package:andalus_smart_pos/src/widgets/common/loading_shimmer.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';
// import 'package:andalus_smart_pos/src/utils/print_service.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  List<Product> _filteredProducts = [];
  List<Product> _allProducts = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(productRepositoryProvider);
      final products = await repository.getAllProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(query) ||
            product.nameAm.toLowerCase().contains(query) ||
            product.barcode.toLowerCase().contains(query);

        final matchesCategory = _selectedCategory == 'all' ||
            product.categoryId == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _addToCart(Product product) {
    if (product.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} is out of stock'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ref.read(cartProvider.notifier).addProduct(
          productId: product.id!,
          productName: product.name,
          unitPrice: product.price,
        );

    _showAddToCartAnimation(product.name);
  }

  void _showAddToCartAnimation(String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Added $productName to cart')),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _scanBarcode() {
    if (_barcodeController.text.isNotEmpty) {
      final barcode = _barcodeController.text.trim();
      final product = _allProducts.firstWhere(
        (p) => p.barcode == barcode,
        orElse: () => Product(
          id: -1,
          productId: '',
          name: '',
          nameAm: '',
          price: 0,
          stockQuantity: 0,
          barcode: '',
          categoryId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (product.id != -1) {
        _addToCart(product);
        _barcodeController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product not found'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _completeSale() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add products to cart first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check stock availability
    for (final item in cart) {
      final product = _allProducts.firstWhere(
        (p) => p.id == item.productId,
        orElse: () => Product(
          id: -1,
          productId: '',
          name: '',
          nameAm: '',
          price: 0,
          stockQuantity: 0,
          barcode: '',
          categoryId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (product.id != -1 && product.stockQuantity < item.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Insufficient stock for ${product.name}. Available: ${product.stockQuantity}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final total = ref.read(cartProvider.notifier).totalAmount;
    await _showPaymentMethodDialog(total, cart);
  }

  Future<void> _showPaymentMethodDialog(
      double total, List<CartItem> cart) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => PaymentMethodDialog(total: total),
    );

    if (result != null && mounted) {
      final paymentMethod = result['method'] as String;
      final customer = result['customer'] as Customer?;
      await _processSale(total, cart, paymentMethod, customer);
    }
  }

  Future<void> _processSale(double total, List<CartItem> cart,
      String paymentMethod, Customer? customer) async {
    try {
      final saleRepository = ref.read(saleRepositoryProvider);
      final customerRepository = ref.read(customerRepositoryProvider);

      // Create sale object
      final sale = Sale(
        localId: 'sale_${DateTime.now().millisecondsSinceEpoch}',
        totalAmount: total,
        finalAmount: total,
        paymentMethod: paymentMethod,
        paymentStatus: 'completed',
        userId: 1,
        shopId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        saleId: '',
      );

      // Convert cart items to sale items
      final saleItems = cart
          .map((cartItem) => SaleItem(
                saleId: 0,
                productId: cartItem.productId,
                productName: cartItem.productName,
                quantity: cartItem.quantity,
                unitPrice: cartItem.unitPrice,
                totalPrice: cartItem.totalPrice,
                createdAt: DateTime.now(),
              ))
          .toList();

// Handle credit sale
      if (paymentMethod == 'credit' && customer != null) {
        final creditResult = await customerRepository.createCreditSale(
          customerId: customer.id!,
          amount: total,
          saleReference: sale.saleId, // FIX: Use saleId instead of localId
          notes: 'POS Sale - ${cart.length} items',
        );

        if (!creditResult.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Credit sale failed: ${creditResult.error}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Save sale to database
      final saleId = await saleRepository.createSale(sale, saleItems);

      // Update product stock
      final productRepo = ref.read(productRepositoryProvider);
      for (final item in cart) {
        final product = _allProducts.firstWhere((p) => p.id == item.productId);
        if (product.trackInventory) {
          await productRepo.updateStockQuantity(
              item.productId, product.stockQuantity - item.quantity);
        }
      }

      // Clear cart and show success
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sale #$saleId completed successfully!',
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View Receipt',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to receipt screen
              },
            ),
          ),
        );
      }

      // Reload products to update stock
      _loadProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing sale: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<String> _getCategories() {
    final categories = _allProducts.map((p) => p.categoryId).toSet().toList();
    return ['all', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        actions: [
          Badge(
            label: Text(cartNotifier.totalItems.toString()),
            isLabelVisible: cart.isNotEmpty,
            backgroundColor: Colors.white,
            textColor: const Color(0xFF10B981),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_checkout),
              onPressed: () {},
              tooltip: 'View Cart',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search and Controls Section
          _buildControlsSection(),

          // Products and Cart Area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Products Section
                Expanded(
                  flex: 2,
                  child: _isLoading
                      ? _buildProductsShimmer()
                      : _filteredProducts.isEmpty
                          ? _buildEmptyProducts()
                          : _buildProductsGrid(),
                ),

                // Cart Panel
                _buildCartPanel(cart, cartNotifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    return CustomCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search products by name, barcode...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),

          // Barcode and Category Row
          Row(
            children: [
              // Barcode Input
              Expanded(
                child: TextField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: 'Scan barcode',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _scanBarcode(),
                ),
              ),
              const SizedBox(width: 12),
              // Scan Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _scanBarcode,
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: const Text('Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 9,
      itemBuilder: (context, index) => const LoadingShimmer(
        height: 120,
        borderRadius: 12,
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Column(
      children: [
        // Category Filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _getCategories().length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = _getCategories()[index];
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text(category == 'all' ? 'All' : category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCategory = category);
                  _onSearchChanged();
                },
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF10B981),
                side: BorderSide(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                ),
              );
            },
          ),
        ),

        // Products Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return _ProductCard(
                product: product,
                onTap: () => _addToCart(product),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartPanel(List<CartItem> cart, CartNotifier cartNotifier) {
    return Container(
      width: 400,
      margin: const EdgeInsets.all(16),
      child: CustomCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Cart Header (keep existing code)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (cart.isNotEmpty)
                    TextButton(
                      onPressed: () => cartNotifier.clearCart(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear All'),
                    ),
                  Badge(
                    label: Text(cartNotifier.totalItems.toString()),
                    backgroundColor: Colors.white,
                    textColor: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),

            // Cart Items (keep existing code)
            Expanded(
              child: cart.isEmpty
                  ? const _EmptyCart()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        return _CartItem(
                          item: item,
                          onQuantityChanged: (newQuantity) {
                            if (newQuantity > 0) {
                              cartNotifier.updateQuantity(
                                  item.productId, newQuantity);
                            } else {
                              cartNotifier.removeProduct(item.productId);
                            }
                          },
                          onRemove: () {
                            cartNotifier.removeProduct(item.productId);
                          },
                        );
                      },
                    ),
            ),

            // Cart Footer - UPDATED SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                children: [
                  // Subtotal
                  _buildTotalRow('Subtotal', cartNotifier.subtotalAmount),
                  const SizedBox(height: 8),

                  // Tax (if applicable) - uncomment if you want to show tax
                  // _buildTotalRow('Tax (15%)', cartNotifier.taxAmount),
                  // const SizedBox(height: 8),

                  // Total
                  _buildTotalRow(
                    'TOTAL',
                    cartNotifier.totalAmount, // This will work now
                    isTotal: true,
                  ),

                  const SizedBox(height: 16),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _completeSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Complete Sale',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? const Color(0xFF1F2937) : Colors.grey.shade600,
          ),
        ),
        Text(
          AppFormatters.formatCurrency(amount), // Using the formatter
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF10B981) : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProducts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or add new products',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Modern Product Card
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: EdgeInsets.all(0),
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock Status Badge
          if (product.isLowStock || product.isOutOfStock)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: product.isOutOfStock
                    ? Colors.red.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: product.isOutOfStock
                      ? Colors.red.shade200
                      : Colors.orange.shade200,
                ),
              ),
              child: Text(
                product.isOutOfStock ? 'OUT OF STOCK' : 'LOW STOCK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: product.isOutOfStock
                      ? Colors.red.shade700
                      : Colors.orange.shade700,
                ),
              ),
            )
          else
            const SizedBox(height: 20), // Placeholder for alignment

          const Spacer(),

          // Product Name
          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Price
          Text(
            AppFormatters.formatCurrency(product.price),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 4),

          // Stock and Barcode
          Text(
            'Stock: ${product.stockQuantity}',
            style: TextStyle(
              fontSize: 12,
              color: product.isLowStock
                  ? Colors.orange.shade700
                  : Colors.grey.shade600,
              fontWeight:
                  product.isLowStock ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (product.barcode.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Barcode: ${product.barcode}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// Modern Cart Item
class _CartItem extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItem({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.formatCurrency(item.unitPrice),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Quantity Controls
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () => onQuantityChanged(item.quantity - 1),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    item.quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => onQuantityChanged(item.quantity + 1),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Total and Remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.formatCurrency(item.totalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Empty Cart State
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to get started',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// Payment Method Dialog
class PaymentMethodDialog extends ConsumerStatefulWidget {
  final double total;

  const PaymentMethodDialog({super.key, required this.total});

  @override
  ConsumerState<PaymentMethodDialog> createState() =>
      _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends ConsumerState<PaymentMethodDialog> {
  String _selectedMethod = 'cash';
  Customer? _selectedCustomer;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${AppFormatters.formatCurrency(widget.total)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Methods
            _buildPaymentMethodOption('cash', 'Cash', Icons.money),
            _buildPaymentMethodOption('telebirr', 'Telebirr', Icons.qr_code),
            _buildPaymentMethodOption('card', 'Card', Icons.credit_card),
            _buildPaymentMethodOption('credit', 'Credit', Icons.credit_score),

            // Customer Selection for Credit
            if (_selectedMethod == 'credit') ...[
              const SizedBox(height: 16),
              _buildCustomerSelector(),
            ],

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
                    onPressed: _canProceed
                        ? () => Navigator.pop(context, {
                              'method': _selectedMethod,
                              'customer': _selectedCustomer,
                            })
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm Payment'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String label, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedMethod,
      onChanged: (newValue) => setState(() => _selectedMethod = newValue!),
      title: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF10B981)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return FutureBuilder<List<Customer>>(
      future: ref
          .read(customerRepositoryProvider)
          .getAllCustomers(activeOnly: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Text(
            'Error loading customers',
            style: TextStyle(color: Colors.red.shade700),
          );
        }

        final customers = snapshot.data!.where((c) => c.allowCredit).toList();

        if (customers.isEmpty) {
          return Text(
            'No credit customers found',
            style: TextStyle(color: Colors.orange.shade700),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Customer *',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Customer>(
              value: _selectedCustomer,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: customers.map((customer) {
                return DropdownMenuItem(
                  value: customer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name),
                      Text(
                        'Credit Available: ${AppFormatters.formatCurrency(customer.availableCredit)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (customer) =>
                  setState(() => _selectedCustomer = customer),
              validator: (value) {
                if (_selectedMethod == 'credit' && value == null) {
                  return 'Please select a customer';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  bool get _canProceed {
    if (_selectedMethod == 'credit') {
      return _selectedCustomer != null &&
          _selectedCustomer!.availableCredit >= widget.total;
    }
    return true;
  }
}
