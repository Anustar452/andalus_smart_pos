// lib/src/controllers/sale_controller.dart - CORRECTED VERSION
import 'dart:async';
import 'package:andalus_smart_pos/src/service/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/models/sale.dart';
import '../data/models/sale_item.dart';
import '../data/models/product.dart';
import '../data/models/user.dart';
import '../data/repositories/sale_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/customer_repository.dart';
// import '../services/sync_service.dart';
import '../utils/print_service.dart';
import '../providers/auth_provider.dart';

class SaleState {
  final Sale? currentSale;
  final List<SaleItem> cartItems;
  final bool isLoading;
  final String? error;
  final bool isPrinting;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;

  const SaleState({
    this.currentSale,
    this.cartItems = const [],
    this.isLoading = false,
    this.error,
    this.isPrinting = false,
    this.subtotal = 0,
    this.tax = 0,
    this.discount = 0,
    this.total = 0,
  });

  SaleState copyWith({
    Sale? currentSale,
    List<SaleItem>? cartItems,
    bool? isLoading,
    String? error,
    bool? isPrinting,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
  }) {
    return SaleState(
      currentSale: currentSale ?? this.currentSale,
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isPrinting: isPrinting ?? this.isPrinting,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
    );
  }

  int get cartItemCount => cartItems.length;
  bool get isCartEmpty => cartItems.isEmpty;
}

class SaleController extends StateNotifier<SaleState> {
  final Ref _ref;
  final SaleRepository _saleRepository;
  final ProductRepository _productRepository;
  final CustomerRepository _customerRepository;
  final SyncService _syncService;

  static const double _taxRate = 0.15;
  static const int _maxCartItems = 100;

  SaleController(
    this._ref, {
    required SaleRepository saleRepository,
    required ProductRepository productRepository,
    required CustomerRepository customerRepository,
    required SyncService syncService,
  })  : _saleRepository = saleRepository,
        _productRepository = productRepository,
        _customerRepository = customerRepository,
        _syncService = syncService,
        super(const SaleState());

