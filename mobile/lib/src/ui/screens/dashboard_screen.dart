import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/repositories/sale_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/customer_repository.dart';
import 'package:andalus_smart_pos/src/data/repositories/product_repository.dart';
import 'package:andalus_smart_pos/src/data/models/sale.dart';
import 'package:andalus_smart_pos/src/data/models/product.dart';
import 'package:andalus_smart_pos/src/widgets/common/custom_card.dart';
import 'package:andalus_smart_pos/src/widgets/common/stat_card.dart';
import 'package:andalus_smart_pos/src/widgets/common/loading_shimmer.dart';
import 'package:andalus_smart_pos/src/utils/date_utils.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';

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

      final salesSummary = await saleRepository.getSalesSummary();
      final creditSummary = await customerRepository.getCreditSummary();
      final todaysSales = await saleRepository.getTodaysSales();
      final lowStockProducts = await productRepository.getLowStockProducts();
      final totalProducts = await productRepository.getAllProducts();

      // Calculate metrics with explicit type conversion
      final totalRevenue = salesSummary.totalSales;
      final averageOrderValue = salesSummary.totalOrders > 0
          ? (totalRevenue / salesSummary.totalOrders).toDouble()
          : 0.0;

      // Calculate growth percentages with explicit type conversion
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
        totalRevenue: totalRevenue,
        averageOrderValue: averageOrderValue,
        dailyGrowth: dailyGrowth,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // If there's an error, create sample data for demonstration
      return DashboardData.createSample();
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
    setState(() {
      _dashboardData = _loadDashboardData();
      _isRefreshing = false;
    });
  }

  Future<void> _createSampleData() async {
    try {
      final saleRepository = ref.read(saleRepositoryProvider);
      // Check if the method exists before calling it
      if (_isMethodAvailable(saleRepository, 'createSampleSales')) {
        await saleRepository.createSampleSales();
      }
      _refreshData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample data created successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating sample data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isMethodAvailable(dynamic object, String methodName) {
    try {
      return object.runtimeType.toString().contains(methodName) ||
          (object is SaleRepository && methodName == 'createSampleSales');
    } catch (e) {
      return false;
    }
  }

  void _navigateToPOS() {
    Navigator.pushNamed(context, '/pos');
  }

  void _navigateToProducts() {
    Navigator.pushNamed(context, '/products');
  }

  void _navigateToCustomers() {
    Navigator.pushNamed(context, '/customers');
  }

  void _navigateToReports() {
    Navigator.pushNamed(context, '/reports');
  }
  // void _navigateToReports() {
  // Navigate to Reports screen
  // Navigator.push(context, MaterialPageRoute(builder: (context) => ReportsScreen()));
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isRefreshing ? Icons.refresh : Icons.refresh_outlined,
              color: _isRefreshing ? Colors.grey : const Color(0xFF10B981),
            ),
            onPressed: _isRefreshing ? null : _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<DashboardData>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const DashboardShimmer();
          }

          if (snapshot.hasError) {
            return DashboardErrorWidget(
              error: snapshot.error.toString(),
              onRetry: _refreshData,
              onCreateSample: _createSampleData,
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFF10B981),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quick Stats Grid - Responsive
                  _buildQuickStats(data, isSmallScreen),
                  const SizedBox(height: 20),

                  // Performance Overview
                  _buildPerformanceOverview(data),
                  const SizedBox(height: 20),

                  // Recent Activity & Side Panels
                  isSmallScreen
                      ? _buildMobileLayout(data)
                      : _buildDesktopLayout(data),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(DashboardData data, bool isSmallScreen) {
    final crossAxisCount = isSmallScreen ? 2 : 4;
    final childAspectRatio = isSmallScreen ? 1.3 : 1.1;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: childAspectRatio,
      children: [
        _buildStatItem(
          'Today\'s Revenue',
          AppFormatters.formatCurrency(data.salesSummary.todaysSales),
          Icons.attach_money_rounded,
          const Color(0xFF10B981),
          trend: data.dailyGrowth > 0
              ? 1
              : data.dailyGrowth < 0
                  ? -1
                  : 0,
          subtitle: '${data.salesSummary.todaysOrders} orders',
        ),
        _buildStatItem(
          'Weekly Sales',
          AppFormatters.formatCurrency(data.salesSummary.weeklySales),
          Icons.trending_up_rounded,
          const Color(0xFF3B82F6),
          subtitle: '${data.salesSummary.weeklyOrders} orders',
        ),
        _buildStatItem(
          'Total Revenue',
          AppFormatters.formatCompactCurrency(data.totalRevenue),
          Icons.bar_chart_rounded,
          const Color(0xFF8B5CF6),
        ),
        _buildStatItem(
          'Outstanding',
          AppFormatters.formatCurrency(
              data.creditSummary['totalOutstanding'] ?? 0),
          Icons.credit_card_rounded,
          const Color(0xFFF59E0B),
          isWarning: (data.creditSummary['overdueAmount'] ?? 0) > 0,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color, {
    int? trend,
    String? subtitle,
    bool isWarning = false,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (trend != null) ...[
                Icon(
                  trend > 0 ? Icons.trending_up : Icons.trending_down,
                  color: trend > 0 ? Colors.green : Colors.red,
                  size: 16,
                ),
              ],
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview(DashboardData data) {
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_rounded,
                    color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Performance Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3,
            children: [
              _buildMetricItem(
                'Average Order Value',
                AppFormatters.formatCurrency(data.averageOrderValue),
                Icons.shopping_cart_rounded,
              ),
              _buildMetricItem(
                'Total Orders',
                data.salesSummary.totalOrders.toString(),
                Icons.receipt_long_rounded,
              ),
              _buildMetricItem(
                'Customers with Balance',
                (data.creditSummary['customersWithBalance'] ?? 0).toString(),
                Icons.people_alt_rounded,
              ),
              _buildMetricItem(
                'Overdue Amount',
                AppFormatters.formatCurrency(
                    data.creditSummary['overdueAmount'] ?? 0),
                Icons.warning_amber_rounded,
                isWarning: (data.creditSummary['overdueAmount'] ?? 0) > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon, {
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: isWarning
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color:
                  isWarning ? const Color(0xFFEF4444) : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(DashboardData data) {
    return Column(
      children: [
        _buildRecentSales(data.todaysSales),
        const SizedBox(height: 16),
        _buildLowStockAlert(data.lowStockProducts),
        const SizedBox(height: 16),
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildDesktopLayout(DashboardData data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildRecentSales(data.todaysSales),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildLowStockAlert(data.lowStockProducts),
              const SizedBox(height: 16),
              _buildQuickActions(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSales(List<Sale> sales) {
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recent Sales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sales.isEmpty)
            _buildEmptySalesState()
          else
            Column(
              children:
                  sales.take(5).map((sale) => _buildSaleItem(sale)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSaleItem(Sale sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  _getPaymentMethodColor(sale.paymentMethod).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getPaymentMethodIcon(sale.paymentMethod),
              color: _getPaymentMethodColor(sale.paymentMethod),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sale #${sale.id ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppDateUtils.formatTime(sale.createdAt)} • ${_formatPaymentMethod(sale.paymentMethod)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                sale.formattedTotal,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF10B981),
                ),
              ),
              Text(
                AppDateUtils.formatDate(sale.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert(List<Product> lowStockProducts) {
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Low Stock Alert',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (lowStockProducts.isEmpty)
            Text(
              'All products are well stocked',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            )
          else
            Column(
              children: lowStockProducts
                  .take(3)
                  .map((product) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${product.stockQuantity} left',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          if (lowStockProducts.length > 3) ...[
            const SizedBox(height: 8),
            Text(
              '+${lowStockProducts.length - 3} more',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionChip(Icons.point_of_sale, 'New Sale', _navigateToPOS),
              _buildActionChip(
                  Icons.inventory_2, 'Add Product', _navigateToProducts),
              _buildActionChip(
                  Icons.people, 'Add Customer', _navigateToCustomers),
              _buildActionChip(Icons.bar_chart, 'Reports', _navigateToReports),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: onTap,
      backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
      labelStyle: const TextStyle(color: Color(0xFF10B981)),
    );
  }

  Widget _buildEmptySalesState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.receipt_long_outlined,
            size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(
          'No sales today',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete your first sale to see it here!',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _navigateToPOS,
          icon: const Icon(Icons.point_of_sale, size: 16),
          label: const Text('Start Selling'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return const Color(0xFF10B981);
      case 'telebirr':
        return const Color(0xFF3B82F6);
      case 'card':
        return const Color(0xFF8B5CF6);
      case 'credit':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'telebirr':
        return Icons.qr_code;
      case 'card':
        return Icons.credit_card;
      case 'credit':
        return Icons.credit_score;
      default:
        return Icons.payment;
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'telebirr':
        return 'Telebirr';
      case 'card':
        return 'Card';
      case 'credit':
        return 'Credit';
      default:
        return method;
    }
  }
}

// Dashboard Data Model
class DashboardData {
  final SalesSummary salesSummary;
  final Map<String, dynamic> creditSummary;
  final List<Sale> todaysSales;
  final List<Product> lowStockProducts;
  final List<Product> totalProducts;
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
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.dailyGrowth,
    required this.timestamp,
  });

  factory DashboardData.createSample() {
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
      todaysSales: List.generate(3, (index) => Sale.createSample()),
      lowStockProducts: [],
      totalProducts: [],
      totalRevenue: 12500.0,
      averageOrderValue: 277.78,
      dailyGrowth: 15.2,
      timestamp: DateTime.now(),
    );
  }
}

class DashboardErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onCreateSample;

  const DashboardErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onCreateSample,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Unable to load dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                error.contains('DatabaseException')
                    ? 'Database schema needs update. You can create sample data to explore the dashboard.'
                    : error.length > 100
                        ? '${error.substring(0, 100)}...'
                        : error,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onCreateSample,
                  icon: const Icon(Icons.data_exploration_rounded),
                  label: const Text('Use Sample Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Grid Shimmer
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: List.generate(
                4,
                (index) => const LoadingShimmer(
                      height: 100,
                      borderRadius: 12,
                    )),
          ),
          const SizedBox(height: 20),
          // Performance Overview Shimmer
          const LoadingShimmer(height: 200, borderRadius: 16),
          const SizedBox(height: 20),
          // Content Area Shimmer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 2,
                child: LoadingShimmer(height: 300, borderRadius: 16),
              ),
              const SizedBox(width: 16),
              const Expanded(
                flex: 1,
                child: Column(
                  children: [
                    LoadingShimmer(height: 140, borderRadius: 16),
                    SizedBox(height: 16),
                    LoadingShimmer(height: 140, borderRadius: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
