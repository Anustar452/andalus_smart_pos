// lib/src/controllers/product_controller.dart
// Controller for managing product-related state and actions.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final String? selectedCategory;

  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.selectedCategory,
  });

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class ProductController extends StateNotifier<ProductState> {
  final ProductRepository _productRepository;

  ProductController(this._productRepository) : super(const ProductState());

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _productRepository.getAllProducts();
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> searchProducts(String query) async {
    state = state.copyWith(searchQuery: query);
    // Implement search logic
  }

  void filterByCategory(String? categoryId) {
    state = state.copyWith(selectedCategory: categoryId);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final productControllerProvider =
    StateNotifierProvider<ProductController, ProductState>(
  (ref) => ProductController(ref.read(productRepositoryProvider)),
);
