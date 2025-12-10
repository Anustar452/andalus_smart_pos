// lib/src/widgets/dashboard/enhanced_dashboard.dart - SIMPLIFIED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/app_localizations.dart';
import '../../controllers/sale_controller.dart';

class EnhancedDashboard extends ConsumerStatefulWidget {
  const EnhancedDashboard({super.key});

  @override
  ConsumerState<EnhancedDashboard> createState() => _EnhancedDashboardState();
}

class _EnhancedDashboardState extends ConsumerState<EnhancedDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final salesState = ref.watch(saleControllerProvider);
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(localizations.dashboard),
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {},
                  tooltip: localizations.refresh,
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: localizations.translate('overview')),
                  Tab(text: localizations.salesAnalytics),
                  Tab(text: localizations.translate('performance')),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(salesState, localizations, theme),
            _buildAnalyticsTab(localizations, theme),
            _buildPerformanceTab(localizations, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
      SaleState salesState, AppLocalizations localizations, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  title: localizations.todayRevenue,
                  value: 'ETB ${salesState.total.toStringAsFixed(2)}',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  context: context,
                ),
                _buildStatCard(
                  title: localizations.todayOrders,
                  value: salesState.cartItems.length
                      .toString(), // FIXED: Use cartItems.length
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                  context: context,
                ),
                _buildStatCard(
                  title: 'Products',
                  value: '125',
                  icon: Icons.inventory,
                  color: Colors.orange,
                  context: context,
                ),
                _buildStatCard(
                  title: 'Customers',
                  value: '45',
                  icon: Icons.people,
                  color: Colors.purple,
                  context: context,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab(AppLocalizations localizations, ThemeData theme) {
    return Center(
      child: Text(
        'Sales Analytics - Coming Soon',
        style: theme.textTheme.titleLarge,
      ),
    );
  }

  Widget _buildPerformanceTab(AppLocalizations localizations, ThemeData theme) {
    return Center(
      child: Text(
        'Performance Metrics - Coming Soon',
        style: theme.textTheme.titleLarge,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Remove or comment out the SalesData class if not needed
