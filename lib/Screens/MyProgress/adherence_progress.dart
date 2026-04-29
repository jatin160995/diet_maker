import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Screens/MyProgress/ChartModels/adherence_chart_data.dart';
import 'package:diet_maker/Screens/MyProgress/ChartWidgets/daily_adherence_log_widget.dart';
import 'package:diet_maker/Screens/MyProgress/ChartWidgets/time_range_selector.dart';
import 'package:diet_maker/Screens/MyProgress/Charts/adherence_chart.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdherenceScreen extends StatefulWidget {
  AdherenceScreen({super.key});

  @override
  State<AdherenceScreen> createState() => _AdherenceScreenState();
}

class _AdherenceScreenState extends State<AdherenceScreen> {
  dynamic chartData;
  dynamic logs;

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
    _getAdherenceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        //padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart
            TimeRangeSelector(
              onDateRangeSelected: (dateRange) {
                setState(() {
                  _startDate = dateRange['startDate'];
                  _endDate = dateRange['endDate'];
                });
                _getAdherenceData();
                print("Start Date: $_startDate, End Date: $_endDate");
              },
            ),
            _isLoading
                ? loader("loading...")
                : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      height: MediaQuery.of(context).size.height / 2,
                      color: backgroundColor(),

                      child: AdherenceChart(chartData: chartData),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        smallHeading("Average Meal Adherence (%)"),
                        heading(totalPercentage.toStringAsFixed(2) + "%"),
                      ],
                    ),
                    // Logs Section
                    Container(
                      padding: EdgeInsets.all(20),
                      child: DailyLogWidget(logs: logs),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  dynamic totalPercentage = 0;
  List<AdherenceChartData> parseChart(dynamic adherenceFromServer) {
    List<AdherenceChartData> chartData = [];
    dynamic totalValue = 0;
    if (adherenceFromServer['chart'] != null) {
      for (var point in adherenceFromServer['chart']) {
        // Skip if percentage is -1 (no data)
        if (point['percentage'] != -1) {
          totalValue = totalValue + point['percentage'];
          chartData.add(
            AdherenceChartData(
              dateLabel: point['date_formatted'],
              percentage: (point['percentage'] as num).toDouble(),
            ),
          );
        }
      }
      totalPercentage = totalValue / adherenceFromServer['chart'].length;
      //showToast(totalPercentage.toString());
    }
    return chartData;
  }

  List<DailyLog> parseLogs(dynamic adherenceFromServer) {
    List<DailyLog> logs = [];

    if (adherenceFromServer['list'] != null) {
      for (var day in adherenceFromServer['list']) {
        var log = day['log'];
        if (log != null && log['log_adherences'] != null) {
          List<MealLog> meals = [];
          for (var meal in log['log_adherences']) {
            meals.add(
              MealLog(title: meal['title'], isOnPlan: meal['is_on_plan']),
            );
          }

          logs.add(
            DailyLog(dateFormatted: log['log_date_formatted'], meals: meals),
          );
        }
      }
    }

    return logs;
  }

  bool _isLoading = false;
  dynamic adherenceFromServer = {};
  void _getAdherenceData() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });
      String? dietaryPrefId =
          (await StorageService.getLoginData())?.dietaryPreference.id
              .toString();
      String dataToSend =
          "?dietary_preference_id=$dietaryPrefId&period=custom&start_date=$_startDate&end_date=$_endDate";

      Map data = await apiService.getWithToken(
        getAdherenceLogs + dataToSend,
        {},
      );
      setState(() {
        adherenceFromServer = data;
        chartData = parseChart(adherenceFromServer);
        logs = parseLogs(adherenceFromServer);
        _isLoading = false;
      });
      print(data);
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
