import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Models/user_profile.dart';
import 'package:diet_maker/Screens/AddMeal/MealPlan/add_meal_plan.dart';
import 'package:diet_maker/Screens/my_meal_plan_calculator.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/vertical_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class MyMealPlan extends StatefulWidget {
  const MyMealPlan({super.key});

  @override
  State<MyMealPlan> createState() => _MyMealPlanState();
}

class _MyMealPlanState extends State<MyMealPlan> {
  bool isImperial = false;
  @override
  void initState() {
    getValues();
    _getMealPlansRequest();
    super.initState();
  }

  getValues() async {
    LoginResponse userDetail = (await StorageService.getLoginData())!;
    isImperial =
        userDetail.profile.preferredMeasurement.toLowerCase() == "imperial"
            ? true
            : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      bottomNavigationBar: SafeArea(
        child: GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMealPlanScreen()),
            );
            _getMealPlansRequest();
          },
          child: Container(
            height: 50,
            color: primaryColor,
            child: Center(
              child: Text(
                "Add Meal Plan +",
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("My Meal Plans"),
      ),
      body:
          _isLoading
              ? loader("Loading meal Plans...")
              : ListView(
                padding: EdgeInsets.all(20),
                children: mealPlanWidget(),
              ),
    );
  }

  List<Widget> mealPlanWidget() {
    List<Widget> mealPlanWidgetList = [];
    for (int i = mealPlansList.length - 1; i >= 0; i--) {
      print(mealPlansList[i]['title']);
      print(mealPlansList[i]["is_primary"]);

      if (mealPlansList[i]["is_primary"] == "Yes") {
        // DietaryPreference.setPrimaryMealPlanId(1);
        print(mealPlansList[i]["id"]);
      }
      mealPlanWidgetList.add(
        Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    heading(mealPlansList[i]['title']),
                    Text(
                      mealPlansList[i]["is_primary"] == "Yes"
                          ? " (Primary)"
                          : "",
                      style: TextStyle(color: primaryColor, fontSize: 13),
                    ),
                  ],
                ),

                Container(
                  decoration: borderRadius(primaryColor, 10),
                  height: 35,
                  child: TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MyMealPlanCalculator(
                                mealPlanId: mealPlansList[i]["id"],
                              ),
                        ),
                      );
                      _getMealPlansRequest();
                    },
                    child: Text(
                      "View Detail >",
                      style: TextStyle(color: white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(15),
              decoration: borderRadius(white, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "No. of meals: " +
                        mealPlansList[i]['total_meal'].toString(),
                    style: TextStyle(color: textMedium()),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      VerticalProgress(
                        "Protein",
                        protien,
                        mealPlansList[i]['protein_amount'].toDouble(),
                        mealPlansList[i]['dietary_preference']['protein_required']
                            .toDouble(),
                        "g",
                      ),
                      VerticalProgress(
                        "Carbs",
                        carbs,
                        mealPlansList[i]['carbohydrate_amount'].toDouble(),
                        mealPlansList[i]['dietary_preference']['carbohydrate_required']
                            .toDouble(),
                        "g",
                      ),
                      VerticalProgress(
                        "Fats",
                        fats,
                        mealPlansList[i]['fat_amount'].toDouble(),
                        mealPlansList[i]['dietary_preference']['fat_required']
                            .toDouble(),
                        "g",
                      ),
                      VerticalProgress(
                        "Calories",
                        calories,
                        mealPlansList[i]['calorie_amount'].toDouble(),
                        mealPlansList[i]['dietary_preference']['daily_calorie_intake']
                            .toDouble(),
                        "k",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // SizedBox(height: 20),
            // Container(
            //   decoration: borderRadius(white, 10),
            //   padding: EdgeInsets.all(20),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       heading("Dietary Preference"),
            //       SizedBox(height: 20),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Expanded(
            //             child: Column(
            //               children: [
            //                 prefWidget(
            //                   "Weight",
            //                   isImperial
            //                       ? mealPlansList[i]['dietary_preference']['weight_lbs']
            //                               .toString() +
            //                           "lbs"
            //                       : mealPlansList[i]['dietary_preference']['weight_kg']
            //                               .toString() +
            //                           "kg",
            //                   "assets/images/weight.png",
            //                 ),
            //                 prefWidget(
            //                   "Height",
            //                   isImperial
            //                       ? mealPlansList[i]['dietary_preference']['height_feet']
            //                               .toString() +
            //                           ""
            //                       : mealPlansList[i]['dietary_preference']['height_cm']
            //                               .toString() +
            //                           "cm",
            //                   "assets/images/height.png",
            //                 ),
            //                 prefWidget(
            //                   "Activity Level",
            //                   mealPlansList[i]['dietary_preference']['activity_level_title']
            //                       .toString(),
            //                   "assets/images/run.png",
            //                 ),
            //                 // prefWidget(
            //                 //   "No. of Meal",
            //                 //   mealPlansList[i]['dietary_preference']['weight_kg']
            //                 //               .toString(),
            //                 //   "assets/images/meal.png",
            //                 // ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(height: 20),
            Divider(color: dividerColor, height: 30),
          ],
        ),
      );
    }
    return mealPlanWidgetList;
  }

  prefWidget(String title, String value, String image) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 45,
            width: 45,
            padding: EdgeInsets.all(8),
            decoration: borderRadius(primaryColorLight, 22.5),
            child: Image.asset(image),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textDark(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: textLightest(),
                  fontSize: 12.5,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isLoading = false;
  dynamic mealPlansFromServer = [];
  dynamic mealPlansList = [];
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
        _isLoading = false;
      });
      _editUser();
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

  void _editUser() async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    String? dateOfBirth = (await StorageService.getLoginData())?.profile.dob;
    Map<String, dynamic> dataToPost = {
      "timezone": currentTimeZone,
      "dob": dateOfBirth,
    };

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
