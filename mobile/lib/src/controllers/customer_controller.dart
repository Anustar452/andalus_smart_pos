// lib/src/controllers/customer_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/customer.dart';
import '../data/repositories/customer_repository.dart';

class CustomerState {
  final List<Customer> customers;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  const CustomerState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  CustomerState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CustomerController extends StateNotifier<CustomerState> {
  final CustomerRepository _customerRepository;

  CustomerController(this._customerRepository) : super(const CustomerState());

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final customers = await _customerRepository.getAllCustomers();
      state = state.copyWith(customers: customers, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> searchCustomers(String query) async {
    state = state.copyWith(searchQuery: query);
    // Implement search logic
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final customerControllerProvider =
    StateNotifierProvider<CustomerController, CustomerState>(
  (ref) => CustomerController(ref.read(customerRepositoryProvider)),
);
