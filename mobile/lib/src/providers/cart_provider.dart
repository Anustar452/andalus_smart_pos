// mobile/lib/src/providers/cart_provider.dart
// Provider for managing the shopping cart state.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/cart_item.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  // Getters for cart calculations
  double get subtotalAmount {
    return state.fold(0, (total, item) => total + item.totalPrice);
  }

  double get taxAmount {
    // Assuming 15% tax rate - you can make this configurable
    return subtotalAmount * 0.15;
  }

  double get totalAmount {
    return subtotalAmount + taxAmount;
  }

  int get totalItems {
    return state.fold(0, (total, item) => total + item.quantity);
  }

  // Cart operations
  void addProduct({
    required int productId,
    required String productName,
    required double unitPrice,
    int quantity = 1,
  }) {
    final existingIndex =
        state.indexWhere((item) => item.productId == productId);

    if (existingIndex != -1) {
      // Update existing item
      final existingItem = state[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      final updatedItem = existingItem.copyWith(quantity: newQuantity);

      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new item
      final newItem = CartItem(
        productId: productId,
        productName: productName,
        unitPrice: unitPrice,
        quantity: quantity,
      );
      state = [...state, newItem];
    }
  }

  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeProduct(productId);
      return;
    }

    final index = state.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      final updatedItem = state[index].copyWith(quantity: newQuantity);
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
    }
  }

  void removeProduct(int productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void clearCart() {
    state = [];
  }

  // Helper methods
  bool containsProduct(int productId) {
    return state.any((item) => item.productId == productId);
  }

  int getProductQuantity(int productId) {
    final item = state.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
        productId: -1,
        productName: '',
        unitPrice: 0,
        quantity: 0,
      ),
    );
    return item.productId == -1 ? 0 : item.quantity;
  }

  // Apply discount to entire cart (optional feature)
  void applyDiscount(double discountPercentage) {
    // This would modify the cart items with discounted prices
    // Implementation depends on your discount strategy
  }

  // Apply tax (optional - you might want to handle this differently)
  void setTaxRate(double taxRate) {
    // Store tax rate and recalculate totals
  }
}
