import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Screens/MyProgress/ChartModels/weight_chart_data.dart';
import 'package:diet_maker/Screens/MyProgress/ChartWidgets/time_range_selector.dart';
import 'package:diet_maker/Screens/MyProgress/Charts/weight_chart.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class WeightProgress extends StatefulWidget {
  const WeightProgress({super.key});

  @override
  State<WeightProgress> createState() => _WeightProgressState();
}

class _WeightProgressState extends State<WeightProgress> {
  List<WeightChartData> chartData = [];
  List<Map<String, dynamic>> weightLogs = [];

  bool _isAddingWeight = false;
  bool _isLoading = false;

  String? _startDate;
  String? _endDate;
  final DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _endDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, now.day));
    _startDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month - 1, now.day));
    _getWeightData(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          TimeRangeSelector(
            onDateRangeSelected: (dateRange) {
              setState(() {
                _startDate = dateRange['startDate'];
                _endDate = dateRange['endDate'];
              });
              _getWeightData(true);
            },
          ),
          _isLoading
              ? loader("loading data...")
              : Column(
                  children: [
                    WeightChart(data: chartData),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: _isAddingWeight
                          ? SpinKitWave(color: primaryColor)
                          : ElevatedButton(
                              onPressed: () {
                                showAddEditWeightDialog(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Add Weight",
                                style: TextStyle(
                                  color: white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    _buildWeightLogsList(),
                    const SizedBox(height: 20),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildWeightLogsList() {
  if (weightLogs.isEmpty) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Text(
        "No weight logs found for selected range.",
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: weightLogs.length,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemBuilder: (context, monthIndex) {
      final monthGroup = weightLogs[monthIndex];
      final String month = (monthGroup['month'] ?? '').toString();
      final List logs = (monthGroup['logs'] ?? []) as List;

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
                  color: Colors.black,
                ),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            itemBuilder: (context, logIndex) {
              final logWrapper = logs[logIndex] as Map<String, dynamic>;
              final log = Map<String, dynamic>.from(logWrapper['log'] ?? {});
              final dynamic id = log['id'];

              final String note = (log['note'] ?? '').toString();
              final String dateStr =
                  (log['log_date_formatted'] ?? log['log_date'] ?? logWrapper['date'] ?? '').toString();

              final dynamic weightValue = log['lbs'] ?? log['kg'] ?? '';
              final String weightText = weightValue.toString();

              return Container(
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$weightText ${_displayWeightUnitFromLog(log)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          if (note.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              note,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          showAddEditWeightDialog(
                            context,
                            logItem: log,
                          );
                        } else if (value == 'delete') {
                          _confirmDeleteWeight(log);
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
              );
            },
          ),
        ],
      );
    },
  );
}
 String _displayWeightUnitFromLog(Map<String, dynamic> log) {
  if (log['lbs'] != null && log['lbs'].toString().isNotEmpty) {
    return "lbs";
  }
  if (log['kg'] != null && log['kg'].toString().isNotEmpty) {
    return "kg";
  }
  return "lbs";
}

  String _formatDate(String value) {
    try {
      final date = DateTime.parse(value);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return value;
    }
  }

  List<WeightChartData> parseChartData(dynamic weightsLogsFromServer) {
    List<dynamic> chartItems = [];

    if (weightsLogsFromServer is Map) {
      if (weightsLogsFromServer['chart'] is List) {
        chartItems = weightsLogsFromServer['chart'];
      } else if (weightsLogsFromServer['data'] is Map &&
          weightsLogsFromServer['data']['chart'] is List) {
        chartItems = weightsLogsFromServer['data']['chart'];
      }
    }

    return chartItems.map((item) {
      return WeightChartData(
        date: DateTime.parse(item['date']),
        weight: (item['weight'] as num).toDouble(),
      );
    }).toList();
  }

  List<Map<String, dynamic>> parseWeightLogs(dynamic response) {
    List<dynamic> logs = [];

    if (response is Map) {
      if (response['logs'] is List) {
        logs = response['logs'];
      } else if (response['data'] is Map && response['data']['logs'] is List) {
        logs = response['data']['logs'];
      } else if (response['weight_logs'] is List) {
        logs = response['weight_logs'];
      } else if (response['data'] is Map && response['data']['weight_logs'] is List) {
        logs = response['data']['weight_logs'];
      } else if (response['list'] is List) {
        logs = response['list'];
      } else if (response['data'] is Map && response['data']['list'] is List) {
        logs = response['data']['list'];
      }
    }

    return logs.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  dynamic weightsLogsFromServer = {};

  void _getWeightData(bool showLoading) async {
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

      Map data = await apiService.getWithToken(getWeightLogs + dataToSend, {});

      setState(() {
        weightsLogsFromServer = data;
        chartData = parseChartData(weightsLogsFromServer);
        weightLogs = parseWeightLogs(weightsLogsFromServer);
        _isLoading = false;
      });
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
      } else {
        debugPrint("Unexpected error: $e");
      }
      setState(() => _isLoading = false);
    }
  }

  void showAddEditWeightDialog(
    BuildContext context, {
    Map<String, dynamic>? logItem,
  }) async {
    final TextEditingController noteController = TextEditingController(
      text: (logItem?['note'] ?? '').toString(),
    );

    int selectedWeight = int.tryParse(
      (logItem?['lbs'] ?? logItem?['kg'] ?? '100').toString().split('.').first,
    ) ??
    100;

    DateTime? selectedDate;
    if (logItem != null) {
      final existingDate = (logItem['log_date'] ?? logItem['date'] ?? '').toString();
      try {
        selectedDate = DateTime.parse(existingDate);
      } catch (_) {
        selectedDate = null;
      }
    }

    String? dietaryPrefId =
        (await StorageService.getLoginData())?.dietaryPreference.id.toString();

    String? preferredMeasurement =
        (await StorageService.getLoginData())?.profile.preferredMeasurement ?? "lbs";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          logItem == null ? "Add Weight" : "Edit Weight",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        height: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryColor,
                                  width: 1,
                                ),
                              ),
                              child: ListWheelScrollView.useDelegate(
                                controller: FixedExtentScrollController(
                                  initialItem: selectedWeight - 30,
                                ),
                                itemExtent: 50,
                                onSelectedItemChanged: (value) {
                                  setStateDialog(() {
                                    selectedWeight = value + 30;
                                  });
                                },
                                physics: const FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    bool isSelected = (index + 30) == selectedWeight;
                                    return Center(
                                      child: Text(
                                        (index + 30).toString(),
                                        style: TextStyle(
                                          fontSize: isSelected ? 26 : 20,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: 300,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              preferredMeasurement.toLowerCase() == "imperial"
                                  ? "lbs"
                                  : "kg",
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Date",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setStateDialog(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade100,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDate != null
                                    ? "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}"
                                    : "Select Date",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedDate == null ? Colors.grey : Colors.black,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Comment",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Add your comment",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedDate == null) {
                              showToast("Please select a date");
                              return;
                            }

                            Navigator.pop(context);

                            if (logItem != null) {
                              await updateWeightToServer(
                                dietaryPrefId.toString(),
                                selectedWeight,
                                selectedDate!,
                                noteController.text.trim(),
                                logItem,
                              );
                            } else {
                              await addWeightToServer(
                                dietaryPrefId.toString(),
                                selectedWeight,
                                selectedDate!,
                                noteController.text.trim(),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            logItem == null ? "Save" : "Update",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> addWeightToServer(
    String dietaryPrefId,
    int weight,
    DateTime date,
    String note,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    Map<String, dynamic> mapToSend = {
      "dietary_preference_id": dietaryPrefId,
      "weight": weight,
      "log_date":
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      "note": note,
    };

    try {
      setState(() {
        _isAddingWeight = true;
      });

      await apiService.postWithToken(addWeight, mapToSend);

      setState(() {
        _isAddingWeight = false;
      });

      _getWeightData(false);
      showToast("Weight added successfully");
    } catch (e) {
      setState(() {
        _isAddingWeight = false;
      });

      if (e is ApiException) {
        showToast(e.message.toString());
      } else {
        debugPrint("Unexpected error: $e");
      }
    }
  }

  Future<void> updateWeightToServer(
    String dietaryPrefId,
    int weight,
    DateTime date,
    String note,
    Map<String, dynamic> oldItem,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    final dynamic oldId = oldItem['id'];
    if (oldId == null) {
      showToast("Weight log id not found");
      return;
    }

    Map<String, dynamic> mapToSend = {
      "dietary_preference_id": dietaryPrefId,
      "weight": weight,
      "log_date":
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      "note": note,
    };

    try {
      setState(() {
        _isAddingWeight = true;
      });

       await apiService.postWithToken(addWeight, mapToSend);

      setState(() {
        _isAddingWeight = false;
      });

      _getWeightData(false);
      showToast("Weight updated successfully");
    } catch (e) {
      setState(() {
        _isAddingWeight = false;
      });

      if (e is ApiException) {
        showToast(e.message.toString());
      } else {
        debugPrint("Unexpected error: $e");
      }
    }
  }

  void _confirmDeleteWeight(Map<String, dynamic> item) {
    final dynamic id = item['id'];

    if (id == null) {
      showToast("Weight log id not found");
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Weight"),
          content: const Text("Are you sure you want to delete this weight log?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteWeight(id);
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

  Future<void> _deleteWeight(dynamic id) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });

      await apiService.deleteWithToken("$deleteWeight/$id", {});

      showToast("Weight deleted successfully");
      _getWeightData(false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e is ApiException) {
        showToast(e.message.toString());
      } else {
        debugPrint("Unexpected error: $e");
      }
    }
  }
}