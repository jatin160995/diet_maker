import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:flutter/material.dart';

class NotifficationPreferences extends StatefulWidget {
  const NotifficationPreferences({super.key});

  @override
  State<NotifficationPreferences> createState() =>
      _NotifficationPreferencesState();
}

class _NotifficationPreferencesState extends State<NotifficationPreferences> {
  bool mealTime = false;
  bool writeJournal = false;
  bool missedJournal = false;
  //
  String mealTimeString = "Before meal time";
  String writeJournalString = "To write journal";
  String missedJournalString = "For missed journal";
  // bool missedMeal = true;

  late LoginResponse userDetail;
  List savedNotificaations = [];

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  getDetails() async {
    userDetail = (await StorageService.getLoginData())!;
    savedNotificaations = userDetail.profile.notification;
    if (savedNotificaations.contains("write_journal")) {
      writeJournal = true;
    }
    if (savedNotificaations.contains("missed_journal")) {
      missedJournal = true;
    }
    if (savedNotificaations.contains("before_meal_time")) {
      mealTime = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("Notification Preference"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          preferenceWidget(mealTimeString, mealTime, (t) {
            setState(() {
              mealTime = t;
              submitRecipeToMeal();
            });
          }),
          preferenceWidget(writeJournalString, writeJournal, (t) {
            setState(() {
              writeJournal = t;
              submitRecipeToMeal();
            });
          }),
          preferenceWidget(missedJournalString, missedJournal, (t) {
            setState(() {
              missedJournal = t;
              submitRecipeToMeal();
            });
          }),
          // preferenceWidget("Notification for missed meals", missedMeal, (t) {
          //   setState(() {
          //     missedMeal = t;
          //   });
          // }),
        ],
      ),
    );
  }

  preferenceWidget(String title, bool flag, Function onChanged) {
    return Container(
      height: 50,
      decoration: borderRadius(white, 25),
      padding: EdgeInsets.symmetric(horizontal: 15),
      margin: EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: textMedium())),
          Switch(
            value: flag,
            onChanged: (t) {
              onChanged(t);
            },
            inactiveThumbColor: dividerColor,
            inactiveTrackColor: Colors.grey,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  bool _isLoading = false;

  void submitRecipeToMeal() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    Map<String, dynamic> dataToPost = {
      "write_journal": writeJournal ? "yes" : "no",
      "missed_journal": missedJournal ? "yes" : "no",
      "before_meal_time": mealTime ? "yes" : "no",
    };
    print(dataToPost);
    //return;
    try {
      showLoadingDialog(context, "Updating..");
      Map data = await apiService.postWithToken(notification, dataToPost);
      //Navigator.pop(context);
      //Navigator.pop(context);
      hideLoadingDialog(context);
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
      }
      setState(() => _isLoading = false);
      hideLoadingDialog(context);
    }
  }
}
