import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Models/user_profile.dart';
import 'package:diet_maker/Screens/Auth/login.dart';
import 'package:diet_maker/Screens/dashboard.dart';
import 'package:diet_maker/Screens/nutrition_target.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/globals.dart';
import 'package:diet_maker/widgets/app_popups.dart';

import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';

class Signup2 extends StatefulWidget {
  const Signup2({super.key});

  @override
  State<Signup2> createState() => _Signup2State();
}

class _Signup2State extends State<Signup2> {
  TextEditingController measurementController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController activityController = TextEditingController();
  TextEditingController mealsController = TextEditingController();
  TextEditingController dietTitleController = TextEditingController();
  List<String> measurements = ["Imperial", "Metric"];
  List<String> activityLevels = [
    "Sedentary",
    "Lightly Active",
    "Moderately Active",
    "Very Active",
    "Extreme Activity",
  ];
  List<String> meals = ["1", "2", "3", "4", "5", "6"];

  Map activityLevelValues = {
    "Sedentary": "1.2",
    "Lightly Active": "1.375",
    "Moderately Active": "1.55",
    "Very Active": "1.7",
    "Extreme Activity": "1.9",
  };

  late LoginResponse userDetail;

  getDetails() async {
    userDetail = (await StorageService.getLoginData())!;
    measurementController.text = userDetail.profile.preferredMeasurement;

    measurementController = TextEditingController(
      text: userDetail.profile.preferredMeasurement,
    );
    dietTitleController = TextEditingController(
      text: userDetail.dietaryPreference.title,
    );
    mealsController = TextEditingController(
      text: userDetail.dietaryPreference.noOfMeals.toString(),
    );
    activityController = TextEditingController(
      text: userDetail.dietaryPreference.activityLevelTitle.toString(),
    );

    await getVariableValues();
    setState(() {});
  }

  getVariableValues() async {
    userDetail = (await StorageService.getLoginData())!;
    heightController = TextEditingController(
      text: await getUserHeight(measurementController.text),
    );
    weightController = TextEditingController(
      text: await getUserWeight(measurementController.text),
    );
  }

  @override
  void initState() {
    getDetails();
    measurementController.text = "Preferred Measurement";
    heightController.text = "Height";
    weightController.text = "Weight";
    activityController.text = "Current Activity Level";
    mealsController.text = "0";
    super.initState();
  }

