// lib/src/utils/reports_data_calculator.dart
import 'package:andalus_smart_pos/src/data/models/customer.dart';
import 'package:andalus_smart_pos/src/data/models/product.dart';
import 'package:andalus_smart_pos/src/data/models/sale.dart';
import 'package:andalus_smart_pos/src/data/models/subscription.dart';
import 'package:andalus_smart_pos/src/data/repositories/customer_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/product_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/sale_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';

class ReportsDataCalculator {
  static Future<ReportsData> generateReports({
    required Ref ref,
    required DateTimeRange dateRange,
    required SubscriptionPlan plan,
  }) async {
    final saleRepo = ref.read(saleRepositoryProvider);
    final productRepo = ref.read(productRepositoryProvider);
    final customerRepo = ref.read(customerRepositoryProvider);

    final sales = await saleRepo.getAllSales();
    final products = await productRepo.getAllProducts();
    final customers = await customerRepo.getAllCustomers();

    final filteredSales = _filterSalesByDateRange(sales, dateRange);

    return ReportsData(
      salesData: await _generateSalesReport(filteredSales, plan),
      productsData:
          await _generateProductsReport(products, filteredSales, plan),
      customersData:
          await _generateCustomersReport(customers, filteredSales, plan),
      financialData: await _generateFinancialReport(filteredSales, plan),
    );
  }

  static List<Sale> _filterSalesByDateRange(
      List<Sale> sales, DateTimeRange range) {
    return sales
        .where((sale) =>
            sale.createdAt.isAfter(range.start) &&
            sale.createdAt.isBefore(range.end.add(const Duration(days: 1))))
        .toList();
  }

  static Future<SalesReportData> _generateSalesReport(
      List<Sale> sales, SubscriptionPlan plan) async {
    final totalSales = sales.fold(0.0, (sum, sale) => sum + sale.finalAmount);
    final totalOrders = sales.length;
    final averageOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;

    final salesByPaymentMethod = _calculateSalesByPaymentMethod(sales);
    final revenueByDay = _calculateRevenueByDay(sales);
    final dailySalesTrend = _calculateDailySalesTrend(sales);
    final topSellingHours = _calculateTopSellingHours(sales);

    // Advanced analytics for higher plans
    final customerRetention =
        plan.id != 'basic' ? _calculateCustomerRetentionRate(sales) : null;
    final salesVelocity =
        plan.id == 'enterprise' ? _calculateSalesVelocity(sales) : null;

    return SalesReportData(
      totalSales: totalSales,
      totalOrders: totalOrders,
      averageOrderValue: averageOrderValue,
      salesByPaymentMethod: salesByPaymentMethod,
      revenueByDay: revenueByDay,
      dailySalesTrend: dailySalesTrend,
      topSellingHours: topSellingHours,
      customerRetention: customerRetention,
      salesVelocity: salesVelocity,
    );
  }

  static Map<String, double> _calculateSalesByPaymentMethod(List<Sale> sales) {
    final methodSales = <String, double>{};
    for (final sale in sales) {
      methodSales.update(
        sale.paymentMethod,
        (value) => value + sale.finalAmount,
        ifAbsent: () => sale.finalAmount,
      );
    }
    return methodSales;
  }

  static Map<String, double> _calculateRevenueByDay(List<Sale> sales) {
    final revenueByDay = <String, double>{};
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Initialize with zeros
    for (final day in days) {
      revenueByDay[day] = 0.0;
    }

    for (final sale in sales) {
      final dayName = _getDayName(sale.createdAt.weekday);
      revenueByDay[dayName] = (revenueByDay[dayName] ?? 0) + sale.finalAmount;
    }

    return revenueByDay;
  }

