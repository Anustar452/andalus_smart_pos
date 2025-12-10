// lib/src/widgets/reports/inventory_analysis_section.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/app_localizations.dart';
import '../../utils/reports_data_calculator.dart';
import '../common/custom_card.dart';

class InventoryAnalysisSection extends StatelessWidget {
  final ProductsReportData productsData;

  const InventoryAnalysisSection({super.key, required this.productsData});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Inventory Turnover Chart
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventory Turnover Analysis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: const CategoryAxis(),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(text: 'Turnover Ratio'),
                    ),
                    series: <CartesianSeries<TurnoverData, String>>[
                      ColumnSeries<TurnoverData, String>(
                        dataSource: _generateTurnoverData(),
                        xValueMapper: (data, _) => data.category,
                        yValueMapper: (data, _) => data.ratio,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Stock Movement Analysis
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock Movement Analysis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    primaryXAxis: const CategoryAxis(),
                    primaryYAxis: NumericAxis(title: AxisTitle(text: 'Units')),
                    series: <CartesianSeries<StockMovementData, String>>[
                      LineSeries<StockMovementData, String>(
                        dataSource: _generateStockMovementData(),
                        xValueMapper: (data, _) => data.period,
                        yValueMapper: (data, _) => data.units,
                        markerSettings: const MarkerSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<TurnoverData> _generateTurnoverData() {
    return [
      TurnoverData('Fast Moving', 8.5),
      TurnoverData('Medium Moving', 4.2),
      TurnoverData('Slow Moving', 1.8),
    ];
  }

  List<StockMovementData> _generateStockMovementData() {
    return [
      StockMovementData('Jan', 450),
      StockMovementData('Feb', 520),
      StockMovementData('Mar', 480),
      StockMovementData('Apr', 610),
      StockMovementData('May', 580),
      StockMovementData('Jun', 720),
    ];
  }
}

class TurnoverData {
  final String category;
  final double ratio;

  TurnoverData(this.category, this.ratio);
}

class StockMovementData {
  final String period;
  final int units;

  StockMovementData(this.period, this.units);
}