  // === CART MANAGEMENT ===
  Future<void> addToCart({
    required Product product,
    required int quantity,
    double? customPrice,
    double? discount,
  }) async {
    try {
      // Validate product
      if (!product.canSellQuantity(quantity)) {
        throw Exception(
            'Cannot add $quantity of ${product.name}. Available: ${product.stockQuantity}');
      }

      // Check cart limits
      if (state.cartItems.length >= _maxCartItems) {
        throw Exception('Cart is full. Maximum $_maxCartItems items allowed');
      }

      // Check if product already in cart
      final existingIndex = state.cartItems
          .indexWhere((item) => item.productId == product.productId);

      if (existingIndex >= 0) {
        // Update existing item
        final existingItem = state.cartItems[existingIndex];
        final newQuantity = existingItem.quantity + quantity;

        if (!product.canSellQuantity(newQuantity)) {
          throw Exception(
              'Cannot add $quantity more. Total would be $newQuantity, available: ${product.stockQuantity}');
        }

        final updatedItems = List<SaleItem>.from(state.cartItems);
        updatedItems[existingIndex] = SaleItem.create(
          saleId: existingItem.saleId,
          productId: product.productId,
          productName: product.name,
          productNameAm: product.nameAm,
          quantity: newQuantity,
          unitPrice: customPrice ?? product.price,
          costPrice: product.costPrice,
          discount: discount ?? existingItem.discount,
          barcode: product.barcode,
          unit: product.unit,
        );

        _updateCart(updatedItems);
      } else {
        // Add new item
        final newItem = SaleItem.create(
          saleId: 'temp',
          productId: product.productId,
          productName: product.name,
          productNameAm: product.nameAm,
          quantity: quantity,
          unitPrice: customPrice ?? product.price,
          costPrice: product.costPrice,
          discount: discount ?? 0,
          barcode: product.barcode,
          unit: product.unit,
        );

        final updatedItems = [...state.cartItems, newItem];
        _updateCart(updatedItems);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void updateCartItemQuantity(String productId, int newQuantity) {
    try {
      if (newQuantity <= 0) {
        removeFromCart(productId);
        return;
      }

      final index =
          state.cartItems.indexWhere((item) => item.productId == productId);
      if (index == -1) return;

      final item = state.cartItems[index];
      final updatedItem = SaleItem.create(
        saleId: item.saleId,
        productId: item.productId,
        productName: item.productName,
        productNameAm: item.productNameAm,
        quantity: newQuantity,
        unitPrice: item.unitPrice,
        costPrice: item.costPrice,
        discount: item.discount,
        barcode: item.barcode,
        unit: item.unit,
      );

      final updatedItems = List<SaleItem>.from(state.cartItems);
      updatedItems[index] = updatedItem;
      _updateCart(updatedItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void removeFromCart(String productId) {
    final updatedItems =
        state.cartItems.where((item) => item.productId != productId).toList();
    _updateCart(updatedItems);
  }

  void clearCart() {
    _updateCart([]);
  }

  void _updateCart(List<SaleItem> items) {
    // Calculate totals
    final subtotal =
        items.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
    final discount = items.fold(0.0, (sum, item) => sum + item.discount);
    final tax = (subtotal - discount) * _taxRate;
    final total = subtotal + tax - discount;

    state = state.copyWith(
      cartItems: items,
      subtotal: double.parse(subtotal.toStringAsFixed(2)),
      tax: double.parse(tax.toStringAsFixed(2)),
      discount: double.parse(discount.toStringAsFixed(2)),
      total: double.parse(total.toStringAsFixed(2)),
      error: null,
    );
  }

  // === SALE PROCESSING ===
  Future<Sale> processSale({
    required String paymentMethod,
    String? paymentReference,
    int? customerId,
    String? customerName,
    double additionalDiscount = 0,
    String? notes,
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Validate cart
      if (state.cartItems.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Validate stock for all items
      await _validateStockAvailability();

      // Get user info (from auth provider)
      final authState = _ref.read(authProvider);
      final User? user = authState.user;
      if (user == null) throw Exception('User not authenticated');

      // Convert userId from String to int
      int userId;
      try {
        userId = int.parse(user.id);
      } catch (e) {
        // If user.id is not a number, use a default or hash
        userId = user.id.hashCode.abs();
      }

      // Create sale
      final sale = Sale.createNew(
        items: state.cartItems,
        userId: userId,
        userName: user.name,
        shopId: 1,
        paymentMethod: paymentMethod,
        paymentReference: paymentReference,
        customerId: customerId,
        customerName: customerName,
        discountAmount: additionalDiscount,
        notes: notes,
      );

      // Process in transaction
      final completedSale = await _processSaleTransaction(sale);

      // Print receipt
      await _printReceipt(completedSale, context);

      // Update state
      state = state.copyWith(
        currentSale: completedSale,
        cartItems: [],
        subtotal: 0,
        tax: 0,
        discount: 0,
        total: 0,
        isLoading: false,
      );

      // Trigger sync if online
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity != ConnectivityResult.none) {
        await _syncService.syncAllData();
      }

      return completedSale;
    } catch (e, stackTrace) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('Sale processing error: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _validateStockAvailability() async {
    for (final item in state.cartItems) {
      try {
        // Use getProductById which we added to ProductRepository
        final product = await _productRepository.getProductById(item.productId);
        if (product == null) {
          throw Exception('Product ${item.productName} not found');
        }

        if (!product.canSellQuantity(item.quantity)) {
          throw Exception(
              'Insufficient stock for ${product.name}. Available: ${product.stockQuantity}, Requested: ${item.quantity}');
        }
      } catch (e) {
        throw Exception('Stock validation failed for ${item.productName}: $e');
      }
    }
  }

  Future<Sale> _processSaleTransaction(Sale sale) async {
    try {
      // Save sale
      final saleId = await _saleRepository.createSale(sale, state.cartItems);

      // Update product stock - using updateStockAfterSale which we added
      for (final item in state.cartItems) {
        await _productRepository.updateStockAfterSale(
          productId: item.productId,
          quantitySold: item.quantity,
        );
      }

      // Update customer balance if credit sale
      if (sale.paymentMethod == 'credit' && sale.customerId != null) {
        // Use updateCustomerBalance which we added to CustomerRepository
        await _customerRepository.updateCustomerBalance(
          customerId: sale.customerId!,
          amount: sale.finalAmount,
          transactionType: 'sale',
          reference: sale.saleId,
        );
      }

      // Get the saved sale - use getSimpleSaleById which returns Sale, not SaleWithItems
      final savedSale = await _saleRepository.getSimpleSaleById(saleId);
      if (savedSale == null) {
        throw Exception('Failed to retrieve saved sale');
      }
      return savedSale;
    } catch (e) {
      throw Exception('Transaction failed: $e');
    }
  }

  Future<void> _printReceipt(Sale sale, BuildContext context) async {
    try {
      state = state.copyWith(isPrinting: true);

      // Convert sale items for printing
      final printItems = state.cartItems.map((item) {
        return {
          'name': item.productName,
          'quantity': item.quantity,
          'price': item.unitPrice,
          'total': item.totalPrice,
        };
      }).toList();

      // Get business info
      final businessInfo = {
        'shopName': 'Andalus Smart POS',
        'shopNameAm': 'አንዳሉስ ስማርት ፖስ',
        'address': 'Addis Ababa, Ethiopia',
        'phone': '+251911223344',
        'tinNumber': '1234567890',
      };

      // Call PrintService with correct parameters matching your existing interface
      await PrintService.printReceipt(
        context: context,
        shopName: businessInfo['shopName']!,
        shopNameAm: businessInfo['shopNameAm']!,
        address: businessInfo['address']!,
        phone: businessInfo['phone']!,
        tinNumber: businessInfo['tinNumber']!,
        receiptNumber: sale.saleId,
        dateTime: sale.createdAt,
        items: printItems,
        subtotal: state.subtotal,
        tax: state.tax,
        discount: state.discount,
        total: state.total,
        paymentMethod: sale.paymentMethod,
        telebirrRef: sale.paymentReference,
        sale: sale,
        businessInfo: businessInfo,
      );

      state = state.copyWith(isPrinting: false);
    } catch (e) {
      state = state.copyWith(isPrinting: false);
      print('Printing failed: $e');
    }
  }

  // === SALE QUERIES ===
  Future<List<Sale>> getTodaySales() async {
    try {
      state = state.copyWith(isLoading: true);
      final sales = await _saleRepository.getTodaysSales();
      state = state.copyWith(isLoading: false);
      return sales;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<SalesSummary> getSalesSummary({DateTimeRange? dateRange}) async {
    try {
      return await _saleRepository.getSalesSummary(dateRange: dateRange);
    } catch (e) {
      throw Exception('Failed to get sales summary: $e');
    }
  }

  Future<List<Sale>> searchSales({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    String? paymentMethod,
    String? status,
    int? customerId,
  }) async {
    return await _saleRepository.searchSales(
      query: query,
      startDate: startDate,
      endDate: endDate,
      paymentMethod: paymentMethod,
      status: status,
      customerId: customerId,
    );
  }

  // === REFUNDS ===
  Future<Sale> refundSale({
    required int saleId,
    required String reason,
    bool fullRefund = true,
    List<String>? itemIds,
    Map<String, int>? partialQuantities,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      // Get original sale
      final originalSaleWithItems = await _saleRepository.getSaleById(saleId);
      if (originalSaleWithItems == null) {
        throw Exception('Sale not found');
      }

      final originalSale = originalSaleWithItems.sale;

      // Check if can be refunded
      if (!originalSale.canBeRefunded) {
        throw Exception('Sale cannot be refunded');
      }

      // Process refund using refundSale method we added
      final refundedSale = await _saleRepository.refundSale(
        saleId: saleId,
        reason: reason,
        fullRefund: fullRefund,
        itemIds: itemIds,
        partialQuantities: partialQuantities,
      );

      // Restore stock if full refund
      if (fullRefund) {
        await _restoreStockForRefund(originalSale);
      }

      state = state.copyWith(isLoading: false);
      return refundedSale;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> _restoreStockForRefund(Sale sale) async {
    final items = await _saleRepository.getSaleItems(sale.id!);

    for (final item in items) {
      await _productRepository.updateStockAfterRefund(
        productId: item.productId,
        quantityRefunded: item.quantity,
      );
    }
  }

  // === UTILITIES ===
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// === PROVIDERS ===
final saleControllerProvider = StateNotifierProvider<SaleController, SaleState>(
  (ref) => SaleController(
    ref,
    saleRepository: ref.read(saleRepositoryProvider),
    productRepository: ref.read(productRepositoryProvider),
    customerRepository: ref.read(customerRepositoryProvider),
    syncService: ref.read(syncServiceProvider),
  ),
);
