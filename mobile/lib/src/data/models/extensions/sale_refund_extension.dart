// lib/models/extensions/sale_refund_extension.dart

import 'dart:core';
// Assuming your Sale model is here (adjust path as needed)
import '../sale.dart';

// Add this extension to Sale class for canBeRefunded
extension SaleRefundExtension on Sale {
  bool get canBeRefunded {
    // 1. Check if it's already refunded
    if (isRefunded) return false;

    // 2. Check if the sale and payment are fully processed
    if (saleStatus != 'completed') return false;
    if (paymentStatus != 'completed') return false;

    // 3. Check the 30-day refund window
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    // Check if the sale creation date is *after* the date 30 days ago.
    return createdAt.isAfter(thirtyDaysAgo);
  }
}
