import 'dart:convert';
import 'dart:io';

import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Screens/Calendar/journal_archive.dart';
import 'package:diet_maker/main.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/utils/globals.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/loading_image.dart';
import 'package:diet_maker/widgets/single_item_desc.dart';
import 'package:diet_maker/widgets/single_recipe_item_desc.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class MyJournal extends StatefulWidget {
  const MyJournal({super.key});

  @override
  State<MyJournal> createState() => _MyJournalState();
}

class _MyJournalState extends State<MyJournal> with RouteAware {
  dynamic selectedMealPlan = {};
  int? dayIndex;

  // Images for dates
  Map<String, dynamic> imagesForSchedules = {};

  // Adherence
  Map<String, dynamic> adherenceForSchedules = {};
  @override
  void initState() {
    _getSchedulesRequest();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 👇 This runs when you return to this screen
    debugPrint("Returned");
    _getSchedulesRequest();
  }

  @override
  Widget build(BuildContext context) {
    //print(selectedMealPlan);
    return Scaffold(
      backgroundColor: backgroundLight,
      body:
          _isLoading
              ? loader("Loading...")
              : ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JournalArchiveScreen(),
                                ),
                              );
                            },
                            child: Container(
                              child: Text(
                                "View Journal Archive >",
                                style: TextStyle(color: textDark()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SfDateRangePicker(
                        navigationMode: DateRangePickerNavigationMode.none,
                        cellBuilder: (context, cellDetails) {
                          //print(cellDetails.date);
                          final DateTime currentDate = cellDetails.date;

                          // ✅ Check if currentDate falls between ANY schedule range
                          bool isWithinSchedule = schedulesFromServer.any((
                            schedule,
                          ) {
                            DateTime start = DateTime.parse(
                              schedule['start_date'],
                            );
                            DateTime end = DateTime.parse(schedule['end_date']);
                            return currentDate.isAtSameMomentAs(start) ||
                                currentDate.isAtSameMomentAs(end) ||
                                (currentDate.isAfter(start) &&
                                    currentDate.isBefore(end));
                          });

                          return Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Date number
                                Text(
                                  "${currentDate.day}",
                                  style: TextStyle(
                                    color:
                                        isWithinSchedule
                                            ? primaryColor
                                            : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                // Dot shown only if in schedule range
                                if (isWithinSchedule)
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                        onSelectionChanged: _onSelectionChanged,
                        //selectionMode: DateRangePickerSelectionMode.range,
                        backgroundColor: Colors.white,
                        selectionColor: backgroundLight,
                        todayHighlightColor: primaryColor,
                        endRangeSelectionColor: primaryColor,
                        startRangeSelectionColor: primaryColor,
                        rangeSelectionColor: backgroundLight,
                        showNavigationArrow: true,
                      ),
                      SizedBox(height: 15),
                      SmallHeading("Selected Date"),
                      heading(selectedDateString),
                      _isLoadingMeal
                          ? loader("Loading meals...")
                          : selectedMealPlan.isEmpty
                          ? Container(
                            margin: EdgeInsets.only(top: 30),
                            child: Center(
                              child: Text(
                                "No meal plan scheduled for the day!",
                                style: TextStyle(
                                  color: textLightest(),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: mealPlanWidgets(
                              allLoadedMealPlans[selectedMealPlan[dayIndex]['meal_plan_id']
                                  .toString()],
                            ),
                          ),
                      SizedBox(height: 20),
                      selectedMealPlan.isEmpty
                          ? Container()
                          : Column(
                            children: [
                              Row(
                                children: [
                                  imageWidget("Front"),
                                  SizedBox(width: 20),
                                  imageWidget("Back"),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  imageWidget("Left"),
                                  SizedBox(width: 20),
                                  imageWidget("Right"),
                                ],
                              ),
                            ],
                          ),
                      // ElevatedButton(
                      //   onPressed: getTimezone,
                      //   child: Text("Pick or Capture Image"),
                      // ),
                    ],
                  ),
                ],
              ),
    );
  }

  imageWidget(String title) {
    String imageUrl = "";
     String imageId = "";
    if (imagesForSchedules[selectedScheduleId.toString()] != null) {
      final selectedDateData = imagesForSchedules[selectedScheduleId.toString()]
          .firstWhere(
            (item) => item['date'] == selectedDateString,
            orElse: () => null,
          );
      //print(selectedDateData['photos']);
      if (selectedDateData != null) {
        dynamic image = selectedDateData['photos'].firstWhere(
          (item) => item['type'] == title,
          orElse: () => {"type": "noImage"},
        );
        //imageUrl = image[0]['photo_url'];
        if (image['type'] != "noImage") {
          imageUrl = image['photo_url'];
         // showToast(selectedDateData.toString());
        } else {
          imageUrl = "";
        }
        print(imageUrl);
      } 
    }
    return Expanded(
      child: GestureDetector(
        onTap: () {
          
          _showImageSourceOptions(title, imageUrl);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title + " Photo", style: TextStyle(color: textLightest())),
            SizedBox(height: 5),
            Container(
              height: MediaQuery.of(context).size.width / 3,
              color: dividerColor,
              child:
                  imageUrl == ""
                      ? Image.asset(imagesPath + "img-placeholder.png")
                      : LoadingImage(imageUrl),
            ),
          ],
        ),
      ),
    );
  }

  bool _isLoading = false;
  List schedulesFromServer = [];

  void _getSchedulesRequest() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });

      Map data = await apiService.getWithToken(getSchedule, {});
      setState(() {
        schedulesFromServer = data['table']['data'];
        _isLoading = false;
      });
      Future.delayed(Duration(milliseconds: 2500), () {
        updateSelectedMealPlan(DateTime.now());
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

  String selectedDateString = "";
  String startDateString = "";
  String endDateString = "";
  int selectedDietaryPrefId = 0;
  int selectedMealPlanId = 0;
  int selectedScheduleId = 0;

  void updateSelectedMealPlan(DateTime selectedDate) {
    //showToast(schedulesFromServer.toString());
    dynamic foundPlan;

    for (var schedule in schedulesFromServer) {
      DateTime start = DateTime.parse(schedule['start_date']);
      DateTime end = DateTime.parse(schedule['end_date']);

      if (selectedDate.isAtSameMomentAs(start) ||
          selectedDate.isAtSameMomentAs(end) ||
          (selectedDate.isAfter(start) && selectedDate.isBefore(end))) {
        foundPlan = schedule['schedule_meal_plans'];

        //  Calculate day difference
        int daysDiff = selectedDate.difference(start).inDays;

        //  Get cycle count
        int cycleCount = schedule['cycle'] ?? 1;

        //  Calculate index within the cycle
        dayIndex = daysDiff % cycleCount;

        print("Selected Date: $selectedDate");
        print("Start Date: $start");
        print("Day Difference: $daysDiff");
        print("Cycle Count: $cycleCount");
        print("Meal Plan Index: $dayIndex");
        selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate);
        startDateString = DateFormat('yyyy-MM-dd').format(start);
        endDateString = DateFormat('yyyy-MM-dd').format(end);
        selectedDietaryPrefId = schedule['dietary_preference_id'];
        selectedScheduleId = schedule['id'];
        break; // stop after finding the matching schedule
      }
    }

    setState(() {
      if (foundPlan != null && foundPlan is List) {
        selectedMealPlan = foundPlan;
      } else {
        selectedMealPlan = {}; // clear if no match
      }
    });
    print(selectedMealPlan);
    print(selectedMealPlan.length);
    if (selectedMealPlan is List &&
        selectedMealPlan.isNotEmpty &&
        selectedMealPlan[dayIndex!] != null) {
      print(
        "Selected Meal Plan ID: ${selectedMealPlan[dayIndex!]['meal_plan_id']}",
      );
      selectedMealPlanId = selectedMealPlan[dayIndex]['meal_plan_id'];
      if (!allLoadedMealPlans.containsKey(
        selectedMealPlan[dayIndex]['meal_plan_id'].toString(),
      )) {
        _getMealPlansRequest(selectedMealPlan[dayIndex]['meal_plan_id']);
      }
      if (!imagesForSchedules.containsKey(selectedScheduleId.toString())) {
        _getCalendarImages();
      }
      if (!adherenceForSchedules.containsKey(selectedScheduleId.toString())) {
        _getAdherenceData();
      }
      // print(selectedDateString + "---------------------------");
      // print(startDateString + "---------------------------");
      // print(endDateString + "---------------------------");
      // print(selectedMealPlanId.toString() + "---------------------------");
      // print(selectedDietaryPrefId.toString() + "---------------------------");
      // print(selectedScheduleId.toString() + "---------------------------");
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is DateTime) {
      updateSelectedMealPlan(args.value);
      print(args.value);
    }
  }

  // get Meal Plan
  Map allLoadedMealPlans = {};
  var mealPlanFromServer = {};

  List completeNutrientBreakdown = [];
  bool _isLoadingMeal = false;
  void _getMealPlansRequest(int mealId) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoadingMeal = true;
      });

      Map data = await apiService.getWithToken(
        mealPlanById + mealId.toString(),
        {},
      );
      setState(() {
        mealPlanFromServer = data;
        List mealPlans = [];
        mealPlans = mealPlanFromServer['meal_meals'];
        allLoadedMealPlans[mealId.toString()] = mealPlans;
        completeNutrientBreakdown =
            mealPlanFromServer['complete_nutrient_breakdown'];
        _isLoadingMeal = false;
        //updateSelectedMealPlan(DateTime.now());
        // print(allLoadedMealPlans);
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
      setState(() => _isLoadingMeal = false);
    }
  }

  Future<String?> showAddJournalDialog(BuildContext context, {String journal = ""} ) async {
    TextEditingController _controller = TextEditingController();
_controller.text = journal;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Journal",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                selectedDateString,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: textMedium(),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: borderRadius(backgroundColor(), 8),
                child: TextField(
                  controller: _controller,
                  maxLines: 3,
                  
                  decoration: InputDecoration(
                    hintText: "Write here...",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: textMedium())),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () {
                String value = _controller.text.trim();
                Navigator.pop(context, value); // return value

                Map<String, dynamic> mapToSend = {
                  "log_date": selectedDateString,
                  "dietary_preference_id": selectedDietaryPrefId,
                  "meal_plan_id": selectedMealPlanId.toString(),
                  "schedule_id": selectedScheduleId,
                  "note": value,
                };
                _setJournalToServer(mapToSend);
                print(mapToSend);
              },
              child: Text("Submit", style: TextStyle(color: white)),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            ),
          ],
        );
      },
    );
  }

  List<Widget> mealPlanWidgets(List mealPlans) {
    dynamic logForSelectedDate = getLogByDate(selectedDateString);
    print(logForSelectedDate.toString());
    List adherenceForSelectedDate =
        logForSelectedDate == null ? [] : logForSelectedDate['log_adherences'];
    dynamic journalForSelectedDate =
        logForSelectedDate == null ? [] : logForSelectedDate['log_journal'];
    print("sected_adherence" + adherenceForSelectedDate.toString());
    print("sected_adherence-" + mealPlans.length.toString());
    List<Widget> mealPlanWidgetsList = [];
    print(logForSelectedDate);
    mealPlanWidgetsList.add(
      journalForSelectedDate['note'] == null
          ? GestureDetector(
            onTap: () async {
              print(logForSelectedDate);
              final result = await showAddJournalDialog(context);
              print(result);

              // print(mapToSend);
              // _setAdherenceToServer(mapToSend);
            },
            child: Container(
              margin: EdgeInsets.only(top: 10),
              height: 40,
              decoration: borderRadius(primaryColor, 10),
              child: Center(
                child: Text(
                  "Add Journal",
                  style: TextStyle(color: white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              SmallHeading("Journal"),
              Row(
               children: [Expanded(
                 child: Text(
                    journalForSelectedDate['note'] == null
                        ? "N/A"
                        : journalForSelectedDate['note'],
                    style: TextStyle(fontSize: 15, color: textDark()),
                  ),
               ),
                IconButton(onPressed: () async {final result = await showAddJournalDialog(context, journal: journalForSelectedDate['note'] == null
                      ? "N/A"
                      : journalForSelectedDate['note']);}, icon: Icon(Icons.edit,color: darkText,))
                ],
              ),
            ],
          ),
    );
    for (int i = 0; i < mealPlans.length; i++) {
      mealPlanWidgetsList.add(
        Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.all(10),
          decoration: borderRadius(white, 8),
          child: ExpandablePanel(
            header: heading("Meal " + (i + 1).toString()),
            controller: ExpandableController(initialExpanded: true),
            collapsed: Text(
              "Time : " + mealPlans[i]['meal_time_formatted'],
              style: TextStyle(color: textMedium()),
            ),
            expanded: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Time : " + mealPlans[i]['meal_time_formatted'],
                  style: TextStyle(color: textMedium()),
                ),
                SizedBox(height: 10),
                Column(
                  children: recipeWidget(
                    mealPlans[i]['meal_recipes'],
                    mealPlans[i]['id'],
                    mealPlans[i],
                  ),
                ),
                Column(
                  children: foodWidget(
                    mealPlans[i]['meal_foods'],
                    mealPlans[i]['id'],
                    mealPlans[i],
                  ),
                ),
                isFutureDate(selectedDateString) ||
                        adherenceForSelectedDate.isEmpty
                    ? Container()
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: borderRadius(dividerColor, 20),
                          height: 30,
                          width: 140,
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Map<String, dynamic> mapToSend = {
                                      "log_date": selectedDateString,
                                      "dietary_preference_id":
                                          selectedDietaryPrefId,
                                      "meal_plan_id":
                                          mealPlans[i]['meal_plan_id'],
                                      "schedule_id": selectedScheduleId,
                                      "meal_meal_id": mealPlans[i]['id'],
                                      "is_on_plan": "Yes",
                                    };
                                    _setAdherenceToServer(mapToSend);
                                  },
                                  child: Container(
                                    height: 35,
                                    color:
                                        adherenceForSelectedDate[i]["is_on_plan"] ==
                                                "Yes"
                                            ? Colors.green
                                            : transparent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "On Plan",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              adherenceForSelectedDate[i]["is_on_plan"] ==
                                                      "Yes"
                                                  ? white
                                                  : textMedium(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 35,
                                width: 1,
                                color: textLightest(),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Map<String, dynamic> mapToSend = {
                                      "log_date": selectedDateString,
                                      "dietary_preference_id":
                                          selectedDietaryPrefId,
                                      "meal_plan_id":
                                          mealPlans[i]['meal_plan_id'],
                                      "schedule_id": selectedScheduleId,
                                      "meal_meal_id": mealPlans[i]['id'],
                                      "is_on_plan": "No",
                                    };
                                    _setAdherenceToServer(mapToSend);
                                  },
                                  child: Container(
                                    height: 35,
                                    color:
                                        adherenceForSelectedDate[i]["is_on_plan"] ==
                                                "No"
                                            ? Colors.red
                                            : transparent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Off Plan",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              adherenceForSelectedDate[i]["is_on_plan"] ==
                                                      "No"
                                                  ? white
                                                  : textMedium(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      );
    }

    return mealPlanWidgetsList;
  }

  List<Widget> foodWidget(List foods, int meal_id, dynamic mealPlan) {
    List<Widget> foodWidgetsList = [];
    for (int i = 0; i < foods.length; i++) {
      foodWidgetsList.add(SingleItemDescription(foods[i], mealPlan));
    }
    return foodWidgetsList;
  }

  List<Widget> recipeWidget(List recipes, int meal_id, dynamic mealPlan) {
    List<Widget> foodWidgetsList = [];
    for (int i = 0; i < recipes.length; i++) {
      foodWidgetsList.add(SingleRecipeItemDescription(recipes[i], mealPlan));
    }
    return foodWidgetsList;
  }

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  /// Pick image from gallery
  Future<void> _pickImageFromGallery(String type) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      sendValuesToServer(type);
    }
  }

  /// Capture image using camera
  Future<void> _captureImageFromCamera(String type) async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 20,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
      sendValuesToServer(type);
    }
  }

  /// Show options dialog
  void _showImageSourceOptions(String type, String imageUrl) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Browse Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery(type);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Capture Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _captureImageFromCamera(type);
                },
              ),
            // imageUrl == "" ? Container():  ListTile(
            //     leading: Icon(Icons.delete, color: Colors.red,),
            //     title: Text("Delete Photo", style: TextStyle(color: Colors.red),),
            //     onTap: () {
            //       Navigator.pop(context);
            //       _confirmDeleteMeasurement(context);
            //     },
            //   ),
            ],
          ),
        );
      },
    );
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
          title: const Text("Delete Image journal"),
          content: const Text("Are you sure you want to delete this image journal?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                 await _deleteImageLog(id);
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

  Future<void> _deleteImageLog(dynamic id) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });

      await apiService.deleteWithToken("$logPhotos/$id", {});

      showToast("Measurement deleted successfully");
      
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

  // sendValuesToServer() async {
  //   FocusManager.instance.primaryFocus?.unfocus();
  //   final ApiService apiService = ApiService();
  //   //Setting up the data
  //   Map<String, dynamic> mapToSend = {};
  //   mapToSend = {
  //     "log_date": "2025-08-16",
  //     "dietary_preference_id": 896,
  //     "meal_plan_id": 1011,
  //     "schedule_id": 314,
  //     "type": "Front",
  //     "photo": _selectedImage!.path,
  //   };

  //   print(mapToSend);

  //   //return;
  //   try {
  //     showLoadingDialog(context, "Adding Photo...");
  //     Map data = await apiService.postWithToken(logPhotos, mapToSend);
  //     print(data);
  //     hideLoadingDialog(context);
  //     showToast("Schedule added to calender");
  //     Navigator.pop(context, true);
  //   } catch (e) {
  //     if (e is ApiException) {
  //       print("API Error: ${e.message}, status: ${e.code}");
  //       print("Details: ${e.errorBody}");
  //     } else {
  //       print("Unexpected error: $e");
  //     }
  //     setState(() => _isLoading = false);
  //     hideLoadingDialog(context);
  //   }
  // }

  sendValuesToServer(String type) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    // Setting up the data
    Map<String, dynamic> mapToSend = {
      "log_date": selectedDateString,
      "dietary_preference_id": selectedDietaryPrefId,
      "meal_plan_id": selectedMealPlanId,
      "schedule_id": selectedScheduleId,
      "type": type,
      // "photo": _selectedImage, // <-- must be a File object
    };

    print("Data to send: $mapToSend");

    try {
      showLoadingDialog(context, "Adding photo...");

      // Build Multipart Request
      var uri = Uri.parse(
        baseUrl + logPhotos,
      ); // postSchedule must be a full URL
      var request = http.MultipartRequest('POST', uri);

      // ✅ Add headers
      String? token = (await StorageService.getLoginData())?.accessToken;
      request.headers.addAll({
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      });

      // ✅ Add non-file fields (must be String)
      request.fields['log_date'] = mapToSend['log_date'].toString();
      request.fields['dietary_preference_id'] =
          mapToSend['dietary_preference_id'].toString();
      request.fields['meal_plan_id'] = mapToSend['meal_plan_id'].toString();
      request.fields['schedule_id'] = mapToSend['schedule_id'].toString();
      request.fields['type'] = mapToSend['type'].toString();
      // Add JSON data as a single field
      request.fields['data'] = jsonEncode(mapToSend);

      // Add image file
      if (_selectedImage != null && _selectedImage is File) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo', // Field name expected by backend
            _selectedImage!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        throw Exception("No image selected or invalid file.");
      }

      // ✅ Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      hideLoadingDialog(context);

      if (response.statusCode == 200) {
        print("Response: $responseBody");
        showToast("Image added to calendar");
        _getCalendarImages();
        // Navigator.pop(context, true);
      } else {
        print("Error ${response.statusCode}: $responseBody");
        throw ApiException(
          message: "Failed to add Image",
          code: response.statusCode,
          errorBody: responseBody,
        );
      }
    } catch (e) {
      hideLoadingDialog(context);

      if (e is ApiException) {
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
      }

      setState(() => _isLoading = false);
    }
  }

  bool isLoadingImages = false;
  void _getCalendarImages() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    Map<String, dynamic> mapToSend = {
      "dietary_preference_id": selectedDietaryPrefId,
      "period": "custom",
      "start_date": startDateString,
      "end_date": endDateString,
    };
    print(mapToSend);
    try {
      setState(() {
        isLoadingImages = true;
      });
      String parameters =
          "?dietary_preference_id=$selectedDietaryPrefId&period=custom&start_date=$startDateString&end_date=$endDateString";

      List<dynamic> data = await apiService.getWithToken(
        comparePhotos + parameters,
        {},
      );
      //print(data);
      setState(() {
        //showToast("hello");
        imagesForSchedules[selectedScheduleId.toString()] = data;
        print(imagesForSchedules);
        isLoadingImages = false;
      });
      //print(data);
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
      setState(() => isLoadingImages = false);
    }
  }

  bool isLoadingAdherence = false;
  void _setAdherenceToServer(Map<String, dynamic> mapToSend) async {
    print(mapToSend);
    //return;
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        isLoadingAdherence = true;
      });
      showLoadingDialog(context, "Saving data...");
      String parameters =
          "?log_date=$selectedDateString&dietary_preference_id=$selectedDietaryPrefId&schedule_id=$selectedScheduleId&meal_plan_id=" +
          mapToSend['meal_plan_id'].toString() +
          "&meal_meal_id=" +
          mapToSend['meal_meal_id'].toString() +
          "&is_on_plan=" +
          mapToSend['is_on_plan'].toString();
      print(parameters);
      //return;
      dynamic data = await apiService.postWithToken(addAdherence, mapToSend);
      print("journal----" + data.toString());
      setState(() {
        //showToast("hello");
        hideLoadingDialog(context);
        _getAdherenceData();
        isLoadingAdherence = false;
      });
      //print(data);
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
      hideLoadingDialog(context);
      setState(() => isLoadingAdherence = false);
    }
  }

  void _setJournalToServer(Map<String, dynamic> mapToSend) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    print(mapToSend);
    // return;

    try {
      setState(() {
        isLoadingAdherence = true;
      });
      showLoadingDialog(context, "Saving data...");
      // String parameters =
      //     "?log_date=$selectedDateString&dietary_preference_id=$selectedDietaryPrefId&schedule_id=$selectedScheduleId&meal_plan_id=" +
      //     mapToSend['meal_plan_id'].toString() +
      //     "&meal_meal_id=" +
      //     mapToSend['meal_meal_id'].toString() +
      //     "&is_on_plan=" +
      //     mapToSend['is_on_plan'].toString();
      // print(parameters);
      //return;
      dynamic data = await apiService.postWithToken(addJournal, mapToSend);
      print("journal----" + data.toString());
      setState(() {
        //showToast("hello");
        hideLoadingDialog(context);
        _getAdherenceData();
        isLoadingAdherence = false;
      });
      //print(data);
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
      hideLoadingDialog(context);
      setState(() => isLoadingAdherence = false);
    }
  }

  // get adherence from server
  Map<String, dynamic>? getLogByDate(String date) {
    // Decode the JSON string into a Dart Map
    if (isLoadingGetAdherence) {
      return {"log_adherences": []};
    }
    Map<String, dynamic> data =
        adherenceForSchedules[selectedScheduleId.toString()];

    // Access the 'list' array from the decoded data
    List<dynamic> list = data['list'];

    // Iterate through the list to find the matching date
    for (var item in list) {
      if (item['date'] == date) {
        // Return the 'log' object if the date matches
        return item['log'] as Map<String, dynamic>;
      }
    }

    // Return null if no matching date is found
    return null;
  }

  //dynamic adherenceFromServer = {};
  bool isLoadingGetAdherence = false;
  void _getAdherenceData() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        isLoadingGetAdherence = true;
      });

      String dataToSend =
          "?dietary_preference_id=$selectedDietaryPrefId&period=custom&start_date=$startDateString&end_date=$endDateString";

      Map data = await apiService.getWithToken(
        getAdherenceLogs + dataToSend,
        {},
      );
      setState(() {
        isLoadingGetAdherence = false;
        adherenceForSchedules[selectedScheduleId.toString()] = data;
      });
      print("Adherence-" + data.toString());
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
      setState(() => isLoadingGetAdherence = false);
    }
  }
}
