// import 'package:diet_maker/Exception/api_exception.dart';
// import 'package:diet_maker/Screens/Calendar/add_schedule.dart';
// import 'package:diet_maker/services/api_service.dart';
// import 'package:diet_maker/utils/api_endpoints.dart';
// import 'package:diet_maker/utils/app_helpers.dart';
// import 'package:diet_maker/utils/color_utils.dart';
// import 'package:diet_maker/utils/design_utils.dart';
// import 'package:diet_maker/widgets/app_popups.dart';
// import 'package:diet_maker/widgets/small_heading.dart';
// import 'package:flutter/material.dart';

// class Schedule extends StatefulWidget {
//   const Schedule({super.key});

//   @override
//   State<Schedule> createState() => _ScheduleState();
// }

// class _ScheduleState extends State<Schedule> {
//   @override
//   void initState() {
//     _getSchedulesRequest();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: SafeArea(
//         child: GestureDetector(
//           onTap: () async {
//             bool needRefresh = await Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => AddSchedule()),
//             );
//             if (needRefresh) {
//               _getSchedulesRequest();
//             }
//           },
//           child: Container(
//             height: 50,
//             color: primaryColor,
//             child: Center(
//               child: Text(
//                 "Add Schedule",
//                 style: TextStyle(
//                   color: white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       body:
//           _isLoading
//               ? loader("loading schedules...")
//               : ListView(
//                 padding: EdgeInsets.all(20),
//                 children: schedulesWidgets(),
//               ),
//     );
//   }