  logoutUser() async {
    await StorageService.clearLoginData();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        title: headingBig("My Profile"),
        backgroundColor: backgroundLight,
        actions: [
          TextButton(
            onPressed: () {
              logoutUser();
            },
            child: Text("Logout", style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
      body: Container(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Step 2",
                  style: TextStyle(color: textLightest(), fontSize: 16),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 7,
                      width: 40,
                      decoration: borderRadius(textLightest(), 4),
                    ),
                    SizedBox(width: 10),
                    Container(
                      height: 7,
                      width: 40,
                      decoration: borderRadius(primaryColor, 4),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              //height: 90,
              margin: EdgeInsets.all(20),
              decoration: borderRadius(lightBackgroundColor(), 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image.asset("assets/images/user_demo.png", height: 80),
                  // SizedBox(height: 10),
                  // SmallHeading("Preferred Measurement"),
                  // GestureDetector(
                  //   onTap: () {
                  //     showPicker(context, (int index) {
                  //       setState(() {
                  //         measurementController.text = measurements[index];
                  //         heightController.text = "Height";
                  //         weightController.text = "Weight";
                  //       });
                  //     }, measurements);
                  //   },
                  //   child: Container(
                  //     height: 60,
                  //     padding: EdgeInsets.symmetric(horizontal: 15),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Text(measurementController.text),
                  //         Icon(
                  //           Icons.keyboard_arrow_down_outlined,
                  //           color: textLightest(),
                  //         ),
                  //       ],
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: white,
                  //       borderRadius: BorderRadius.all(Radius.circular(15)),
                  //       border: Border.all(color: dividerColor),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 10),
                  // SmallHeading("Diet Title"),
                  // CustomEditText(
                  //   true,
                  //   15,
                  //   dietTitleController,
                  //   TextInputType.text,
                  //   "Diet Title",
                  // ),
                  SizedBox(height: 10),
                  SmallHeading(
                    "Height (" +
                        (measurementController.text == measurements[1]
                            ? "cm)"
                            : "Feet/Inch)"),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDecimalPicker(
                        context,
                        (value) {
                          setState(() {
                            heightController.text = value;
                            // print("Selected height: $value");
                          });
                        },
                        measurementController.text == measurements[1] ? 100 : 0,
                        measurementController.text == measurements[1]
                            ? 121
                            : 10,
                        measurementController.text == measurements[1] ? 10 : 12,
                      );
                    },
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(heightController.text),
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
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallHeading("Current Activity Level"),
                      IconButton(
                        onPressed: () {
                          showActivityLevelInfoDialog();
                        },
                        icon: Icon(Icons.info, color: textMedium()),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      showPicker(context, (int index) {
                        setState(() {
                          activityController.text = activityLevels[index];
                        });
                      }, activityLevels);
                    },
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(activityController.text),
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
                  SizedBox(height: 10),
                  SmallHeading(
                    "Weight (" +
                        (measurementController.text == measurements[1]
                            ? "kg)"
                            : "lbs)"),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDecimalPicker(
                        context,
                        (value) {
                          setState(() {
                            weightController.text = value;
                            // print("Selected height: $value");
                          });
                        },
                        measurementController.text == measurements[1]
                            ? 45
                            : 100,
                        measurementController.text == measurements[1]
                            ? 91
                            : 200,
                        measurementController.text == measurements[1] ? 10 : 10,
                      );
                    },
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(weightController.text),
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
                  SizedBox(height: 10),
                  // SmallHeading("Number of meals"),
                  // GestureDetector(
                  //   onTap: () {
                  //     showPicker(context, (int index) {
                  //       setState(() {
                  //         mealsController.text = meals[index];
                  //       });
                  //     }, meals);
                  //   },
                  //   child: Container(
                  //     height: 60,
                  //     padding: EdgeInsets.symmetric(horizontal: 15),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Text(mealsController.text),
                  //         Icon(
                  //           Icons.keyboard_arrow_down_outlined,
                  //           color: textLightest(),
                  //         ),
                  //       ],
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: white,
                  //       borderRadius: BorderRadius.all(Radius.circular(15)),
                  //       border: Border.all(color: dividerColor),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "We use this information to generate and deliver personalized daily recommendations tailored to you.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textMedium()),
              ),
            ),
            SizedBox(height: 20),
            DefaultButton("Submit", () {
              _editPreferences();
            }, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }

  bool _isLoading = false;

  void _editPreferences() async {
    if (dietTitleController.text == "" ||
        measurementController.text == "Preferred Measurement" ||
        heightController.text == "Height" ||
        weightController.text == "Weight" ||
        activityController.text == "Current Activity Level" ||
        mealsController.text == "0") {
      showToast("Please fill all the fields");
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    Map<String, dynamic> dataToPost = {
      // "title": dietTitleController.text,
      "preferred_measurement": measurementController.text,
      "no_of_meals": mealsController.text,
      "activity_level": activityLevelValues[activityController.text],
    };
    if (measurementController.text.toLowerCase() == "imperial") {
      //dataToPost["height_feet"] = ;

      var parts = [];
      if (heightController.text.contains("\"")) {
        parts = heightController.text
            .replaceAll("\"", "")
            .replaceAll("'", "")
            .split(" ");
      } else {
        parts = heightController.text.split(".");
      }

      dataToPost["height_in"] =
          (int.parse(parts[0]) * 12) +
          int.parse(parts[1]); //parts.length > 1 ? parts[1] : "0";
      dataToPost["weight_lbs"] = weightController.text;
    } else {
      dataToPost["height_cm"] = heightController.text;
      dataToPost["weight_kg"] = weightController.text;
    }

    print(dataToPost);
    //return;
    try {
      setState(() {
        _isLoading = true;
      });
      Map data = await apiService.putRequest(
        editDietaryPreferences + userDetail.dietaryPreference.id.toString(),
        {},
        dataToPost,
      );
      print(data['dietary_preference']);
      setState(() async {
        LoginResponse response = LoginResponse(
          profile: UserProfile.fromJson(data['profile']),
          dietaryPreference: DietaryPreference.fromJson(
            data['dietary_preference'],
          ),
          accessToken: userDetail.accessToken,
        );

        await StorageService.saveLoginData(response);
        _isLoading = false;

        _editCaloriesToMaintain();
      });
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
      }
      setState(() => _isLoading = false);
    }
  }

  void _editCaloriesToMaintain() async {
    userDetail = (await StorageService.getLoginData())!;
    final calories = calculateCaloriesToMaintainWeight(
      preferredMeasurement: userDetail!.profile.preferredMeasurement,
      weightKg: userDetail.dietaryPreference.weightKg.toDouble(),
      weightLbs: userDetail.dietaryPreference.weightLbs.toDouble(),
      heightCm: userDetail.dietaryPreference.heightCm.toDouble(),
      heightIn: userDetail.dietaryPreference.heightIn.toDouble(),
      age: userDetail.dietaryPreference.age,
      gender: userDetail.profile.gender,
      activityLevel: userDetail.dietaryPreference.activityLevel,
    );

    final ApiService apiService = ApiService();

    Map<String, dynamic> dataToPost = {
      "avg_calorie_to_maintain_weight": calories,
      "daily_calorie_intake": calories,
    };
    //print(dataToPost);
    //return;
    try {
      setState(() {
        _isLoading = true;
      });
      Map data = await apiService.putRequest(
        editDietaryPreferences + userDetail.dietaryPreference.id.toString(),
        {},
        dataToPost,
      );

      setState(() async {
        LoginResponse response = LoginResponse(
          profile: UserProfile.fromJson(data['profile']),
          dietaryPreference: DietaryPreference.fromJson(
            data['dietary_preference'],
          ),
          accessToken: userDetail.accessToken,
        );

        await StorageService.saveLoginData(response);
        _isLoading = false;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyNutritionTarget(saveAndDashboard: true),
          ),
        );
      });
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
      }
      setState(() => _isLoading = false);
    }
  }

  int calculateCaloriesToMaintainWeight({
    required String preferredMeasurement,
    required double weightKg,
    required double weightLbs,
    required double heightCm,
    required double heightIn,
    required int age,
    required String gender,
    required double activityLevel,
  }) {
    double bmr = 0;
    //print(activityLevel);
    if (preferredMeasurement.toLowerCase() == "imperial") {
      //imperials Formula
      if (gender.toLowerCase() == "male") {
        bmr = (4.536 * weightLbs) + (15.88 * heightIn) - (5 * age) + 5;
      } else {
        bmr = (4.536 * weightLbs) + (15.88 * heightIn) - (5 * age) - 161;
      }
    } else {
      // Metric Formula
      if (gender.toLowerCase() == "male") {
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
      } else {
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
      }
    }

    return (bmr * activityLevel).toInt();
  }

  showActivityLevelInfoDialog() {
    infoDialog(
      context,
      "Activity Level Info",
      Column(
        children: [
          //Level 1---------------------
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                child: Image.asset(imagesPath + "activity1.png"),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Sedentary"),
                    SmallHeading(
                      "Little or no exercise; mostly sitting or desk work.",
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: dividerColor, height: 20),
          //Level 2---------------------
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                child: Image.asset(imagesPath + "activity2.png"),
              ),

              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Light Active"),
                    SmallHeading("Light exercise/sports 1-3 days/week."),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: dividerColor, height: 20),
          //Level 3---------------------
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                child: Image.asset(imagesPath + "activity3.png"),
              ),

              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Moderately Active"),
                    SmallHeading("Moderate exercise/sports 3-5 days/week."),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: dividerColor, height: 20),
          //Level 4---------------------
          Row(
            children: [
              Container(
                width: 80,
                child: Image.asset(imagesPath + "activity4.png"),
                height: 80,
              ),

              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Very Active"),
                    SmallHeading(
                      "Hard exercise/sports 6-7 days/week or a physical job.",
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: dividerColor, height: 20),
          //Level 5---------------------
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                child: Image.asset(imagesPath + "activity5.png"),
              ),

              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Extremely Active"),
                    SmallHeading(
                      "Very hard daily training and physically demanding work",
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: dividerColor, height: 20),
        ],
      ),
    );
  }
}
