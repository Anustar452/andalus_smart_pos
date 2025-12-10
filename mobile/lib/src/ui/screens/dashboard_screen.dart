//lib/src
import 'package:andalus_smart_pos/src/data/models/customer.dart';
import 'package:andalus_smart_pos/src/providers/language_provider.dart';
import 'package:andalus_smart_pos/src/ui/screens/customer_management_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/product_management_screen.dart';
import 'package:andalus_smart_pos/src/utils/calendar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/repositories/sale_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/customer_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/product_repository.dart';
import 'package:andalus_smart_pos/src/data/models/sale.dart';
import 'package:andalus_smart_pos/src/data/models/product.dart';
import 'package:andalus_smart_pos/src/utils/date_utils.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
// import 'package:andalus_smart_pos/src/widgets/dashboard/stat_card.dart';
import 'package:andalus_smart_pos/src/widgets/dashboard/metric_card.dart';
import 'package:andalus_smart_pos/src/widgets/dashboard/recent_sales_list.dart';
import 'package:andalus_smart_pos/src/widgets/dashboard/stock_alert_widget.dart';
import 'package:andalus_smart_pos/src/widgets/dashboard/quick_actions_widget.dart';
// import 'package:andalus_smart_pos/src/widgets/dashboard/sales_charts.dart';
import 'package:andalus_smart_pos/src/widgets/common/loading_shimmer.dart';
// import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:andalus_smart_pos/src/widgets/dashboard/dashboard_cards.dart';
import 'package:andalus_smart_pos/src/widgets/dashboard/sales_analytics.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Future<DashboardData> _dashboardData;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _dashboardData = _loadDashboardData();
  }

  Future<DashboardData> _loadDashboardData() async {
    try {
      final saleRepository = ref.read(saleRepositoryProvider);
      final customerRepository = ref.read(customerRepositoryProvider);
      final productRepository = ref.read(productRepositoryProvider);

      // Load all data
      final salesSummary = await saleRepository.getSalesSummary();
      final creditSummary = await customerRepository.getCreditSummary();
      final todaysSales = await saleRepository.getTodaysSales();
      final lowStockProducts = await productRepository.getLowStockProducts();
      final totalProducts = await productRepository.getAllProducts();

      // Get customers for total count
      List<Customer> allCustomers = [];
      try {
        allCustomers = await customerRepository.getAllCustomers();
      } catch (e) {
        print('Error loading customers: $e');
        allCustomers = [];
      }

      // Calculate metrics
      final totalRevenue = salesSummary.totalSales;
      final averageOrderValue = salesSummary.totalOrders > 0
          ? (totalRevenue / salesSummary.totalOrders).toDouble()
          : 0.0;

      final dailyGrowth = salesSummary.weeklySales > 0
          ? ((salesSummary.todaysSales / salesSummary.weeklySales * 100) - 100)
              .toDouble()
          : 0.0;

      return DashboardData(
        salesSummary: salesSummary,
        creditSummary: creditSummary,
        todaysSales: todaysSales,
        lowStockProducts: lowStockProducts,
        totalProducts: totalProducts,
        allCustomers: allCustomers,
        totalRevenue: totalRevenue,
        averageOrderValue: averageOrderValue,
        dailyGrowth: dailyGrowth,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Error loading dashboard data: $e');
      // Return fallback data without using createSample methods
      return _createFallbackDashboardData();
    }
  }

// Add this fallback method
  DashboardData _createFallbackDashboardData() {
    return DashboardData(
      salesSummary: SalesSummary(
        todaysSales: 1250.0,
        todaysOrders: 8,
        totalSales: 12500.0,
        totalOrders: 45,
        weeklySales: 3250.0,
        weeklyOrders: 22,
      ),
      creditSummary: {
        'totalOutstanding': 2500.0,
        'overdueAmount': 750.0,
        'customersWithBalance': 3,
        'overdueCustomers': 1,
        'totalCustomers': 15,
      },
      todaysSales: [],
      lowStockProducts: [],
      totalProducts: [],
      allCustomers: [],
      totalRevenue: 12500.0,
      averageOrderValue: 277.78,
      dailyGrowth: 15.2,
      timestamp: DateTime.now(),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _dashboardData = _loadDashboardData();
      _isRefreshing = false;
    });
  }

