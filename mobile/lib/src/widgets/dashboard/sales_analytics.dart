// widgets/dashboard/sales_analytics.dart
// A sales analytics widget displaying sales data with charts and statistics on the dashboard.
import 'package:andalus_smart_pos/src/data/repositories/sale_repository.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/utils/formatters.dart';

class SalesAnalyticsWidget extends ConsumerStatefulWidget {
  final SalesSummary salesData;
  final AppLocalizations localizations;

  const SalesAnalyticsWidget({
    super.key,
    required this.salesData,
    required this.localizations,
  });

  @override
  ConsumerState<SalesAnalyticsWidget> createState() =>
      _SalesAnalyticsWidgetState();
}

class _SalesAnalyticsWidgetState extends ConsumerState<SalesAnalyticsWidget> {
  int _selectedChartIndex = 0;
  final List<String> _chartTypes = ['daily', 'weekly', 'monthly'];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Smaller radius
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16), // Reduced padding
        constraints: const BoxConstraints(
          minHeight: 320, // Fixed minimum height
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - More compact
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // Smaller
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20, // Smaller icon
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.localizations.translate('salesAnalytics'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Chart Type Selector - More compact
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedChartIndex,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                    items: _chartTypes.asMap().entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(
                          _getChartTypeName(entry.value),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedChartIndex = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Chart - Fixed height
            SizedBox(
              height: 160, // Reduced height
              child: _buildSalesChart(),
            ),
            const SizedBox(height: 12),

            // Statistics - More compact
            _buildStatistics(),
          ],
        ),
      ),
    );
  }

  String _getChartTypeName(String type) {
    switch (type) {
      case 'daily':
        return widget.localizations.translate('today');
      case 'weekly':
        return widget.localizations.translate('weeklySales');
      case 'monthly':
        return widget.localizations.translate('thisMonth');
      default:
        return type;
    }
  }

  Widget _buildSalesChart() {
    final chartData = _getChartData();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false, // Remove vertical lines for cleaner look
          horizontalInterval: _getHorizontalInterval(chartData),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20, // Smaller reserved size
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= chartData.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _getBottomTitle(value.toInt(), chartData.length),
                    style: TextStyle(
                      fontSize: 9, // Smaller font
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getHorizontalInterval(chartData),
              reservedSize: 32, // Smaller reserved size
              getTitlesWidget: (value, meta) {
                return Text(
                  AppFormatters.formatCompactCurrency(value),
                  style: TextStyle(
                    fontSize: 9, // Smaller font
                    color: Theme.of(context).colorScheme.outline,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false, // Remove border for cleaner look
        ),
        minX: 0,
        maxX: chartData.length > 0 ? (chartData.length - 1).toDouble() : 0,
        minY: 0,
        maxY: chartData.isNotEmpty
            ? chartData.reduce((a, b) => a > b ? a : b) * 1.1
            : 1000,
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 2, // Thinner line
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.05), // Lighter fill
            ),
          ),
        ],
      ),
    );
  }

  List<double> _getChartData() {
    switch (_chartTypes[_selectedChartIndex]) {
      case 'daily':
        // Simulate hourly data for today - smaller values
        return [
          300,
          500,
          800,
          600,
          900,
          1200,
          1000,
          1400,
          1600,
          1800,
          2000,
          2200
        ];
      case 'weekly':
        // Last 7 days data - smaller values
        return [
          widget.salesData.weeklySales * 0.08,
          widget.salesData.weeklySales * 0.12,
          widget.salesData.weeklySales * 0.15,
          widget.salesData.weeklySales * 0.20,
          widget.salesData.weeklySales * 0.18,
          widget.salesData.weeklySales * 0.15,
          widget.salesData.weeklySales * 0.12,
        ];
      case 'monthly':
        // Last 30 days aggregated by week - smaller values
        return [
          widget.salesData.totalSales * 0.08,
          widget.salesData.totalSales * 0.12,
          widget.salesData.totalSales * 0.20,
          widget.salesData.totalSales * 0.25,
          widget.salesData.totalSales * 0.18,
        ];
      default:
        return [0, 0, 0, 0, 0];
    }
  }

  double _getHorizontalInterval(List<double> data) {
    if (data.isEmpty) return 1000;
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    if (maxValue > 10000) return 5000;
    if (maxValue > 5000) return 2000;
    if (maxValue > 1000) return 500;
    if (maxValue > 500) return 200;
    return 100;
  }

  String _getBottomTitle(int index, int total) {
    switch (_chartTypes[_selectedChartIndex]) {
      case 'daily':
        final hours = ['6', '8', '10', '12', '2', '4', '6', '8', '10'];
        return index < hours.length ? hours[index] : '';
      case 'weekly':
        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        return index < days.length ? days[index] : '';
      case 'monthly':
        final weeks = ['W1', 'W2', 'W3', 'W4', 'W5'];
        return index < weeks.length ? weeks[index] : '';
      default:
        return index.toString();
    }
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8), // Smaller radius
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            widget.localizations.translate('todayRevenue'),
            AppFormatters.formatCurrency(widget.salesData.todaysSales),
            Icons.today_rounded,
            const Color(0xFF10B981),
          ),
          _buildStatItem(
            widget.localizations.translate('weeklySales'),
            AppFormatters.formatCurrency(widget.salesData.weeklySales),
            Icons.calendar_view_week_rounded,
            const Color(0xFF3B82F6),
          ),
          _buildStatItem(
            widget.localizations.translate('totalRevenue'),
            AppFormatters.formatCompactCurrency(widget.salesData.totalSales),
            Icons.bar_chart_rounded,
            const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6), // Smaller
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16), // Smaller icon
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12, // Smaller font
                  ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 9, // Smaller font
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
