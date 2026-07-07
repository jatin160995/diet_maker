import 'package:diet_maker/Screens/MyProgress/ChartModels/measurement_chart_data.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    setState(() {});
  }

  @override
  void initState() {
    getPrefferedMeasurement();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

        primaryXAxis: DateTimeAxis(
          title: AxisTitle(text: 'Date'),
          intervalType: DateTimeIntervalType.days,
          dateFormat: DateFormat.Md(),
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

        series: chartSeriesData
            .map<LineSeries<MeasurementChartData, DateTime>>((seriesData) {
          return LineSeries<MeasurementChartData, DateTime>(
  name: seriesData['label'],
  dataSource: seriesData['data'],
  color: _hexToColor(seriesData['color']),
  xValueMapper: (MeasurementChartData data, _) => data.date,
  yValueMapper: (MeasurementChartData data, _) => data.measurement,
  emptyPointSettings: const EmptyPointSettings(
    mode: EmptyPointMode.drop,
  ),
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

      List<MeasurementChartData> chartData = dataPoints
          .where((point) {
            final measurement = point['measurement'];
            if (measurement == null) return false;
            final value = (measurement as num).toDouble();
            return value > 0;
          })
          .map((point) {
            DateTime? parsedDate;

            if (point['log_date'] != null) {
              parsedDate = DateTime.tryParse(point['log_date'].toString());
            }

            if (parsedDate == null && point['log_date_formatted'] != null) {
              try {
                final temp = DateFormat('MM/dd')
                    .parse(point['log_date_formatted'].toString());
                parsedDate = DateTime(
                  DateTime.now().year,
                  temp.month,
                  temp.day,
                );
              } catch (_) {}
            }

            parsedDate ??= DateTime.now();

            return MeasurementChartData(
              date: parsedDate,
              measurement: (point['measurement'] as num).toDouble(),
            );
          })
          .toList();

      chartData.sort((a, b) => a.date.compareTo(b.date));

      if (chartData.isNotEmpty) {
        parsedData.add({
          "label": label,
          "color": lineColor,
          "data": chartData,
        });
      }
    }
  }

  return parsedData;
}

  // Helper to convert hex color (e.g. "#FAD55C") to Flutter Color
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}