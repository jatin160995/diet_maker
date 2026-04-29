import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Models/user_profile.dart';
import 'package:diet_maker/Screens/Calendar/journal.dart';
import 'package:diet_maker/Screens/Calendar/add_schedule.dart';
import 'package:diet_maker/Screens/Calendar/schedule.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MyCalendar extends StatefulWidget {
  int? tabIndex;
  MyCalendar({super.key, this.tabIndex = 0});

  @override
  State<MyCalendar> createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  int selectedTab = 0; // 0 = Journal, 1 = Scehdule
  List<Widget> screens = [MyJournal(), ScheduleScreen()];
  @override
  void initState() {
    selectedTab = widget.tabIndex!;
    _editUser();
    super.initState();
    //screens = [new MyJournal(), new Schedule()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("My Calendar"),
      ),
      body: Container(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = 0;
                          });
                        },
                        child: Container(
                          color: selectedTab == 0 ? primaryColor : transparent,
                          child: Center(
                            child: Text(
                              "Journal",
                              style: TextStyle(
                                fontSize: selectedTab == 0 ? 16 : 14,
                                color: selectedTab == 0 ? white : textMedium(),
                                fontWeight:
                                    selectedTab == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = 1;
                          });
                        },
                        child: Container(
                          color: selectedTab == 1 ? primaryColor : transparent,
                          child: Center(
                            child: Text(
                              "Schedule",
                              style: TextStyle(
                                fontSize: selectedTab == 1 ? 16 : 14,
                                color: selectedTab == 1 ? white : textMedium(),
                                fontWeight:
                                    selectedTab == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: 50),
                child: IndexedStack(
                  //margin: EdgeInsets.only(top: 50),
                  children: screens,
                  index: selectedTab,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editUser() async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    String? dateOfBirth = (await StorageService.getLoginData())?.profile.dob;
    Map<String, dynamic> dataToPost = {
      "timezone": currentTimeZone,
      "dob": dateOfBirth,
    };
    // if (measurementController.text.toLowerCase() == "imperial") {
    //   final parts = heightController.text.split(".");
    //   dataToPost["height_feet"] = parts[0];
    //   dataToPost["height_in"] = parts.length > 1 ? parts[1] : "0";
    //   dataToPost["weight_lbs"] = weightController.text;
    // } else {
    //   dataToPost["height_cm"] = heightController.text;
    //   dataToPost["weight_kg"] = weightController.text;
    // }

    //return;
    try {
      Map data = await apiService.putRequest(editProfile, {}, dataToPost);
      print(dataToPost);
      print(data);
      setState(() async {
        LoginResponse response = LoginResponse(
          profile: UserProfile.fromJson(data['profile']),
          dietaryPreference: DietaryPreference.fromJson(
            data['dietary_preference'],
          ),
          accessToken: data['access_token'],
        );

        await StorageService.saveLoginData(response);

        // showToast("Profile Updated");
      });
    } catch (e) {
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