//   schedulesWidgets() {
//     List<Widget> schedulesWidgetsList = [];
//     for (int i = 0; i < schedulesFromServer.length; i++) {
//       List<Widget> mealsWidgetList = [];
//       List<dynamic> meals = schedulesFromServer[i]['schedule_meal_plans'];
//       for (int x = 0; x < meals.length; x++) {
//         mealsWidgetList.add(
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
//                 margin: EdgeInsets.only(bottom: 2, top: 5),
//                 decoration: borderRadius(primaryColorLight, 5),
//                 child: Text(
//                   (x + 1).toString(),
//                   style: TextStyle(color: textMedium(), fontSize: 15),
//                 ),
//               ),
//               SizedBox(width: 15),
//               meals[x]['meal_plan'] != null
//                   ? Text(meals[x]['meal_plan']['title'])
//                   : Text("Meal Plan not available"),
//             ],
//           ),
//         );
//       }
//       schedulesWidgetsList.add(
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: heading(
//                     schedulesFromServer[i]["start_date"].toString().replaceAll(
//                           "-",
//                           "/",
//                         ) +
//                         " - " +
//                         schedulesFromServer[i]["end_date"]
//                             .toString()
//                             .replaceAll("-", "/"),
//                   ),
//                 ),
//                 PopupMenuButton<String>(
//                   icon: Icon(Icons.more_vert, color: textDark()),
//                   onSelected: (value) {
//                     if (value == 'delete') {
//                       showDialog(
//                         context: context,
//                         builder:
//                             (_) => AlertDialog(
//                               title: Text('Confirm'),
//                               content: Text('Are you sure you want to delete?'),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   child: Text('Cancel'),
//                                 ),
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                     deleteMealPlan(
//                                       schedulesFromServer[i]['id'],
//                                     );
//                                   },
//                                   child: Text(
//                                     'Delete',
//                                     style: TextStyle(color: Colors.red),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                       );
//                     }
//                   },
//                   itemBuilder:
//                       (BuildContext context) => [
//                         PopupMenuItem<String>(
//                           value: 'delete',
//                           child: Row(
//                             children: const [
//                               Icon(Icons.delete, color: Colors.red),
//                               SizedBox(width: 8),
//                               Text(
//                                 'Delete',
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                 ),
//               ],
//             ),
//             SmallHeading(
//               schedulesFromServer[i]['dietary_preference']['title'] +
//                   " (" +
//                   schedulesFromServer[i]['cycle'].toString() +
//                   " Day Meal Cycle)",
//             ),
//             Column(children: mealsWidgetList),
//             Divider(height: 30, color: dividerColor),
//           ],
//         ),
//       );
//     }
//     if (schedulesWidgetsList.length == 0) {
//       schedulesWidgetsList.add(
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               "No Schedule found",
//               style: TextStyle(
//                 color: textLightest(),
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     return schedulesWidgetsList;
//   }

//   bool isDeletingScheduleLoading = false;
//   Future<void> deleteMealPlan(int scheduleId) async {
//     final apiService = ApiService();
//     //print("$deleteSchedule$scheduleId");
//     ///return;
//     try {
//       setState(() => isDeletingScheduleLoading = true);
//       showLoadingDialog(context, "Deleting Schedule...");

//       await apiService.deleteWithToken("$deleteSchedule$scheduleId", {});

//       hideLoadingDialog(context);
//       showToast("Schedule deleted successfully!");
//       setState(() => isDeletingScheduleLoading = false);
//       _getSchedulesRequest();
//       //Navigator.pop(context, true);
//       //Navigator.pop(context, true);
//     } catch (e) {
//       hideLoadingDialog(context);
//       if (e is ApiException) {
//         showToast(e.message.toString());
//         print("API Error: ${e.message}, status: ${e.code}");
//       } else {
//         showToast("Unexpected error while Deleting Schedule.");
//       }
//     } finally {
//       setState(() => isDeletingScheduleLoading = false);
//     }
//   }

//   bool _isLoading = false;
//   List schedulesFromServer = [];

//   void _getSchedulesRequest() async {
//     FocusManager.instance.primaryFocus?.unfocus();
//     final ApiService apiService = ApiService();

//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       Map data = await apiService.getWithToken(getSchedule, {});
//       setState(() {
//         schedulesFromServer = data['table']['data'];
//         _isLoading = false;
//       });
//       print(data);
//     } catch (e) {
//       if (e is ApiException) {
//         showToast(e.message.toString());
//         print(
//           "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
//         );
//       } else {
//         print("Unexpected error: $e");
//       }
//       setState(() => _isLoading = false);
//     }
//   }
// }

import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Screens/Calendar/add_schedule.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;

  List schedulesFromServer = [];
  List currentAndUpcoming = [];
  List pastSchedules = [];

  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  // ---------------- API CALL ----------------
  Future<void> fetchSchedules() async {
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
      splitSchedules();
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

  // ---------------- LOGIC ----------------
  bool isPastSchedule(String endDate) {
    final today = DateTime.now();
    final end = DateTime.parse(endDate);
    return end.isBefore(DateTime(today.year, today.month, today.day));
  }

  void splitSchedules() {
    currentAndUpcoming.clear();
    pastSchedules.clear();

    for (var schedule in schedulesFromServer) {
      if (isPastSchedule(schedule['end_date'])) {
        pastSchedules.add(schedule);
      } else {
        currentAndUpcoming.add(schedule);
      }
    }

    // Sorting
    currentAndUpcoming.sort(
      (a, b) => a['start_date'].compareTo(b['start_date']),
    );

    pastSchedules.sort((a, b) => b['end_date'].compareTo(a['end_date']));
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddSchedule()),
              );
              fetchSchedules();
            },
            child: Container(
              height: 50,
              color: primaryColor,
              child: Center(
                child: Text(
                  "Add Schedule",
                  style: TextStyle(
                    color: white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        appBar: AppBar(
          leadingWidth: 1,
          leading: Container(),
          title: const TabBar(
            isScrollable: true,
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            tabs: [Tab(text: "Current & Upcoming"), Tab(text: "Past")],
          ),
          //bottom:
        ),
        body: TabBarView(
          children: [
            buildScheduleList(currentAndUpcoming, isPast: false),
            buildScheduleList(pastSchedules, isPast: true),
          ],
        ),
      ),
    );
  }

  Widget buildScheduleList(List schedules, {required bool isPast}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (schedules.isEmpty) {
      return Center(
        child: Text(
          isPast ? "No past schedules found" : "No current schedules found",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return scheduleCard(schedule, isPast);
      },
    );
  }

  Widget scheduleCard(Map schedule, bool isPast) {
    List<Widget> mealsWidgetList = [];

    List<dynamic> meals = schedule['schedule_meal_plans'] ?? [];

    for (int x = 0; x < meals.length; x++) {
      mealsWidgetList.add(
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              margin: const EdgeInsets.only(bottom: 2, top: 5),
              decoration: borderRadius(primaryColorLight, 5),
              child: Text(
                (x + 1).toString(),
                style: TextStyle(color: textMedium(), fontSize: 15),
              ),
            ),
            const SizedBox(width: 15),
            meals[x]['meal_plan'] != null
                ? Text(meals[x]['meal_plan']['title'])
                : const Text("Meal Plan not available"),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------- HEADER ROW --------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: heading(
                schedule["start_date"].toString().replaceAll("-", "/") +
                    " - " +
                    schedule["end_date"].toString().replaceAll("-", "/"),
              ),
            ),

            // Show delete ONLY for current/upcoming
            if (!isPast)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: textDark()),
                onSelected: (value) {
                  if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text(
                              'Are you sure you want to delete?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  deleteScheduleRequest(schedule['id']);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
              ),
          ],
        ),

        // -------- SUB HEADING --------
        SmallHeading(
          schedule['dietary_preference']['title'] +
              " (" +
              schedule['cycle'].toString() +
              " Day Meal Cycle)",
        ),

        // -------- MEALS LIST --------
        Column(children: mealsWidgetList),

        const Divider(height: 30, color: dividerColor),
      ],
    );
  }

  Widget rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  String formatDate(String date) {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
  }

  bool isDeletingScheduleLoading = false;
  // ---------------- ACTIONS ----------------
  deleteScheduleRequest(int scheduleId) async {
    final apiService = ApiService();
    //showToast("$deleteSchedule$scheduleId");
    ///return;
    try {
      setState(() => isDeletingScheduleLoading = true);
      showLoadingDialog(context, "Deleting Schedule...");

      await apiService.deleteWithToken("$deleteSchedule$scheduleId", {});

      hideLoadingDialog(context);
      showToast("Schedule deleted successfully!");
      setState(() => isDeletingScheduleLoading = false);
      fetchSchedules();
      //Navigator.pop(context, true);
      //Navigator.pop(context, true);
    } catch (e) {
      hideLoadingDialog(context);
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
      } else {
        showToast("Unexpected error while Deleting Schedule.");
      }
    } finally {
      setState(() => isDeletingScheduleLoading = false);
    }
  }
}
