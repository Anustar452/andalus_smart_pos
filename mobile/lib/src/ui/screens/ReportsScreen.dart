// lib/src/ui/screens/reports_screen.dart
import 'package:andalus_smart_pos/src/data/models/subscription.dart';
import 'package:andalus_smart_pos/src/utils/reports_data_calculator.dart';
import 'package:andalus_smart_pos/src/widgets/reports/advanced_product_analytics.dart';
import 'package:andalus_smart_pos/src/widgets/reports/advanced_sales_charts.dart';
import 'package:andalus_smart_pos/src/widgets/reports/customer_analytics_section.dart';
import 'package:andalus_smart_pos/src/widgets/reports/customers_overview_card.dart';
import 'package:andalus_smart_pos/src/widgets/reports/financial_ratios_section.dart';
import 'package:andalus_smart_pos/src/widgets/reports/inventory_analysis_section.dart';
import 'package:andalus_smart_pos/src/widgets/reports/outstanding_balance_chart.dart';
import 'package:andalus_smart_pos/src/widgets/reports/products_overview_card.dart';
import 'package:andalus_smart_pos/src/widgets/reports/revenue_by_day_chart.dart';
import 'package:andalus_smart_pos/src/widgets/reports/top_customers_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../controllers/reports_controller.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/common/date_range_picker.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/reports/sales_overview_card.dart';
import '../../widgets/reports/sales_trend_chart.dart';
import '../../widgets/reports/payment_method_chart.dart';
import '../../widgets/reports/top_products_chart.dart';
import '../../widgets/reports/customer_report_section.dart';
import '../../widgets/reports/financial_report_section.dart';
import '../../widgets/reports/subscription_info_card.dart';
import 'package:andalus_smart_pos/src/widgets/reports/top_products_chart.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsControllerProvider);
    final controller = ref.read(reportsControllerProvider.notifier);
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.reports),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
            tooltip: localizations.refresh,
          ),
          _buildReportTypeMenu(localizations, controller, state),
        ],
        bottom: state.currentPlan.id != 'basic'
            ? _buildTabBar(localizations, state)
            : null,
      ),
      body: state.isLoading
          ? _buildLoadingState()
          : state.error != null
              ? _buildErrorState(state.error!, controller)
              : _buildContent(state, localizations, theme),
    );
  }

  Widget _buildReportTypeMenu(AppLocalizations localizations,
      ReportsController controller, ReportsState state) {
    return PopupMenuButton<ReportType>(
      onSelected: (type) {
        controller.setReportType(type);
        _tabController.animateTo(_getTabIndex(type));
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ReportType.sales,
          child: Text(localizations.salesAnalytics),
        ),
        PopupMenuItem(
          value: ReportType.products,
          enabled: state.currentPlan.id != 'basic',
          child: Text(localizations.productsReport),
        ),
        PopupMenuItem(
          value: ReportType.customers,
          enabled: state.currentPlan.id != 'basic',
          child: Text(localizations.customersReport),
        ),
        PopupMenuItem(
          value: ReportType.financial,
          enabled: state.currentPlan.id == 'enterprise',
          child: Text(localizations.financialReport),
        ),
      ],
    );
  }

  TabBar _buildTabBar(AppLocalizations localizations, ReportsState state) {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(text: localizations.salesAnalytics),
        Tab(text: localizations.productsReport),
        Tab(text: localizations.customersReport),
        if (state.currentPlan.id == 'enterprise')
          Tab(text: localizations.financialReport),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading reports...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ReportsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Error loading reports', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refresh,
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      ReportsState state, AppLocalizations localizations, ThemeData theme) {
    return Column(
      children: [
        _buildFiltersSection(localizations, theme, state, ref),
        SubscriptionInfoCard(plan: state.currentPlan),
        Expanded(
          child: state.currentPlan.id != 'basic'
              ? _buildTabbedView(state, localizations, theme)
              : _buildBasicView(state, localizations, theme),
        ),
      ],
    );
  }

  Widget _buildFiltersSection(AppLocalizations localizations, ThemeData theme,
      ReportsState state, WidgetRef ref) {
    final controller = ref.read(reportsControllerProvider.notifier);

    return CustomCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ProfessionalDateRangePicker(
            initialDateRange: state.dateRange,
            onDateRangeSelected: controller.setDateRange,
            title: localizations.selectDateRange,
          ),
        ],
      ),
    );
  }

  Widget _buildTabbedView(
      ReportsState state, AppLocalizations localizations, ThemeData theme) {
    return TabBarView(
      controller: _tabController,
      children: [
        SalesReportSection(
            salesData: state.salesData!, plan: state.currentPlan),
        ProductsReportSection(
            productsData: state.productsData!, plan: state.currentPlan),
        CustomersReportSection(
            customersData: state.customersData!, plan: state.currentPlan),
        if (state.currentPlan.id == 'enterprise')
          FinancialReportSection(financialData: state.financialData!),
      ],
    );
  }

  Widget _buildBasicView(
      ReportsState state, AppLocalizations localizations, ThemeData theme) {
    return SalesReportSection(
        salesData: state.salesData!, plan: state.currentPlan);
  }

  int _getTabIndex(ReportType type) {
    switch (type) {
      case ReportType.sales:
        return 0;
      case ReportType.products:
        return 1;
      case ReportType.customers:
        return 2;
      case ReportType.financial:
        return 3;
    }
  }
}

