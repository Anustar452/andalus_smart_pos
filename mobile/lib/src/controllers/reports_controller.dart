// lib/src/controllers/reports_controller.dart
// Controller for managing reports-related state and actions.
import 'package:andalus_smart_pos/src/ui/screens/ReportsScreen.dart';
import 'package:andalus_smart_pos/src/utils/reports_data_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../data/models/subscription.dart';
import '../data/models/sale.dart';
import '../data/models/product.dart';
import '../data/models/customer.dart';
import '../data/repositories/sale_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/subscription_repository.dart';
import '../utils/formatters.dart';

final reportsControllerProvider =
    StateNotifierProvider.autoDispose<ReportsController, ReportsState>((ref) {
  return ReportsController(ref);
});

class ReportsState {
  final bool isLoading;
  final SubscriptionPlan currentPlan;
  final ReportType selectedReportType;
  final DateTimeRange dateRange;
  final SalesReportData? salesData;
  final ProductsReportData? productsData;
  final CustomersReportData? customersData;
  final FinancialReportData? financialData;
  final String? error;

  const ReportsState({
    this.isLoading = true,
    required this.currentPlan,
    this.selectedReportType = ReportType.sales,
    required this.dateRange,
    this.salesData,
    this.productsData,
    this.customersData,
    this.financialData,
    this.error,
  });

  ReportsState copyWith({
    bool? isLoading,
    SubscriptionPlan? currentPlan,
    ReportType? selectedReportType,
    DateTimeRange? dateRange,
    SalesReportData? salesData,
    ProductsReportData? productsData,
    CustomersReportData? customersData,
    FinancialReportData? financialData,
    String? error,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      currentPlan: currentPlan ?? this.currentPlan,
      selectedReportType: selectedReportType ?? this.selectedReportType,
      dateRange: dateRange ?? this.dateRange,
      salesData: salesData ?? this.salesData,
      productsData: productsData ?? this.productsData,
      customersData: customersData ?? this.customersData,
      financialData: financialData ?? this.financialData,
      error: error ?? this.error,
    );
  }
}

class ReportsController extends StateNotifier<ReportsState> {
  final Ref ref;

  ReportsController(this.ref)
      : super(
          ReportsState(
            currentPlan: SubscriptionPlan.basic,
            dateRange: DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 30)),
              end: DateTime.now(),
            ),
          ),
        ) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSubscription();
    await _loadReports();
  }

  Future<void> _loadSubscription() async {
    try {
      final subscription = await ref
          .read(subscriptionRepositoryProvider)
          .getCurrentSubscription();
      final currentPlan = subscription?.plan ?? SubscriptionPlan.basic;
      state = state.copyWith(currentPlan: currentPlan);
    } catch (e) {
      state = state.copyWith(currentPlan: SubscriptionPlan.basic);
    }
  }

  Future<void> _loadReports() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reportsData = await ReportsDataCalculator.generateReports(
        ref: ref,
        dateRange: state.dateRange,
        plan: state.currentPlan,
      );

      state = state.copyWith(
        isLoading: false,
        salesData: reportsData.salesData,
        productsData: reportsData.productsData,
        customersData: reportsData.customersData,
        financialData: reportsData.financialData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load reports: $e',
      );
    }
  }

  void setDateRange(DateTimeRange range) {
    state = state.copyWith(dateRange: range);
    _loadReports();
  }

  void setReportType(ReportType type) {
    state = state.copyWith(selectedReportType: type);
  }

  void refresh() => _loadReports();
}
