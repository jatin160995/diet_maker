import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AddSchedule extends StatefulWidget {
  const AddSchedule({super.key});

  @override
  State<AddSchedule> createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  List<String> mealCycle = ["1", "2", "3", "4", "5", "6", "7"];
  int selectedMealCycle = 3;

  late LoginResponse userDetail;
  @override
  void initState() {
    _getMealPlansRequest();
    getUserDetails();
    super.initState();
  }

  getUserDetails() async {
    userDetail = (await StorageService.getLoginData())!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("Add Schedule"),
      ),
      body:
          _isLoading
              ? loader("Loading data...")
              : ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Start Date",
                            style: TextStyle(color: textMedium(), fontSize: 12),
                          ),
                          Text(
                            startDateString,
                            style: TextStyle(
                              color: textDark(),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "End Date",
                            style: TextStyle(color: textMedium(), fontSize: 12),
                          ),
                          Text(
                            endDateString,
                            style: TextStyle(
                              color: textDark(),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: borderRadius(white, 10),
                    child: SfDateRangePicker(
                      // cellBuilder: (context, cellDetails) {
                      //   print(cellDetails.date);
                      //   return Container();
                      // },
                      onSelectionChanged: _onSelectionChanged,
                      selectionMode: DateRangePickerSelectionMode.range,
                      backgroundColor: white,
                      selectionColor: primaryColor,
                      todayHighlightColor: primaryColor,
                      endRangeSelectionColor: primaryColor,
                      startRangeSelectionColor: primaryColor,
                      rangeSelectionColor: backgroundLight,
                      enablePastDates: false,

                      //selectionTextStyle: TextStyle(color: primaryColor),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: borderRadius(white, 10),
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //---------------------------------------------------------//
                        Text(
                          "Daily Meal Cycle",
                          style: TextStyle(color: textLightest(), fontSize: 12),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            showPicker(context, (int index) {
                              setState(() {
                                selectedMealCycle = index + 1;
                              });
                            }, mealCycle);
                          },
                          child: Container(
                            height: 55,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedMealCycle.toString(),
                                  style: TextStyle(
                                    color: textDark(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: textLightest(),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              border: Border.all(color: dividerColor),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                        heading("Select Meal Plan"),
                        SizedBox(height: 15),
                        //---------------------------------------------------------//
                        Column(children: createMealPlanWidgets()),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  DefaultButton("Save", () {
                    if (startDateString == "" || endDateString == "") {
                      showToast("Please select dates");
                    } else {
                      sendValuesToServer();
                    }
                  }),
                ],
              ),
    );
  }

  sendValuesToServer() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    //Setting up the data
    Map<String, dynamic> mapToSend = {};
    mapToSend = {
      "dietary_preference_id": userDetail.dietaryPreference.id,
      "start_date": startDateString,
      "end_date": endDateString,
      "cycle": selectedMealCycle,
    };
    List scheduleMealPlans = [];
    for (int i = 0; i < selectedMealCycle; i++) {
      scheduleMealPlans.add({
        "plan_day": i + 1,
        "meal_plan_id": mealPlansList[selectedMealList[i]]['id'].toString(),
      });
    }
    mapToSend["schedule_meal_plans"] = scheduleMealPlans;
    print(mapToSend);

    //return;
    try {
      showLoadingDialog(context, "Adding schedule...");
      Map data = await apiService.postWithToken(postSchedule, mapToSend);
      hideLoadingDialog(context);
      showToast("Schedule added to calender");
      Navigator.pop(context, true);
    } catch (e) {
      if (e is ApiException) {
        if (e.code == 422) {
          showToast(
            "There is already diet schedule for selected date. Please choose other dates.",
          );
        }
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
      }
      setState(() => _isLoading = false);
      hideLoadingDialog(context);
    }
  }

  String startDateString = "";
  String endDateString = "";
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange range = args.value;

      DateTime? startDate = range.startDate;
      DateTime? endDate = range.endDate;

      print("Start Date: $startDate");
      print("End Date: $endDate");

      // If endDate is null, user hasn't selected a full range yet
      if (endDate == null) {
        endDate = startDate; // fallback to startDate
      }

      // Example: format to yyyy-MM-dd
      startDateString =
          "${startDate!.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      endDateString =
          "${endDate!.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
      setState(() {});
      print("Formatted Start Date: $startDateString");
      print("Formatted End Date: $endDateString");
    }
  }

  List<int> selectedMealList = [0, 0, 0, 0, 0, 0, 0];

  createMealPlanWidgets() {
    List<Widget> mealPlanWidgetList = [];
    for (int i = 0; i < selectedMealCycle; i++) {
      mealPlanWidgetList.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //---------------------------------------------------------//
            SizedBox(height: 10),
            Text(
              "Meal " + (i + 1).toString() + " Plan",
              style: TextStyle(color: textLightest(), fontSize: 12),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                showPicker(context, (int index) {
                  setState(() {
                    selectedMealList[i] = index;
                  });
                }, mealNamesList);
              },
              child: Container(
                height: 55,
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mealNamesList[selectedMealList[i]],
                      style: TextStyle(
                        color: textDark(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: textLightest(),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  border: Border.all(color: dividerColor),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return mealPlanWidgetList;
  }

  bool _isLoading = false;
  dynamic mealPlansFromServer = [];
  dynamic mealPlansList = [];
  List<String> mealNamesList = [];
  void _getMealPlansRequest() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });

      Map data = await apiService.getWithToken(allMealPlan, {});
      setState(() {
        mealPlansFromServer = data;
        mealPlansList = data['table']['data'];
        for (var meal in mealPlansList) {
          mealNamesList.add(meal['title']);
        }
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