// Modular report sections
class SalesReportSection extends StatelessWidget {
  final SalesReportData salesData;
  final SubscriptionPlan plan;

  const SalesReportSection({
    super.key,
    required this.salesData,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SalesOverviewCard(salesData: salesData),
        const SizedBox(height: 16),
        SalesTrendChart(dailySales: salesData.dailySalesTrend),
        const SizedBox(height: 16),
        PaymentMethodChart(paymentMethods: salesData.salesByPaymentMethod),
        if (plan.id != 'basic') ...[
          const SizedBox(height: 16),
          RevenueByDayChart(revenueByDay: salesData.revenueByDay),
        ],
        if (plan.id == 'enterprise') ...[
          const SizedBox(height: 16),
          AdvancedSalesCharts(salesData: salesData),
        ],
      ],
    );
  }
}

class ProductsReportSection extends StatelessWidget {
  final ProductsReportData productsData;
  final SubscriptionPlan plan;

  const ProductsReportSection({
    super.key,
    required this.productsData,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProductsOverviewCard(productsData: productsData),
        const SizedBox(height: 16),
        TopProductsChart(products: productsData.topSellingProducts),
        if (plan.id != 'basic') ...[
          const SizedBox(height: 16),
          InventoryAnalysisSection(productsData: productsData),
        ],
        if (plan.id == 'enterprise') ...[
          const SizedBox(height: 16),
          AdvancedProductAnalytics(productsData: productsData),
        ],
      ],
    );
  }
}

class CustomersReportSection extends StatelessWidget {
  final CustomersReportData customersData;
  final SubscriptionPlan plan;

  const CustomersReportSection({
    super.key,
    required this.customersData,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CustomersOverviewCard(customersData: customersData),
        const SizedBox(height: 16),
        TopCustomersChart(customers: customersData.topCustomers),
        const SizedBox(height: 16),
        OutstandingBalanceChart(customersData: customersData),
        if (plan.id == 'enterprise') ...[
          const SizedBox(height: 16),
          CustomerAnalyticsSection(customersData: customersData),
        ],
      ],
    );
  }
}

class FinancialReportSection extends StatelessWidget {
  final FinancialReportData financialData;

  const FinancialReportSection({super.key, required this.financialData});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FinancialKPICards(financialData: financialData),
        const SizedBox(height: 16),
        ProfitMarginTrendChart(financialData: financialData),
        const SizedBox(height: 16),
        CashFlowAnalysisChart(financialData: financialData),
        const SizedBox(height: 16),
        FinancialRatiosSection(financialData: financialData),
      ],
    );
  }
}

enum ReportType { sales, products, customers, financial }
