// lib/src/ui/screens/pos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/customer.dart';
import 'package:andalus_smart_pos/src/data/models/product.dart';
import 'package:andalus_smart_pos/src/data/models/sale.dart';
import 'package:andalus_smart_pos/src/data/models/sale_item.dart';
import 'package:andalus_smart_pos/src/data/models/cart_item.dart';
import 'package:andalus_smart_pos/src/data/repositories/customer_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/product_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/sale_repository.dart';
import 'package:andalus_smart_pos/src/providers/cart_provider.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';
import 'package:andalus_smart_pos/src/utils/print_service.dart';
import 'package:andalus_smart_pos/src/ui/screens/printer_connection_screen.dart';
import 'package:andalus_smart_pos/src/widgets/common/custom_card.dart';
import 'package:andalus_smart_pos/src/widgets/common/loading_shimmer.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();

  List<Product> _filteredProducts = [];
  List<Product> _allProducts = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  bool _isPrinting = false;

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
    _barcodeFocusNode.dispose();
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
        _showErrorSnackBar('Error loading products: $e');
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
      _showWarningSnackBar('${product.name} is out of stock');
      return;
    }

    ref.read(cartProvider.notifier).addProduct(
          productId: product.id!,
          productName: product.name,
          unitPrice: product.price,
        );

    _showSuccessSnackBar('Added ${product.name} to cart');
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
        _barcodeFocusNode.requestFocus();
      } else {
        _showWarningSnackBar('Product not found');
      }
    }
  }

  // Snackbar helpers
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // FIXED: Proper Header with Search
          _buildHeaderSection(localizations, theme),

          // Main Content Area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Products Section
                Expanded(
                  flex: 3,
                  child: _buildProductsSection(localizations, theme),
                ),

                // Cart Panel
                _buildCartPanel(cart, cartNotifier, localizations, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Header with proper search box
  Widget _buildHeaderSection(AppLocalizations localizations, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Title and Printer Status Row
              Row(
                children: [
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.pointOfSale,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          localizations.searchProducts,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Printer Status
                  _buildPrinterStatus(theme, localizations),

                  const SizedBox(width: 12),

                  // Cart Badge
                  _buildCartBadge(localizations, theme),
                ],
              ),

              const SizedBox(height: 16),

              // FIXED: Search Box - Now properly visible
              _buildSearchBox(localizations, theme),
            ],
          ),
        ),
      ),
    );
  }

  // FIXED: Search Box Widget
  Widget _buildSearchBox(AppLocalizations localizations, ThemeData theme) {
    return Row(
      children: [
        // Search Field
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localizations.searchProducts,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onPrimary.withOpacity(0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onPrimary.withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
              ),
              onChanged: (_) => _onSearchChanged(),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Print Button - Now visible in header
        Tooltip(
          message: PrintService.isConnected
              ? 'Print Test Receipt'
              : 'Connect Printer First',
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.print,
                color: PrintService.isConnected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onPrimary.withOpacity(0.5),
              ),
              onPressed: PrintService.isConnected
                  ? _testPrint
                  : _navigateToPrinterConnection,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrinterStatus(ThemeData theme, AppLocalizations localizations) {
    return Tooltip(
      message: PrintService.isConnected
          ? '${localizations.translate("connectedTo")} ${PrintService.connectedDeviceName}'
          : localizations.translate("noPrinterConnected"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PrintService.isConnected ? Icons.print : Icons.print_disabled,
              size: 16,
              color: PrintService.isConnected
                  ? theme.colorScheme.onPrimary
                  : Colors.amber[300],
            ),
            const SizedBox(width: 6),
            Text(
              PrintService.isConnected ? 'Connected' : 'No Printer',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBadge(AppLocalizations localizations, ThemeData theme) {
    final cart = ref.watch(cartProvider);
    return Badge(
      label: Text(
        ref.read(cartProvider.notifier).totalItems.toString(),
        style: TextStyle(
          fontSize: 10,
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      isLabelVisible: cart.isNotEmpty,
      backgroundColor: theme.colorScheme.onPrimary,
      child: IconButton(
        icon: Icon(Icons.shopping_cart, color: theme.colorScheme.onPrimary),
        onPressed: () {},
        tooltip: localizations.shoppingCart,
      ),
    );
  }

  Widget _buildProductsSection(
      AppLocalizations localizations, ThemeData theme) {
    return Column(
      children: [
        // Barcode Scanner Section
        _buildBarcodeSection(localizations, theme),

        // Products Grid
        Expanded(
          child: _isLoading
              ? _buildProductsShimmer()
              : _filteredProducts.isEmpty
                  ? _buildEmptyProducts(localizations, theme)
                  : _buildProductsGrid(localizations, theme),
        ),
      ],
    );
  }

  Widget _buildBarcodeSection(AppLocalizations localizations, ThemeData theme) {
    return CustomCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Barcode Input
          Expanded(
            child: TextField(
              controller: _barcodeController,
              focusNode: _barcodeFocusNode,
              decoration: InputDecoration(
                labelText: localizations.translate('scanBarcode'),
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
              label: Text(localizations.translate('scan')),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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

  Widget _buildProductsGrid(AppLocalizations localizations, ThemeData theme) {
    return Column(
      children: [
        // Category Filter
        SizedBox(
          height: 60,
          child: _buildCategoryFilter(theme),
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

  Widget _buildCategoryFilter(ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: _getCategories().length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final category = _getCategories()[index];
        final isSelected = _selectedCategory == category;
        return FilterChip(
          label: Text(category == 'all' ? 'All Categories' : category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedCategory = category);
            _onSearchChanged();
          },
          backgroundColor: theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary.withOpacity(0.1),
          checkmarkColor: theme.colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        );
      },
    );
  }

  Widget _buildCartPanel(List<CartItem> cart, CartNotifier cartNotifier,
      AppLocalizations localizations, ThemeData theme) {
    return Container(
      width: 400,
      margin: const EdgeInsets.all(16),
      child: CustomCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Cart Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  Text(
                    localizations.translate('orderSummary'),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (cart.isNotEmpty)
                    TextButton(
                      onPressed: () => cartNotifier.clearCart(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: Text(localizations.clearAll),
                    ),
                  Badge(
                    label: Text(cartNotifier.totalItems.toString()),
                    backgroundColor: theme.colorScheme.onPrimary,
                    textColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            // Cart Items
            Expanded(
              child: cart.isEmpty
                  ? _EmptyCart(localizations: localizations)
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

            // Cart Footer with Print Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2)),
                ),
              ),
              child: Column(
                children: [
                  // Totals
                  _buildTotalRow(localizations.translate('subtotal'),
                      cartNotifier.subtotalAmount, theme),
                  const SizedBox(height: 8),
                  _buildTotalRow(localizations.translate('total'),
                      cartNotifier.totalAmount, theme,
                      isTotal: true),

                  const SizedBox(height: 16),

                  // FIXED: Action Buttons with Print Option
                  _buildActionButtons(cartNotifier, localizations, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, ThemeData theme,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          AppFormatters.formatCurrency(amount),
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // FIXED: Action Buttons with Print Option
  Widget _buildActionButtons(CartNotifier cartNotifier,
      AppLocalizations localizations, ThemeData theme) {
    final cart = ref.watch(cartProvider);

    return Column(
      children: [
        // Complete Sale Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _completeSale,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isPrinting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        localizations.completeSale,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        if (cart.isNotEmpty) ...[
          const SizedBox(height: 8),

          // Print and Clear Buttons Row
          Row(
            children: [
              // Print Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isPrinting ? null : _testPrint,
                  icon: Icon(
                    Icons.print,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    localizations.translate('testPrint'),
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Clear Cart Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => cartNotifier.clearCart(),
                  icon: Icon(
                    Icons.clear_all,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    localizations.clearAll,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyProducts(AppLocalizations localizations, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            localizations.noProductsFound,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('tryAdjustingSearch'),
            style: TextStyle(color: theme.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<String> _getCategories() {
    final categories = _allProducts.map((p) => p.categoryId).toSet().toList();
    return ['all', ...categories];
  }

  // Payment and Printing Methods
  Future<void> _completeSale() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      _showWarningSnackBar('Please add products to cart first');
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
        _showErrorSnackBar(
            'Insufficient stock for ${product.name}. Available: ${product.stockQuantity}');
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
    setState(() => _isPrinting = true);

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
        saleId: 'SALE${DateTime.now().millisecondsSinceEpoch}',
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
          saleReference: sale.saleId,
          notes: 'POS Sale - ${cart.length} items',
        );

        if (!creditResult.success) {
          _showErrorSnackBar('Credit sale failed: ${creditResult.error}');
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

      // Print receipt
      final printSuccess = await _printReceipt(
        saleId: saleId,
        cart: cart,
        total: total,
        paymentMethod: paymentMethod,
        customer: customer,
      );

      // Clear cart
      ref.read(cartProvider.notifier).clearCart();

      // Show success message
      if (mounted) {
        _showSuccessSnackBar(
          'Sale #$saleId completed successfully!${printSuccess ? '' : ' (Receipt not printed)'}',
        );
      }

      // Reload products
      _loadProducts();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error processing sale: $e');
      }
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  Future<bool> _printReceipt({
    required int saleId,
    required List<CartItem> cart,
    required double total,
    required String paymentMethod,
    required Customer? customer,
  }) async {
    try {
      final printItems = cart
          .map((item) => {
                'name': item.productName,
                'quantity': item.quantity,
                'price': item.unitPrice,
                'total': item.totalPrice,
              })
          .toList();

      final subtotal = ref.read(cartProvider.notifier).subtotalAmount;

      final success = await PrintService.printReceipt(
        context: context,
        shopName: 'Andalus Smart POS',
        shopNameAm: 'አንዳሉስ ማርቲን ፖስ',
        address: 'Addis Ababa, Ethiopia',
        phone: '+251911223344',
        tinNumber: '1234567890',
        receiptNumber: 'REC-$saleId',
        dateTime: DateTime.now(),
        items: printItems,
        subtotal: subtotal,
        tax: 0.0,
        discount: 0.0,
        total: total,
        paymentMethod: paymentMethod,
        telebirrRef: paymentMethod == 'telebirr'
            ? 'TEL${DateTime.now().millisecondsSinceEpoch}'
            : null,
      );

      return success;
    } catch (e) {
      print('Printing error: $e');
      return false;
    }
  }

  void _testPrint() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      _showWarningSnackBar('Please add products to cart first');
      return;
    }

    setState(() => _isPrinting = true);
    final success = await _printReceipt(
      saleId: 999,
      cart: cart,
      total: ref.read(cartProvider.notifier).totalAmount,
      paymentMethod: 'cash',
      customer: null,
    );

    setState(() => _isPrinting = false);

    if (!success && mounted) {
      _showPrinterConnectionDialog();
    }
  }

  void _showPrinterConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Printer Not Connected'),
        content: const Text('Please connect a printer to print receipts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToPrinterConnection();
            },
            child: const Text('Connect Printer'),
          ),
        ],
      ),
    );
  }

  void _navigateToPrinterConnection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrinterConnectionScreen()),
    );
  }
}

// Keep the existing _ProductCard, _CartItem, _EmptyCart, and PaymentMethodDialog classes...
// [The rest of the widget classes remain the same as in the previous implementation]
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
    final theme = Theme.of(context);

    return CustomCard(
      margin: EdgeInsets.zero,
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
                    ? theme.colorScheme.errorContainer
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: product.isOutOfStock
                      ? theme.colorScheme.error
                      : Colors.orange.shade200,
                ),
              ),
              child: Text(
                product.isOutOfStock ? 'OUT OF STOCK' : 'LOW STOCK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: product.isOutOfStock
                      ? theme.colorScheme.error
                      : Colors.orange.shade700,
                ),
              ),
            )
          else
            const SizedBox(height: 20),

          const Spacer(),

          // Product Name
          Text(
            product.name,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Price
          Text(
            AppFormatters.formatCurrency(product.price),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 4),

          // Stock and Barcode
          Text(
            'Stock: ${product.stockQuantity}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: product.isLowStock
                  ? Colors.orange.shade700
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight:
                  product.isLowStock ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (product.barcode.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Barcode: ${product.barcode}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
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
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.formatCurrency(item.unitPrice),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Quantity Controls
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove,
                      size: 18, color: theme.colorScheme.primary),
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add,
                      size: 18, color: theme.colorScheme.primary),
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
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
  final AppLocalizations localizations;

  const _EmptyCart({required this.localizations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.yourCartEmpty,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.addProductsGetStarted,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
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
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.selectPaymentMethod,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${localizations.totalAmount}: ${AppFormatters.formatCurrency(widget.total)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Payment Methods
            _buildPaymentMethodOption(
                'cash', localizations.cash, Icons.money, theme),
            _buildPaymentMethodOption(
                'telebirr', localizations.telebirr, Icons.qr_code, theme),
            _buildPaymentMethodOption(
                'card', localizations.card, Icons.credit_card, theme),
            _buildPaymentMethodOption(
                'credit', localizations.credit, Icons.credit_score, theme),

            // Customer Selection for Credit
            if (_selectedMethod == 'credit') ...[
              const SizedBox(height: 16),
              _buildCustomerSelector(localizations, theme),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(localizations.cancel),
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
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: Text(localizations.confirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(
      String value, String label, IconData icon, ThemeData theme) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedMethod,
      onChanged: (newValue) => setState(() => _selectedMethod = newValue!),
      title: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSelector(
      AppLocalizations localizations, ThemeData theme) {
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
            style: TextStyle(color: theme.colorScheme.error),
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
            Text(
              '${localizations.selectCustomer} *',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Customer>(
              value: _selectedCustomer,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: customers.map((customer) {
                return DropdownMenuItem(
                  value: customer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name),
                      Text(
                        '${localizations.creditAvailable}: ${AppFormatters.formatCurrency(customer.availableCredit)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
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
