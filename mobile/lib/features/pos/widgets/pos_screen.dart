// mobile/lib/features/pos/widgets/pos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src/models/product.dart';
import '../../../src/models/cart_item.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final List<CartItem> _cartItems = [];
  double _totalAmount = 0.0;

  void _addToCart(Product product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex != -1) {
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + 1,
        );
      } else {
        _cartItems.add(
          CartItem(product: product, quantity: 1, unitPrice: product.price),
        );
      }

      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _totalAmount = _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.unitPrice),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS'),
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: _printReceipt),
        ],
      ),
      body: Column(
        children: [
          // Product Grid
          Expanded(flex: 2, child: _buildProductGrid()),

          // Cart Items
          Expanded(flex: 1, child: _buildCartItems()),

          // Total and Checkout
          _buildCheckoutSection(),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    // Implementation for product grid
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
      ),
      itemCount: 20, // Replace with actual products
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () => _addToCart(
              Product(
                id: index,
                name: 'Product $index',
                price: 100.0 + (index * 10),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Product $index'),
                Text('\$${100.0 + (index * 10)}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItems() {
    return ListView.builder(
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return ListTile(
          title: Text(item.product.name),
          subtitle: Text('${item.quantity} x \$${item.unitPrice}'),
          trailing: Text('\$${item.quantity * item.unitPrice}'),
        );
      },
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Column(
        children: [
          Text(
            'Total: \$$_totalAmount',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cartItems.isEmpty ? null : _processCashPayment,
                  child: const Text('Cash'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _cartItems.isEmpty
                      ? null
                      : _processTelebirrPayment,
                  child: const Text('Telebirr'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _processCashPayment() {
    // Implement cash payment
  }

  void _processTelebirrPayment() {
    // Implement Telebirr payment
  }

  void _printReceipt() {
    // Implement Bluetooth printing
  }
}
