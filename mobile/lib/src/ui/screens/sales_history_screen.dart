import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/repositories/sale_repository.dart';
import 'package:andalus_smart_pos/src/data/models/sale.dart';
import 'package:andalus_smart_pos/src/widgets/common/custom_card.dart';
import 'package:andalus_smart_pos/src/widgets/common/loading_shimmer.dart';
import 'package:andalus_smart_pos/src/utils/date_utils.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';

class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
  List<Sale> _sales = [];
  bool _isLoading = true;
  String _filter = 'today'; // 'today', 'week', 'month', 'all'
  DateTimeRange? _selectedDateRange;
  SaleWithItems? _selectedSale;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _isLoading = true);

    try {
      final saleRepository = ref.read(saleRepositoryProvider);
      List<Sale> sales;

      final now = DateTime.now();
      switch (_filter) {
        case 'today':
          sales = await saleRepository.getTodaysSales();
          break;
        case 'week':
          final weekAgo = now.subtract(const Duration(days: 7));
          final allSales = await saleRepository.getAllSales();
          sales = allSales
              .where((sale) => sale.createdAt.isAfter(weekAgo))
              .toList();
          break;
        case 'month':
          final monthAgo = DateTime(now.year, now.month - 1, now.day);
          final allSales = await saleRepository.getAllSales();
          sales = allSales
              .where((sale) => sale.createdAt.isAfter(monthAgo))
              .toList();
          break;
        case 'custom':
          if (_selectedDateRange != null) {
            final allSales = await saleRepository.getAllSales();
            sales = allSales
                .where((sale) =>
                    sale.createdAt.isAfter(_selectedDateRange!.start) &&
                    sale.createdAt.isBefore(_selectedDateRange!.end))
                .toList();
          } else {
            sales = await saleRepository.getAllSales();
          }
          break;
        default:
          sales = await saleRepository.getAllSales();
      }

      // Sort by date (newest first)
      sales.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _sales = sales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sales: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSaleDetails(int saleId) async {
    try {
      final saleRepository = ref.read(saleRepositoryProvider);
      final saleWithItems = await saleRepository.getSaleById(saleId);

      setState(() => _selectedSale = saleWithItems);
      _showSaleDetailsDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sale details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSaleDetailsDialog() {
    if (_selectedSale == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _buildSaleDetailsContent(),
      ),
    );
  }

  Widget _buildSaleDetailsContent() {
    final sale = _selectedSale!.sale;
    final items = _selectedSale!.items;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.receipt_long,
                  color: Color(0xFF10B981), size: 24),
              const SizedBox(width: 12),
              Text(
                'Sale #${sale.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sale Information
          CustomCard(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow('Date',
                    '${AppDateUtils.formatDate(sale.createdAt)} ${AppDateUtils.formatTime(sale.createdAt)}'),
                _buildDetailRow(
                    'Payment Method', _formatPaymentMethod(sale.paymentMethod)),
                _buildDetailRow('Status', _formatStatus(sale.paymentStatus)),
                if (sale.taxAmount > 0)
                  _buildDetailRow('Tax Amount',
                      AppFormatters.formatCurrency(sale.taxAmount)),
                if (sale.discountAmount > 0)
                  _buildDetailRow('Discount',
                      AppFormatters.formatCurrency(sale.discountAmount)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Items Header
          const Text(
            'Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Items List
          CustomCard(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.productName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'x${item.quantity}',
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              AppFormatters.formatCurrency(item.unitPrice),
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              AppFormatters.formatCurrency(item.totalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL AMOUNT:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  AppFormatters.formatCurrency(sale.finalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'telebirr':
        return 'Telebirr';
      case 'card':
        return 'Card';
      case 'credit':
        return 'Credit';
      default:
        return method.toUpperCase();
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  void _changeFilter(String newFilter) {
    setState(() => _filter = newFilter);
    _loadSales();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      currentDate: DateTime.now(),
      saveText: 'Apply',
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _filter = 'custom';
      });
      _loadSales();
    }
  }

  // Analytics calculations
  double get _totalSalesAmount =>
      _sales.fold(0, (sum, sale) => sum + sale.finalAmount);
  int get _totalOrders => _sales.length;
  double get _averageOrderValue =>
      _totalOrders > 0 ? _totalSalesAmount / _totalOrders : 0;

  Map<String, double> get _paymentMethodBreakdown {
    final breakdown = <String, double>{};
    for (final sale in _sales) {
      breakdown.update(
        sale.paymentMethod,
        (value) => value + sale.finalAmount,
        ifAbsent: () => sale.finalAmount,
      );
    }
    return breakdown;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSales,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // Analytics Summary
          if (_sales.isNotEmpty) _buildAnalyticsSummary(),

          // Sales List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _sales.isEmpty
                    ? _buildEmptyState()
                    : _buildSalesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return CustomCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Today', 'today'),
                const SizedBox(width: 8),
                _buildFilterChip('This Week', 'week'),
                const SizedBox(width: 8),
                _buildFilterChip('This Month', 'month'),
                const SizedBox(width: 8),
                _buildFilterChip('All Time', 'all'),
                const SizedBox(width: 8),
                _buildDateRangeChip(),
              ],
            ),
          ),

          // Selected Date Range
          if (_filter == 'custom' && _selectedDateRange != null) ...[
            const SizedBox(height: 12),
            Text(
              '${AppDateUtils.formatDate(_selectedDateRange!.start)} - ${AppDateUtils.formatDate(_selectedDateRange!.end)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _changeFilter(value),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF10B981),
      side: BorderSide(
        color: const Color(0xFF10B981).withOpacity(isSelected ? 0.2 : 0.3),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF10B981),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDateRangeChip() {
    final isSelected = _filter == 'custom';
    return FilterChip(
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 16),
          SizedBox(width: 4),
          Text('Custom Range'),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => _selectDateRange(),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF10B981),
      side: BorderSide(
        color: const Color(0xFF10B981).withOpacity(isSelected ? 0.2 : 0.3),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF10B981),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildAnalyticsSummary() {
    return CustomCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnalyticsItem(
                'Total Sales',
                AppFormatters.formatCurrency(_totalSalesAmount),
                Icons.attach_money,
              ),
              _buildAnalyticsItem(
                'Total Orders',
                _totalOrders.toString(),
                Icons.receipt_long,
              ),
              _buildAnalyticsItem(
                'Avg. Order',
                AppFormatters.formatCurrency(_averageOrderValue),
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Payment Methods Breakdown
          if (_paymentMethodBreakdown.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Payment Methods',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _paymentMethodBreakdown.entries.map((entry) {
                final percentage = (entry.value / _totalSalesAmount * 100);
                return Chip(
                  label: Text(
                    '${_formatPaymentMethod(entry.key)}: ${percentage.toStringAsFixed(1)}%',
                  ),
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF10B981), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LoadingShimmer(height: 100, borderRadius: 12),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No sales found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(),
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.point_of_sale),
            label: const Text('Start Selling'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (_filter) {
      case 'today':
        return 'No sales made today yet.\nComplete your first sale to see it here!';
      case 'week':
        return 'No sales in the last 7 days.';
      case 'month':
        return 'No sales this month.';
      case 'custom':
        return 'No sales found in the selected date range.';
      default:
        return 'No sales recorded yet.\nComplete your first sale to see it here!';
    }
  }

  Widget _buildSalesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sales.length,
      itemBuilder: (context, index) {
        final sale = _sales[index];
        return _buildSaleCard(sale);
      },
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return CustomCard(
      onTap: () => _loadSaleDetails(sale.id!),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Sale #${sale.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentMethodColor(sale.paymentMethod),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatPaymentMethod(sale.paymentMethod),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details
          Row(
            children: [
              // Date and Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.formatDate(sale.createdAt),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.formatTime(sale.createdAt),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.formatCurrency(sale.finalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap for details',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Sync Status
          if (!sale.isSynced) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.sync, size: 14, color: Colors.orange.shade600),
                const SizedBox(width: 4),
                Text(
                  'Pending sync',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
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
}