// Add navigation methods:
  void _navigateToSalesDetails(BuildContext context) {
    // Navigate to sales details screen
    showDialog(
      context: context,
      builder: (context) => _buildSalesDetailsDialog(context),
    );
  }

  void _navigateToProducts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductManagementScreen()),
    );
  }

  void _navigateToCustomers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CustomerManagementScreen()),
    );
  }

  void _navigateToRevenueAnalytics(BuildContext context) {
    // Navigate to detailed revenue analytics
    showDialog(
      context: context,
      builder: (context) => _buildRevenueAnalyticsDialog(context),
    );
  }

// Helper methods

// Helper methods for dashboard
  int _getTotalItems(List<Product> products) {
    if (products.isEmpty) return 0;
    return products.fold(0, (sum, product) => sum + (product.stockQuantity));
  }

  int _getTotalCategories(List<Product> products) {
    if (products.isEmpty) return 0;
    final categoryIds =
        // ignore: unnecessary_null_comparison
        products.map((p) => p.categoryId).where((id) => id != null).toSet();
    return categoryIds.length;
  }

  int _getTotalCustomers(DashboardData data) {
    // Try to get from credit summary first, then fallback to actual list
    final fromSummary = data.creditSummary['totalCustomers'] as int?;
    if (fromSummary != null) return fromSummary;
    return data.allCustomers.length;
  }

  int _getCustomersWithBalance(DashboardData data) {
    return data.creditSummary['customersWithBalance'] as int? ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(localizations),
      body: FutureBuilder<DashboardData>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return DashboardShimmer(localizations: localizations);
          }

          if (snapshot.hasError) {
            return DashboardErrorWidget(
              error: snapshot.error.toString(),
              onRetry: _refreshData,
              localizations: localizations,
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator.adaptive(
            onRefresh: _refreshData,
            color: Theme.of(context).colorScheme.primary,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildLiveDateTimeWidget(context),
                ),
                // Header Stats Section
                _buildStatsSection(data, localizations),

                // Charts Section
                _buildChartsSection(data, localizations),

                // Content Section
                _buildContentSection(data, localizations),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(AppLocalizations localizations) {
    return AppBar(
      title: Text(
        localizations.dashboard,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.onBackground,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            _isRefreshing ? Icons.refresh : Icons.refresh_rounded,
            color: _isRefreshing
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: _isRefreshing ? null : _refreshData,
          tooltip: localizations.translate('refresh'),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildStatsSection(
      DashboardData data, AppLocalizations localizations) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final crossAxisCount = isTablet ? 4 : 2;

            // Use fixed height instead of aspect ratio for better control
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0, // Square cards
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 130, // Fixed height matching card height
                  child: SalesCard(
                    todaySales: data.salesSummary.todaysSales,
                    itemsSold: data.salesSummary.todaysOrders,
                    onTap: () => _navigateToSalesDetails(context),
                  ),
                ),
                SizedBox(
                  height: 130,
                  child: ProductsCard(
                    totalProducts: data.totalProducts.length,
                    totalItems: _getTotalItems(data.totalProducts),
                    totalCategories: _getTotalCategories(data.totalProducts),
                    onTap: () => _navigateToProducts(context),
                  ),
                ),
                SizedBox(
                  height: 130,
                  child: CustomersCard(
                    totalCustomers: _getTotalCustomers(data),
                    customersWithBalance: _getCustomersWithBalance(data),
                    onTap: () => _navigateToCustomers(context),
                  ),
                ),
                SizedBox(
                  height: 130,
                  child: RevenueCard(
                    totalRevenue: data.totalRevenue,
                    outstandingCredit:
                        data.creditSummary['totalOutstanding'] as double? ??
                            0.0,
                    onTap: () => _navigateToRevenueAnalytics(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildChartsSection(
      DashboardData data, AppLocalizations localizations) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12), // Reduced padding
        child: SalesAnalyticsWidget(
          salesData: data.salesSummary,
          localizations: localizations,
        ),
      ),
    );
  }

  Widget _buildContentSection(
      DashboardData data, AppLocalizations localizations) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            _buildInsightsSection(data, localizations), // Add this line
            const SizedBox(height: 20),
            _buildPerformanceOverview(data, localizations),
            const SizedBox(height: 20),
            RecentSalesList(
              sales: data.todaysSales,
              localizations: localizations,
            ),
            const SizedBox(height: 20),
            StockAlertWidget(
              products: data.lowStockProducts,
              localizations: localizations,
            ),
            const SizedBox(height: 20),
            QuickActionsWidget(localizations: localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesDetailsDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Today\'s Sales Details'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            // Add sales details content here
            const ListTile(
              leading: Icon(Icons.shopping_cart, color: Color(0xFF10B981)),
              title: Text('Total Sales'),
              subtitle: Text('ETB 12,500.00'),
            ),
            // Add more sales details...
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

// Revenue Analytics Dialog
  Widget _buildRevenueAnalyticsDialog(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            const Text(
              'Revenue Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SalesAnalyticsWidget(
                salesData: SalesSummary(
                  todaysSales: 12500,
                  todaysOrders: 45,
                  totalSales: 125000,
                  totalOrders: 450,
                  weeklySales: 32500,
                  weeklyOrders: 120,
                ),
                localizations: AppLocalizations.of(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveDateTimeWidget(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final calendarType = ref.watch(calendarProvider);
        final locale = ref.watch(languageProvider);
        final currentTime = DateTime.now();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              // In your dashboard_screen.dart, update this section:
              // In your dashboard_screen.dart, update this section:
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      calendarType == CalendarType.ethiopian
                          ? 'የኢትዮጵያ ቀን ቆጠራ'
                          : 'Ethiopian Calendar',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppDateUtils.getCurrentFullDate(
                          context, ref), // Add ref parameter
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('HH:mm:ss').format(currentTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontFamily: 'RobotoMono',
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  calendarType == CalendarType.ethiopian ? 'ETH' : 'GREG',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(
      DashboardData data, AppLocalizations localizations) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Content - 70%
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildPerformanceOverview(data, localizations),
              const SizedBox(height: 20),
              RecentSalesList(
                sales: data.todaysSales,
                localizations: localizations,
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Sidebar - 30%
        Expanded(
          flex: 3,
          child: Column(
            children: [
              StockAlertWidget(
                products: data.lowStockProducts,
                localizations: localizations,
              ),
              const SizedBox(height: 20),
              QuickActionsWidget(localizations: localizations),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      DashboardData data, AppLocalizations localizations) {
    return Column(
      children: [
        _buildPerformanceOverview(data, localizations),
        const SizedBox(height: 20),
        RecentSalesList(
          sales: data.todaysSales,
          localizations: localizations,
        ),
        const SizedBox(height: 20),
        StockAlertWidget(
          products: data.lowStockProducts,
          localizations: localizations,
        ),
        const SizedBox(height: 20),
        QuickActionsWidget(localizations: localizations),
      ],
    );
  }

  Widget _buildPerformanceOverview(
      DashboardData data, AppLocalizations localizations) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.translate('performanceOverview'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 400;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 3.5 : 2.5,
                  children: [
                    MetricCard(
                      label: localizations.averageOrderValue,
                      value:
                          AppFormatters.formatCurrency(data.averageOrderValue),
                      icon: Icons.shopping_cart_rounded,
                      localizations: localizations,
                    ),
                    MetricCard(
                      label: localizations.totalOrders,
                      value: data.salesSummary.totalOrders.toString(),
                      icon: Icons.receipt_long_rounded,
                      localizations: localizations,
                    ),
                    MetricCard(
                      label: localizations.translate('customersWithBalance'),
                      value: (data.creditSummary['customersWithBalance'] ?? 0)
                          .toString(),
                      icon: Icons.people_alt_rounded,
                      localizations: localizations,
                    ),
                    MetricCard(
                      label: localizations.translate('overdueAmount'),
                      value: AppFormatters.formatCurrency(
                          data.creditSummary['overdueAmount'] ?? 0),
                      icon: Icons.warning_amber_rounded,
                      isWarning: (data.creditSummary['overdueAmount'] ?? 0) > 0,
                      localizations: localizations,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(
      DashboardData data, AppLocalizations localizations) {
    return PerformanceInsightsWidget(
      data: data,
      localizations: localizations,
    );
  }
}

// Dashboard Data Model
// In your dashboard_screen.dart - update DashboardData
class DashboardData {
  final SalesSummary salesSummary;
  final Map<String, dynamic> creditSummary;
  final List<Sale> todaysSales;
  final List<Product> lowStockProducts;
  final List<Product> totalProducts;
  final List<Customer> allCustomers;
  final double totalRevenue;
  final double averageOrderValue;
  final double dailyGrowth;
  final DateTime timestamp;

  DashboardData({
    required this.salesSummary,
    required this.creditSummary,
    required this.todaysSales,
    required this.lowStockProducts,
    required this.totalProducts,
    required this.allCustomers,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.dailyGrowth,
    required this.timestamp,
  });
}

class DashboardErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final AppLocalizations localizations;

  const DashboardErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('errorLoadingData'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                error.contains('DatabaseException')
                    ? localizations.translate('databaseNeedsUpdate')
                    : error.length > 100
                        ? '${error.substring(0, 100)}...'
                        : error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(localizations.translate('tryAgain')),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardShimmer extends StatelessWidget {
  final AppLocalizations localizations;

  const DashboardShimmer({
    super.key,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: List.generate(
                  4,
                  (index) => const LoadingShimmer(
                        height: 100,
                        borderRadius: 16,
                      )),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: LoadingShimmer(height: 200, borderRadius: 20),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const LoadingShimmer(height: 180, borderRadius: 20),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: LoadingShimmer(height: 300, borderRadius: 20),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          LoadingShimmer(height: 140, borderRadius: 20),
                          SizedBox(height: 20),
                          LoadingShimmer(height: 120, borderRadius: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
// Add these new widgets to your dashboard_screen.dart

class PerformanceInsightsWidget extends StatelessWidget {
  final DashboardData data;
  final AppLocalizations localizations;

  const PerformanceInsightsWidget({
    super.key,
    required this.data,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights(data);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Performance Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...insights.map((insight) => _buildInsightItem(context, insight)),
          ],
        ),
      ),
    );
  }

  List<DashboardInsight> _generateInsights(DashboardData data) {
    final insights = <DashboardInsight>[];

    // Sales performance insights
    if (data.salesSummary.todaysSales >
        data.salesSummary.weeklySales / 7 * 1.2) {
      insights.add(DashboardInsight(
        type: InsightType.positive,
        title: 'Strong Sales Today',
        message: 'Today\'s sales are 20% above daily average',
        icon: Icons.trending_up_rounded,
      ));
    }

    if (data.lowStockProducts.isNotEmpty) {
      insights.add(DashboardInsight(
        type: InsightType.warning,
        title: 'Low Stock Alert',
        message: '${data.lowStockProducts.length} products need restocking',
        icon: Icons.inventory_2_rounded,
      ));
    }

    // Credit risk insights
    final overdueAmount = data.creditSummary['overdueAmount'] as double? ?? 0.0;
    if (overdueAmount > 1000) {
      insights.add(DashboardInsight(
        type: InsightType.negative,
        title: 'High Overdue Amount',
        message: 'ETB ${overdueAmount.toStringAsFixed(0)} in overdue payments',
        icon: Icons.warning_amber_rounded,
      ));
    }

    // Customer growth insights
    final newCustomers = _getNewCustomersCount(data);
    if (newCustomers > 5) {
      insights.add(DashboardInsight(
        type: InsightType.positive,
        title: 'Customer Growth',
        message: '$newCustomers new customers this week',
        icon: Icons.people_alt_rounded,
      ));
    }

    return insights;
  }

  int _getNewCustomersCount(DashboardData data) {
    // Calculate new customers from the last 7 days
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return data.allCustomers
        .where((customer) => customer.createdAt.isAfter(weekAgo))
        .length;
  }

  Widget _buildInsightItem(BuildContext context, DashboardInsight insight) {
    Color backgroundColor;
    Color textColor;

    switch (insight.type) {
      case InsightType.positive:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        break;
      case InsightType.warning:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        break;
      case InsightType.negative:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(insight.icon, color: textColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardInsight {
  final InsightType type;
  final String title;
  final String message;
  final IconData icon;

  const DashboardInsight({
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
  });
}

enum InsightType {
  positive,
  warning,
  negative,
}
