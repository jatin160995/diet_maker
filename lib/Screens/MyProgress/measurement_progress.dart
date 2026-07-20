import 'package:diet_maker/Exception/api_exception.dart';
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

  bool _isLoading = false;
  dynamic measurementLogsFromServer = {};
  List<Map<String, dynamic>> measurementLogGroups = [];

  @override
  void initState() {
    super.initState();
    _endDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, now.day));
    _startDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month - 1, now.day));
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
              },
            ),
            _isLoading
                ? loader("loading data...")
                : Column(
                    children: [
                      MeasurementChart(data: measurementLogsFromServer),
                      const SizedBox(height: 10),
                      _buildMeasurementLogsList(),
                    ],
                  ),
            _isLoading
                ? Container()
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddMeasurementsScreen(),
                          ),
                        );

                        if (result == true) {
                          _getMeasurementData(false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  List<Map<String, dynamic>> parseMeasurementLogs(dynamic response) {
    List<dynamic> logs = [];

    if (response is Map) {
      if (response['list'] is List) {
        logs = response['list'];
      } else if (response['data'] is Map && response['data']['list'] is List) {
        logs = response['data']['list'];
      }
    }

    return logs.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Widget _buildMeasurementLogsList() {
    if (measurementLogGroups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          "No measurement logs found for selected range.",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: measurementLogGroups.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, monthIndex) {
        final monthGroup = measurementLogGroups[monthIndex];
        final String month = (monthGroup['month'] ?? '').toString();
        final List logs = (monthGroup['logs'] ?? []) as List;

        if (logs.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (month.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 10, left: 4),
                  child: Text(
                    month,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  "No logs in this month.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (month.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 10, left: 4),
                child: Text(
                  month,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              itemBuilder: (context, logIndex) {
                final Map<String, dynamic> logItem =
                    Map<String, dynamic>.from(logs[logIndex]);

                final dynamic logId = logItem['id'];
                final String dateText = (logItem['log_date_formatted'] ??
                        logItem['log_date'] ??
                        logItem['date'] ??
                        '')
                    .toString();

                final List items =
                    (logItem['items'] ?? logItem['measurements'] ?? []) as List;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              dateText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddMeasurementsScreen(editLog: logItem),
                                  ),
                                );

                                if (result == true) {
                                  _getMeasurementData(false);
                                }
                              } else if (value == 'delete') {
                                _confirmDeleteMeasurement(logId);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert, color: darkText,),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (items.isEmpty)
                        const Text(
                          "No measurements available",
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: items.map((item) {
                            final map = Map<String, dynamic>.from(item);
                            final String bodyPart =
                                (map['body_part'] ?? '').toString();
                            final String measurement =
                                (map['measurement'] ?? '').toString();

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                "$bodyPart: $measurement",
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _getMeasurementData(bool showLoading) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = showLoading;
      });

      String? dietaryPrefId =
          (await StorageService.getLoginData())?.dietaryPreference.id.toString();

      String dataToSend =
          "?dietary_preference_id=$dietaryPrefId&period=custom&start_date=$_startDate&end_date=$_endDate";

      Map data = await apiService.getWithToken(
        getMeasurementLogs + dataToSend,
        {},
      );

      setState(() {
        measurementLogsFromServer = data;
        measurementLogGroups = parseMeasurementLogs(data);
        _isLoading = false;
      });
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        debugPrint(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        debugPrint("Unexpected error: $e");
      }
      setState(() => _isLoading = false);
    }
  }

  void _confirmDeleteMeasurement(dynamic id) {
    if (id == null) {
      showToast("Measurement log id not found");
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Measurement"),
          content: const Text("Are you sure you want to delete this measurement log?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteMeasurement(id);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMeasurement(dynamic id) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });

      await apiService.deleteWithToken("$deleteMeasurementLogs/$id", {});

      showToast("Measurement deleted successfully");
      _getMeasurementData(false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e is ApiException) {
        showToast(e.message.toString());
        debugPrint("API Error: ${e.message}, status: ${e.code}");
      } else {
        debugPrint("Unexpected error: $e");
      }
    }
  }
}