  static List<DailySalesData> _calculateDailySalesTrend(List<Sale> sales) {
    final dailySales = <DateTime, double>{};

    for (final sale in sales) {
      final date = DateTime(
          sale.createdAt.year, sale.createdAt.month, sale.createdAt.day);
      dailySales.update(
        date,
        (value) => value + sale.finalAmount,
        ifAbsent: () => sale.finalAmount,
      );
    }

    return dailySales.entries
        .map((entry) => DailySalesData(date: entry.key, amount: entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static List<HourlySalesData> _calculateTopSellingHours(List<Sale> sales) {
    final hourSales = <int, double>{};

    for (final sale in sales) {
      final hour = sale.createdAt.hour;
      hourSales.update(
        hour,
        (value) => value + sale.finalAmount,
        ifAbsent: () => sale.finalAmount,
      );
    }

    return hourSales.entries
        .map((entry) => HourlySalesData(hour: entry.key, amount: entry.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  static double _calculateCustomerRetentionRate(List<Sale> sales) {
    // Simplified retention calculation
    if (sales.isEmpty) return 0.0;

    final customerSales = <String, int>{};
    for (final sale in sales) {
      if (sale.customerId != null) {
        customerSales.update(
          sale.customerId! as String,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final repeatCustomers =
        customerSales.values.where((count) => count > 1).length;
    final totalCustomers = customerSales.length;

    return totalCustomers > 0 ? (repeatCustomers / totalCustomers) * 100 : 0.0;
  }

  static double _calculateSalesVelocity(List<Sale> sales) {
    if (sales.length < 2) return 0.0;

    final sortedSales = List<Sale>.from(sales)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final firstSale = sortedSales.first;
    final lastSale = sortedSales.last;
    final daysBetween =
        lastSale.createdAt.difference(firstSale.createdAt).inDays;

    return daysBetween > 0
        ? sales.length / daysBetween
        : sales.length.toDouble();
  }

  static Future<ProductsReportData> _generateProductsReport(
      List<Product> products, List<Sale> sales, SubscriptionPlan plan) async {
    final totalProducts = products.length;
    final lowStockCount = products.where((p) => p.isLowStock).length;
    final outOfStockCount = products.where((p) => p.isOutOfStock).length;

    final topSellingProducts =
        await _calculateTopSellingProducts(products, sales);
    final stockValue = _calculateStockValue(products);
    final profitMarginSummary = _calculateProfitMarginSummary(products, sales);

    // Advanced analytics
    final inventoryTurnover = plan.id != 'basic'
        ? _calculateInventoryTurnover(products, sales)
        : null;
    final abcAnalysis =
        plan.id == 'enterprise' ? _calculateABCAnalysis(products, sales) : null;

    return ProductsReportData(
      totalProducts: totalProducts,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      topSellingProducts: topSellingProducts,
      stockValue: stockValue,
      profitMarginSummary: profitMarginSummary,
      inventoryTurnover: inventoryTurnover,
      abcAnalysis: abcAnalysis,
    );
  }

  static Future<CustomersReportData> _generateCustomersReport(
      List<Customer> customers, List<Sale> sales, SubscriptionPlan plan) async {
    final totalCustomers = customers.length;
    final customersWithBalance =
        customers.where((c) => c.currentBalance > 0).length;
    final overdueCustomers = customers.where((c) => c.isOverdue).length;
    final totalOutstanding =
        customers.fold(0.0, (sum, c) => sum + c.currentBalance);

    final topCustomers = _calculateTopCustomers(customers, sales);
    final averageCustomerValue =
        _calculateAverageCustomerValue(customers, sales);

    return CustomersReportData(
      totalCustomers: totalCustomers,
      customersWithBalance: customersWithBalance,
      overdueCustomers: overdueCustomers,
      totalOutstanding: totalOutstanding,
      topCustomers: topCustomers,
      averageCustomerValue: averageCustomerValue,
    );
  }

  static Future<FinancialReportData> _generateFinancialReport(
      List<Sale> sales, SubscriptionPlan plan) async {
    final totalRevenue = sales.fold(0.0, (sum, sale) => sum + sale.finalAmount);
    final totalTax =
        sales.fold(0.0, (sum, sale) => sum + (sale.taxAmount ?? 0.0));
    final totalDiscount =
        sales.fold(0.0, (sum, sale) => sum + (sale.discountAmount ?? 0.0));
    final netRevenue = totalRevenue - totalTax;
    final profitMargin = _calculateProfitMargin(sales);

    return FinancialReportData(
      totalRevenue: totalRevenue,
      totalTax: totalTax,
      totalDiscount: totalDiscount,
      netRevenue: netRevenue,
      profitMargin: profitMargin,
    );
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'Mon';
    }
  }

  // Additional calculation methods...
  static Future<List<TopSellingProduct>> _calculateTopSellingProducts(
      List<Product> products, List<Sale> sales) async {
    // Implementation for top selling products
    return [];
  }

  static double _calculateStockValue(List<Product> products) {
    return products.fold(0.0, (sum, product) {
      final cost = product.costPrice ?? product.price * 0.6;
      return sum + (cost * product.stockQuantity);
    });
  }

  static double _calculateProfitMargin(List<Sale> sales) {
    if (sales.isEmpty) return 0.0;
    // Simplified profit margin calculation
    return 25.0; // Example value
  }

  static Map<String, dynamic> _calculateProfitMarginSummary(
      List<Product> products, List<Sale> sales) {
    return {};
  }

  static double? _calculateInventoryTurnover(
      List<Product> products, List<Sale> sales) {
    return null;
  }

  static Map<String, dynamic>? _calculateABCAnalysis(
      List<Product> products, List<Sale> sales) {
    return null;
  }

  static List<TopCustomer> _calculateTopCustomers(
      List<Customer> customers, List<Sale> sales) {
    return [];
  }

  static double _calculateAverageCustomerValue(
      List<Customer> customers, List<Sale> sales) {
    return 0.0;
  }
}

// Data models for reports
class ReportsData {
  final SalesReportData salesData;
  final ProductsReportData productsData;
  final CustomersReportData customersData;
  final FinancialReportData financialData;

  const ReportsData({
    required this.salesData,
    required this.productsData,
    required this.customersData,
    required this.financialData,
  });
}

class SalesReportData {
  final double totalSales;
  final int totalOrders;
  final double averageOrderValue;
  final Map<String, double> salesByPaymentMethod;
  final Map<String, double> revenueByDay;
  final List<DailySalesData> dailySalesTrend;
  final List<HourlySalesData> topSellingHours;
  final double? customerRetention;
  final double? salesVelocity;

  const SalesReportData({
    required this.totalSales,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.salesByPaymentMethod,
    required this.revenueByDay,
    required this.dailySalesTrend,
    required this.topSellingHours,
    this.customerRetention,
    this.salesVelocity,
  });
}

class ProductsReportData {
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final List<TopSellingProduct> topSellingProducts;
  final double stockValue;
  final Map<String, dynamic> profitMarginSummary;
  final double? inventoryTurnover;
  final Map<String, dynamic>? abcAnalysis;

  const ProductsReportData({
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.topSellingProducts,
    required this.stockValue,
    required this.profitMarginSummary,
    this.inventoryTurnover,
    this.abcAnalysis,
  });
}

class CustomersReportData {
  final int totalCustomers;
  final int customersWithBalance;
  final int overdueCustomers;
  final double totalOutstanding;
  final List<TopCustomer> topCustomers;
  final double averageCustomerValue;

  const CustomersReportData({
    required this.totalCustomers,
    required this.customersWithBalance,
    required this.overdueCustomers,
    required this.totalOutstanding,
    required this.topCustomers,
    required this.averageCustomerValue,
  });
}

class FinancialReportData {
  final double totalRevenue;
  final double totalTax;
  final double totalDiscount;
  final double netRevenue;
  final double profitMargin;

  const FinancialReportData({
    required this.totalRevenue,
    required this.totalTax,
    required this.totalDiscount,
    required this.netRevenue,
    required this.profitMargin,
  });
}

class DailySalesData {
  final DateTime date;
  final double amount;

  const DailySalesData({required this.date, required this.amount});
}

class HourlySalesData {
  final int hour;
  final double amount;

  const HourlySalesData({required this.hour, required this.amount});
}

class TopSellingProduct {
  final String id;
  final String name;
  final double revenue;
  final int quantitySold;
  final double profitMargin;

  const TopSellingProduct({
    required this.id,
    required this.name,
    required this.revenue,
    required this.quantitySold,
    required this.profitMargin,
  });
}

class TopCustomer {
  final String id;
  final String name;
  final double totalSpent;
  final int orderCount;
  final DateTime lastPurchase;

  const TopCustomer({
    required this.id,
    required this.name,
    required this.totalSpent,
    required this.orderCount,
    required this.lastPurchase,
  });
}
