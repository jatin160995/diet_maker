import 'package:diet_maker/Screens/MyProgress/ChartModels/measurement_chart_data.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MeasurementChart extends StatefulWidget {
  final dynamic data;

  const MeasurementChart({super.key, required this.data});

  @override
  State<MeasurementChart> createState() => _MeasurementChartState();
}

class _MeasurementChartState extends State<MeasurementChart> {
  String? prefMeasurement = "Imperial";

  getPrefferedMeasurement() async {
    prefMeasurement =
        (await StorageService.getLoginData())?.profile.preferredMeasurement;
    // userGender = (await StorageService.getLoginData())?.profile.gender;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Parse the JSON data
    final chartSeriesData = parseMeasurementData(widget.data);

    return Container(
      padding: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height / 2,
      color: backgroundColor(),
      child: SfCartesianChart(
        backgroundColor: Colors.white,
        title: ChartTitle(text: 'Body Measurements'),
        tooltipBehavior: TooltipBehavior(enable: true),
        legend: Legend(isVisible: true, position: LegendPosition.bottom),

        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Date'),
          majorGridLines: const MajorGridLines(width: 0),
        ),

        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text:
                'Measurement (' +
                ((prefMeasurement == "Imperial") ? "Inches" : "cms") +
                ')',
          ),
          majorGridLines: const MajorGridLines(width: 0.5),
        ),

        // Create multiple line series dynamically
        series:
            chartSeriesData.map<LineSeries<MeasurementChartData, String>>((
              seriesData,
            ) {
              return LineSeries<MeasurementChartData, String>(
                name: seriesData['label'],
                dataSource: seriesData['data'],
                color: _hexToColor(seriesData['color']),
                xValueMapper: (MeasurementChartData data, _) => data.dateLabel,
                yValueMapper:
                    (MeasurementChartData data, _) => data.measurement,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  shape: DataMarkerType.circle,
                ),
                width: 2,
              );
            }).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> parseMeasurementData(
    dynamic measurementLogsFromServer,
  ) {
    List<Map<String, dynamic>> parsedData = [];

    if (measurementLogsFromServer['chart'] != null) {
      for (var bodyPart in measurementLogsFromServer['chart']) {
        String label = bodyPart['label'].toString();
        String lineColor = bodyPart['line_color'];
        List<dynamic> dataPoints = bodyPart['data'];

        List<MeasurementChartData> chartData =
            dataPoints.map((point) {
              return MeasurementChartData(
                dateLabel: point['log_date_formatted'], // e.g., "09/18"
                measurement: (point['measurement'] as num).toDouble(),
              );
            }).toList();

        parsedData.add({"label": label, "color": lineColor, "data": chartData});
      }
    }

    return parsedData;
  }

  // Helper to convert hex color (e.g. "#FAD55C") to Flutter Color
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add opacity if missing
    }
    return Color(int.parse(hex, radix: 16));
  }
}
