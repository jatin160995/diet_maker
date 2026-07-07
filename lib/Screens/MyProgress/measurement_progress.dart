import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Screens/MyProgress/ChartModels/measurement_chart_data.dart';
import 'package:diet_maker/Screens/MyProgress/ChartWidgets/time_range_selector.dart';
import 'package:diet_maker/Screens/MyProgress/Charts/measurement_chart.dart';
import 'package:diet_maker/Screens/MyProgress/add_measurements_screen.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class MeasurementProgress extends StatefulWidget {
  const MeasurementProgress({super.key});

  @override
  State<MeasurementProgress> createState() => _MeasurementProgressState();
}

class _MeasurementProgressState extends State<MeasurementProgress> {
  String? _startDate;
  String? _endDate;
  final DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _endDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(now.year, now.month, now.day));
    _startDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(now.year, now.month - 1, now.day));
    _getMeasurementData(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TimeRangeSelector(
              onDateRangeSelected: (dateRange) {
                setState(() {
                  _startDate = dateRange['startDate'];
                  _endDate = dateRange['endDate'];
                });
                _getMeasurementData(true);
                print("Start Date: $_startDate, End Date: $_endDate");
              },
            ),
            _isLoading
                ? loader("loading data...")
                : Column(
                  children: [MeasurementChart(data: measurementLogsFromServer)],
                ),
            _isLoading
                ? Container()
                : Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMeasurementsScreen(),
                        ),
                      );
                      _getMeasurementData(false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Add Measurement",
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  bool _isLoading = false;
  dynamic measurementLogsFromServer = {};
  void _getMeasurementData(bool showLoading) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = showLoading;
      });
      String? dietaryPrefId =
          (await StorageService.getLoginData())?.dietaryPreference.id
              .toString();
      String dataToSend =
          "?dietary_preference_id=$dietaryPrefId&period=custom&start_date=$_startDate&end_date=$_endDate";

      Map data = await apiService.getWithToken(
        getMeasurementLogs + dataToSend,
        {},
      );
      setState(() {
        measurementLogsFromServer = data;
        // chartData = parseChartData(weightsLogsFromServer);
        _isLoading = false;
      });
      print(data);
      // TEMP DEBUG — remove after checking
      if (data['chart'] != null && data['chart'].isNotEmpty) {
        var firstPoint = data['chart'][0]['data'];
        if (firstPoint != null && firstPoint.isNotEmpty) {
          print("DATA POINT KEYS: ${firstPoint[0].keys.toList()}");
          print("DATA POINT SAMPLE: ${firstPoint[0]}");
        }
      }
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
      setState(() => _isLoading = false);
    }
  }
}
