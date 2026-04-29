import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Models/user_profile.dart';
import 'package:diet_maker/Screens/Calendar/journal_archive.dart';
import 'package:diet_maker/Screens/MyProgress/Charts/adherence_chart.dart';
import 'package:diet_maker/Screens/MyProgress/ComparePhotosScreen.dart';
import 'package:diet_maker/Screens/MyProgress/adherence_progress.dart';
import 'package:diet_maker/Screens/MyProgress/journal_archive.dart';
import 'package:diet_maker/Screens/MyProgress/measurement_progress.dart';
import 'package:diet_maker/Screens/MyProgress/weight_progress.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class MyProgress extends StatefulWidget {
  const MyProgress({super.key});

  @override
  State<MyProgress> createState() => _MyProgressState();
}

class _MyProgressState extends State<MyProgress> {
  List<String> tabs = [
    "Adherence",
    "Weight",
    "Measurements",
    "Progress Pics",
    "Journal",
  ];
  List<Widget> screens = [
    AdherenceScreen(),
    WeightProgress(),
    MeasurementProgress(),
    ComparePhotosScreen(),
    JournalArchive(),
  ];
  int screenIndex = 0;

  bool isLoading = false;

  @override
  void initState() {
    _editUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: heading("My Progress"),
        backgroundColor: backgroundColor(),
      ),
      body:
          isLoading
              ? loader("Loading data...")
              : Stack(
                children: [
                  Container(
                    height: 60,
                    color: dividerColor,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: createTabs(),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 60),
                    child: IndexedStack(children: screens, index: screenIndex),
                  ),
                ],
              ),
    );
  }

  List<Widget> createTabs() {
    List<Widget> tabsWidgetList = [];
    for (int i = 0; i < tabs.length; i++) {
      tabsWidgetList.add(
        GestureDetector(
          onTap: () {
            setState(() {
              screenIndex = i;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            margin: EdgeInsets.symmetric(horizontal: 5),
            //height: 43,
            decoration: borderRadius(
              screenIndex == i ? primaryColor : white,
              25,
            ),
            child: Center(
              child: Text(
                tabs[i],
                style: TextStyle(
                  color: screenIndex == i ? white : textMedium(),
                  fontSize: 15,
                  fontWeight:
                      screenIndex == i ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return tabsWidgetList;
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
    setState(() {
      isLoading = true;
    });
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
        setState(() {
          isLoading = false;
          ;
        });
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
      setState(() {
        isLoading = false;
      });
    }
  }
}
