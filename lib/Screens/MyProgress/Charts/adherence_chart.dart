import 'package:diet_maker/Screens/MyProgress/ChartModels/adherence_chart_data.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdherenceChart extends StatelessWidget {
  final List<AdherenceChartData> chartData;

  const AdherenceChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,

      child: SfCartesianChart(
        title: ChartTitle(text: 'Adherence Progress'),
        tooltipBehavior: TooltipBehavior(enable: true),

        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Date'),
          labelRotation: -30,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Adherence (%)'),
          minimum: 0,
          maximum: 100,
        ),
        series: [
          LineSeries<AdherenceChartData, String>(
            dataSource: chartData,
            xValueMapper: (AdherenceChartData data, _) => data.dateLabel,
            yValueMapper: (AdherenceChartData data, _) => data.percentage,
            markerSettings: const MarkerSettings(isVisible: true),
            color: primaryColor,
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
          AreaSeries<AdherenceChartData, String>(
            dataSource: chartData,
            xValueMapper: (AdherenceChartData data, _) => data.dateLabel,
            yValueMapper: (AdherenceChartData data, _) => data.percentage,
            color: Colors.green.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
