// src/data/models/credit_transaction.dart
import 'package:flutter/material.dart';

class CreditTransaction {
  final int? id;
  final String localId;
  final int customerId;
  final String customerName;
  final String type; // 'sale', 'payment', 'adjustment'
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? reference; // sale_id or payment reference
  final String? notes;
  final DateTime createdAt;

  CreditTransaction({
    this.id,
    required this.localId,
    required this.customerId,
    required this.customerName,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.reference,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'local_id': localId,
      'customer_id': customerId,
      'customer_name': customerName,
      'type': type,
      'amount': amount,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'reference': reference,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory CreditTransaction.fromMap(Map<String, dynamic> map) {
    return CreditTransaction(
      id: map['id'],
      localId: map['local_id'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      type: map['type'],
      amount: map['amount'],
      balanceBefore: map['balance_before'],
      balanceAfter: map['balance_after'],
      reference: map['reference'],
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  // Helper methods
  bool get isSale => type == 'sale';
  bool get isPayment => type == 'payment';
  bool get isAdjustment => type == 'adjustment';

  String get formattedAmount {
    if (isSale) {
      return '+ETB ${amount.toStringAsFixed(2)}';
    } else if (isPayment) {
      return '-ETB ${amount.toStringAsFixed(2)}';
    } else {
      return 'ETB ${amount.toStringAsFixed(2)}';
    }
  }

  String get description {
    switch (type) {
      case 'sale':
        return 'Credit Sale';
      case 'payment':
        return 'Payment Received';
      case 'adjustment':
        return 'Credit Limit Adjustment';
      default:
        return 'Transaction';
    }
  }

  Color get amountColor {
    switch (type) {
      case 'sale':
        return Colors.red;
      case 'payment':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData get icon {
    switch (type) {
      case 'sale':
        return Icons.shopping_cart;
      case 'payment':
        return Icons.payment;
      case 'adjustment':
        return Icons.tune;
      default:
        return Icons.receipt;
    }
  }
}
