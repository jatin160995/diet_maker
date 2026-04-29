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

  // popup
  bool _isAddingWeight = false;
  final TextEditingController noteController = TextEditingController();
  DateTime? selectedDate;

  // Weight picker variables
  int selectedWeight = 100; // Default weight
  String weightUnit = "lbs"; // or "kg" based on user preference

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
              print("Start Date: $_startDate, End Date: $_endDate");
            },
          ),
          _isLoading
              ? loader("loading data...")
              : Column(
                children: [
                  WeightChart(data: chartData),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child:
                        _isAddingWeight
                            ? SpinKitWave(color: primaryColor)
                            : ElevatedButton(
                              onPressed: () {
                                showAddWeightDialog(context);
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
                                "Add Weight",
                                style: TextStyle(
                                  color: white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  List<WeightChartData> parseChartData(dynamic weightsLogsFromServer) {
    List<dynamic> chartData = weightsLogsFromServer['chart'];
    return chartData.map((item) {
      return WeightChartData(
        date: DateTime.parse(item['date']),
        weight: (item['weight'] as num).toDouble(),
      );
    }).toList();
  }

  bool _isLoading = false;
  dynamic weightsLogsFromServer = {};
  void _getWeightData(bool showLoading) async {
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

      Map data = await apiService.getWithToken(getWeightLogs + dataToSend, {});
      setState(() {
        weightsLogsFromServer = data;
        chartData = parseChartData(weightsLogsFromServer);
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

  void showAddWeightDialog(BuildContext context) async {
    final TextEditingController noteController = TextEditingController();

    int selectedWeight = 100; // Default weight
    DateTime? selectedDate;
    bool _isAddingWeight = false;

    // Get dietary preference ID
    String? dietaryPrefId =
        (await StorageService.getLoginData())?.dietaryPreference.id.toString();

    // Get preferred measurement (Imperial or Metric)
    String? preferredMeasurement =
        (await StorageService.getLoginData())?.profile.preferredMeasurement ??
        "lbs";

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
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 40,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Center(
                        child: Text(
                          "Add Weight",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// -----------------------------
                      /// Weight Picker
                      /// -----------------------------
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
                                itemExtent: 50,
                                onSelectedItemChanged: (value) {
                                  setStateDialog(() {
                                    selectedWeight =
                                        value + 30; // Minimum weight = 30
                                  });
                                },
                                physics: const FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    bool isSelected =
                                        (index + 30) == selectedWeight;
                                    return Center(
                                      child: Text(
                                        (index + 30).toString(),
                                        style: TextStyle(
                                          fontSize: isSelected ? 26 : 20,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              isSelected
                                                  ? Colors.black
                                                  : Colors.grey.shade400,
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: 300, // up to 330 weight
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

                      /// -----------------------------
                      /// Date Picker
                      /// -----------------------------
                      const Text(
                        "Date",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
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
                                  color:
                                      selectedDate == null
                                          ? Colors.grey
                                          : Colors.black,
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

                      /// -----------------------------
                      /// Comment Field
                      /// -----------------------------
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

                      /// -----------------------------
                      /// Save Button
                      /// -----------------------------
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isAddingWeight
                                  ? null
                                  : () async {
                                    if (selectedDate == null) {
                                      showToast("Please select a date");
                                      return;
                                    }

                                    // // Prepare data to send
                                    // Map<String, dynamic> mapToSend = {
                                    //   "dietary_preference_id": dietaryPrefId,
                                    //   "weight": selectedWeight,
                                    //   "log_date":
                                    //       "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                                    //   "note": noteController.text.trim(),
                                    // };
                                    Navigator.pop(context);
                                    addWeightToServer(
                                      dietaryPrefId.toString(),
                                      selectedWeight,
                                      selectedDate!,
                                      noteController.text.trim(),
                                      context,
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
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

  void addWeightToServer(
    String dietaryPrefId,
    int weight,
    DateTime date,
    String note,
    BuildContext context,
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

    print("Add Weight Payload: $mapToSend");

    try {
      setState(() {
        _isAddingWeight = true;
      });

      Map response = await apiService.postWithToken(addWeight, mapToSend);

      setState(() {
        _isAddingWeight = false;
      });

      // Navigator.pop(context); // Close popup\
      _getWeightData(false);
      showToast("Weight added successfully");
      print("Response: $response");
    } catch (e) {
      setState(() {
        _isAddingWeight = false;
      });

      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
      }
    }
  }
}
