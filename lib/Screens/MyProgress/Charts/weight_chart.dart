import 'package:diet_maker/Screens/MyProgress/ChartModels/weight_chart_data.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';

class WeightChart extends StatefulWidget {
  final List<WeightChartData> data;

  const WeightChart({super.key, required this.data});

  @override
  State<WeightChart> createState() => _WeightChartState();
}

class _WeightChartState extends State<WeightChart> {
  String? prefMeasurement = "Imperial";

  getPrefferedMeasurement() async {
    prefMeasurement =
        (await StorageService.getLoginData())?.profile.preferredMeasurement;
    // userGender = (await StorageService.getLoginData())?.profile.gender;
    setState(() {});
  }

  @override
  void initState() {
    getPrefferedMeasurement();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      padding: EdgeInsets.all(20),
      color: backgroundColor(),
      child: SfCartesianChart(
        backgroundColor: Colors.white,
        title: ChartTitle(text: 'Weight Progress'),
        legend: Legend(isVisible: false),
        tooltipBehavior: TooltipBehavior(enable: true,  header: '',),
        primaryXAxis: DateTimeAxis(
          title: AxisTitle(text: 'Date'),
          intervalType: DateTimeIntervalType.days,
          dateFormat: DateFormat.Md(),
          majorGridLines: const MajorGridLines(width: 0),
        ),

        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text:
                'Weight (' +
                ((prefMeasurement == "Imperial") ? "lbs" : "kgs") +
                ")",
          ),
          majorGridLines: const MajorGridLines(width: 0.5),
        ),
        series: <LineSeries<WeightChartData, DateTime>>[
          LineSeries<WeightChartData, DateTime>(
            dataSource: widget.data,
            xValueMapper: (WeightChartData entry, _) => entry.date,
            yValueMapper: (WeightChartData entry, _) => entry.weight,
            color: primaryColor,
            width: 2,
            markerSettings: const MarkerSettings(
              isVisible: true,
              color: primaryColor,
              shape: DataMarkerType.circle,
            ),
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
        ],
      ),
    );
  }
}
