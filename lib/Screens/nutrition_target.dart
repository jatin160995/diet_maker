import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Models/user_profile.dart';
import 'package:diet_maker/Screens/dashboard.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/utils/globals.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:diet_maker/widgets/single_item_desc.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class MyNutritionTarget extends StatefulWidget {
  bool saveAndDashboard;
  MyNutritionTarget({this.saveAndDashboard = false, super.key});

  @override
  State<MyNutritionTarget> createState() => _MyNutritionTargetState();
}

class _MyNutritionTargetState extends State<MyNutritionTarget> {
  late LoginResponse userDetail;

  List<String> physicalGoal = ["Lose Weight", "Maintain Weight", "Gain Weight"];

  List<String> gainSurplusImperial = [
    "+0.5 lbs / Week",
    "+1.0 lbs / Week",
    "+1.5 lbs / Week",
    "+2.0 lbs / Week",
  ];
  List<String> gainSurplusMetric = [
    "+0.23 kg / Week",
    "+0.45 kg / Week",
    "+0.68 kg / Week",
    "+0.91 kg / Week",
  ];
  List<String> loseDeficitImperial = [
    "-0.5 lbs / Week",
    "-1.0 lbs / Week",
    "-1.5 lbs / Week",
    "-2.0 lbs / Week",
  ];
  List<String> loseDeficitMetric = [
    "-0.23 kg / Week",
    "-0.45 kg / Week",
    "-0.68 kg / Week",
    "-0.91 kg / Week",
  ];
  List<String> deficitPercentages = [
    "-10%",
    "-11%",
    "-12%",
    "-13%",
    "-14%",
    "-15%",
    "-16%",
    "-17%",
    "-18%",
    "-19%",
    "-20%",
    "-21%",
    "-22%",
    "-23%",
    "-24%",
    "-25%",
    "-26%",
    "-27%",
    "-28%",
    "-29%",
    "-30%",
  ];
  List<String> surpluPercentages = [
    "+10%",
    "+11%",
    "+12%",
    "+13%",
    "+14%",
    "+15%",
    "+16%",
    "+17%",
    "+18%",
    "+19%",
    "+20%",
    "+21%",
    "+22%",
    "+23%",
    "+24%",
    "+25%",
    "+26%",
    "+27%",
    "+28%",
    "+29%",
    "+30%",
  ];

  List<int> caloriesDifferenceList = [250, 500, 750, 1000];
  int selectedDifference = 0;
  List<String> optionToLoad = [];

  int caloriesToMaintain = 0;
  int dailyCalorieDeficitOrSurplus = 0;
  int caloriesToReachGoal = 0;
  int selectedPhysicalGoal = 0; // 0 : Lose, 1 : Maintain, 2 Gain
  int caloriesDifference = 0;
  //String percentageOrWeight = "";

  TextEditingController physicalGoalController = TextEditingController();
  TextEditingController weeklyGoalController = TextEditingController();
  //
  TextEditingController percentageOrWeightController = TextEditingController();
  List<String> percentageOrWeightValues = ['Weight', 'Percentage'];

  double weight = 0;

  //
  bool isImperial = false;

  getDetails() async {
    userDetail = (await StorageService.getLoginData())!;
    //showToast(userDetail.dietaryPreference.primaryMealPlanId.toString());
    physicalGoalController.text = userDetail.dietaryPreference.physicalGoal;

    caloriesToMaintain =
        userDetail.dietaryPreference.avgCalorieToMaintainWeight;
    dailyCalorieDeficitOrSurplus =
        userDetail.dietaryPreference.dailyCalorieDeficitOrSurplus;

    if (userDetail.dietaryPreference.physicalGoal == "Maintain Weight") {
      selectedPhysicalGoal = 1;
      caloriesToReachGoal = caloriesToMaintain;
    } else if (userDetail.dietaryPreference.physicalGoal == "Lose Weight") {
      selectedPhysicalGoal = 0;
      caloriesToReachGoal = caloriesToMaintain - dailyCalorieDeficitOrSurplus;
    } else {
      selectedPhysicalGoal = 2;
      caloriesToReachGoal = caloriesToMaintain + dailyCalorieDeficitOrSurplus;
    }
    weight = double.parse(
      await getUserWeight(userDetail.profile.preferredMeasurement),
    );
    percentageOrWeightController.text =
        userDetail.dietaryPreference.percentageOrWeight;
    //
    proteinPer =
        userDetail.dietaryPreference.proteinPercentage.toDouble() == 0
            ? 30
            : userDetail.dietaryPreference.proteinPercentage.toDouble();
    proteinGrams = userDetail.dietaryPreference.proteinRequired.toDouble();
    //
    carbsPer =
        userDetail.dietaryPreference.carbohydratePercentage.toDouble() == 0
            ? 50
            : userDetail.dietaryPreference.carbohydratePercentage.toDouble();
    carbsGrams = userDetail.dietaryPreference.carbohydrateRequired.toDouble();
    //
    fatsPer =
        userDetail.dietaryPreference.fatPercentage.toDouble() == 0
            ? 20
            : userDetail.dietaryPreference.fatPercentage.toDouble();
    carbsGrams = userDetail.dietaryPreference.fatRequired.toDouble();

    caloriesDifference = userDetail.dietaryPreference.avgCalorieDifference;
    if (selectedPhysicalGoal == 0 || selectedPhysicalGoal == 2) {
      weeklyGoalController.text =
          userDetail.dietaryPreference.dailyCalorieDeficitOrSurplusLabel;
    }

    loadValues();
    isImperial =
        userDetail.profile.preferredMeasurement.toLowerCase() == "imperial"
            ? true
            : false;
    print(userDetail.dietaryPreference.toJson());
    caloriesToReachGoal = userDetail.dietaryPreference.dailyCalorieIntake;
    // Future.delayed(Duration(milliseconds: 2500), () {
    //   calculateCaloriesToReachGoal();
    // });

    setState(() {});
    getNutritionTargetVariables();
  }

  loadValues() {
    if (physicalGoalController.text == "Lose Weight" &&
        userDetail.profile.preferredMeasurement.toLowerCase() == "metric") {
      optionToLoad = loseDeficitMetric;
    } else if (physicalGoalController.text == "Lose Weight" &&
        userDetail.profile.preferredMeasurement.toLowerCase() == "imperial") {
      optionToLoad = loseDeficitImperial;
    } else if (physicalGoalController.text == "Gain Weight" &&
        userDetail.profile.preferredMeasurement.toLowerCase() == "metric") {
      optionToLoad = gainSurplusMetric;
    } else {
      optionToLoad = gainSurplusImperial;
    }
    if (physicalGoalController.text == "Lose Weight" &&
        percentageOrWeightController.text == "Percentage") {
      optionToLoad = deficitPercentages;
    }
    if (physicalGoalController.text == "Gain Weight" &&
        percentageOrWeightController.text == "Percentage") {
      optionToLoad = surpluPercentages;
    }

    onProteinChanged(proteinPer);
    onCarbsChanged(carbsPer);
    onFatsChanged(fatsPer);
    setState(() {});
  }

  calculateCaloriesToReachGoal() {
    // showToast(selectedDifference.toString());
    if (percentageOrWeightController.text == "Weight") {
      if (selectedPhysicalGoal == 0) {
        caloriesToReachGoal =
            caloriesToMaintain - caloriesDifferenceList[selectedDifference];
        caloriesDifference = caloriesDifferenceList[selectedDifference];
      }
      if (selectedPhysicalGoal == 1) {
        caloriesToReachGoal = caloriesToMaintain;
      }
      if (selectedPhysicalGoal == 2) {
        caloriesToReachGoal =
            caloriesToMaintain + caloriesDifferenceList[selectedDifference];
        caloriesDifference = caloriesDifferenceList[selectedDifference];
      }
    }
    if (physicalGoalController.text == "Lose Weight" &&
        percentageOrWeightController.text == "Percentage") {
      caloriesToReachGoal =
          caloriesToMaintain -
          (caloriesToMaintain * ((selectedDifference + 10) / 100)).toInt();
      caloriesDifference =
          -(caloriesToMaintain * ((selectedDifference + 10) / 100)).toInt();
    }
    if (physicalGoalController.text == "Gain Weight" &&
        percentageOrWeightController.text == "Percentage") {
      caloriesToReachGoal =
          caloriesToMaintain +
          (caloriesToMaintain * ((selectedDifference + 10) / 100)).toInt();
      caloriesDifference =
          (caloriesToMaintain * ((selectedDifference + 10) / 100)).toInt();
    }
    // showToast(
    //   caloriesToReachGoal.toString() + "--" + caloriesDifference.toString(),
    // );

    setState(() {});
  }

  @override
  void initState() {
    getDetails();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: DefaultButton("Save", () {
          _editPreferences();
        }, isLoading: _isLoading),
      ),
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        title: heading("My Nutrition Targets"),
        backgroundColor: backgroundColor(),
      ),
      body:
          isLoadingNutritionVariables
              ? loader("Loading Your Nutrition Targets")
              : ListView(
                padding: EdgeInsets.all(20),
                children: [
                  heading("Physical Goal"),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: borderRadius(white, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //-----------------------------------------------------
                        SmallHeading("Physical Goal"),
                        GestureDetector(
                          onTap: () {
                            showPicker(context, (int index) {
                              setState(() {
                                physicalGoalController.text =
                                    physicalGoal[index];
                                selectedPhysicalGoal = index;
                                selectedDifference = 0;
                              });
                              caloriesDifference = 0;
                              weeklyGoalController.clear();
                              loadValues();
                            }, physicalGoal);
                          },
                          child: Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(physicalGoal[selectedPhysicalGoal]),
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
                        ////////////////////////////////////////////////////////////
                        selectedPhysicalGoal != 1
                            ? SmallHeading(
                              "Deficit/Surplus by Percentage or Weight",
                            )
                            : Container(),
                        selectedPhysicalGoal != 1
                            ? GestureDetector(
                              onTap: () {
                                showPicker(context, (int index) {
                                  setState(() {
                                    percentageOrWeightController.text =
                                        percentageOrWeightValues[index];
                                    selectedDifference = 0;
                                    weeklyGoalController.text = "";
                                    //selectedDifference = index;
                                  });
                                  calculateCaloriesToReachGoal();
                                  loadValues();
                                }, percentageOrWeightValues);
                              },
                              child: Container(
                                height: 60,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(percentageOrWeightController.text),
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
                            )
                            : Container(),
                        ////////////////////////////////////////////////////////////
                        selectedPhysicalGoal != 1
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SmallHeading(
                                  "Choose Daily Calorie Surplus/Deficit",
                                ),
                                IconButton(
                                  onPressed: () {
                                    bool isImperial =
                                        userDetail.profile.preferredMeasurement
                                            .toLowerCase() ==
                                        "imperial";
                                    bool isGain = selectedPhysicalGoal == 2;
                                    bool isPercentage =
                                        percentageOrWeightController.text ==
                                        "Percentage";
                                    List<String> percentageList =
                                        isGain
                                            ? caloriesHeadingsSurplusPercentage
                                            : caloriesHeadingsDeficitPercentage;
                                    // print(selectedPhysicalGoal);
                                    String unit =
                                        isImperial
                                            ? isPercentage
                                                ? "%"
                                                : "lbs"
                                            : isPercentage
                                            ? "%"
                                            : "kg";
                                    showInfoDialog(
                                      isImperial
                                          ? isGain
                                              ? "Calorie Surplus Guidelines ($unit)"
                                              : "Calorie Deficit Guidelines ($unit)"
                                          : isGain
                                          ? "Calorie Surplus Guidelines ($unit)"
                                          : "Calorie Deficit Guidelines ($unit)",
                                      caloriesImages,
                                      isImperial
                                          ? isPercentage
                                              ? percentageList
                                              : caloriesHeadings
                                          : isPercentage
                                          ? percentageList
                                          : caloriesHeadingsKG,
                                      caloriesSubtitle,
                                      isGain
                                          ? "*Recommended to start with a low surplus"
                                          : "*Recommended to start with a low deficit",
                                    );
                                  },
                                  icon: Icon(Icons.info, color: textMedium()),
                                ),
                              ],
                            )
                            : Container(),
                        selectedPhysicalGoal != 1
                            ? GestureDetector(
                              onTap: () {
                                showPicker(context, (int index) {
                                  setState(() {
                                    weeklyGoalController.text =
                                        optionToLoad[index];
                                    selectedDifference = index;
                                  });
                                  calculateCaloriesToReachGoal();
                                  loadValues();
                                }, optionToLoad);
                              },
                              child: Container(
                                height: 60,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(weeklyGoalController.text),
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
                            )
                            : Container(),
                        SizedBox(height: 15),
                        Text(
                          "Daily Maintenance Calories",
                          style: TextStyle(color: textLightest(), fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          caloriesToMaintain.toString() + " kcal",
                          style: TextStyle(
                            color: textDark(),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        selectedPhysicalGoal != 1
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  "Daily Goal Calories",
                                  style: TextStyle(
                                    color: textLightest(),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  caloriesToReachGoal.toString() + " kcal",
                                  style: TextStyle(
                                    color: textDark(),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                            : Container(),
                        SizedBox(height: 8),
                        Text(
                          "Calorie Difference",
                          style: TextStyle(color: textLightest(), fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          caloriesDifference.toString() + " kcal",
                          style: TextStyle(
                            color: textDark(),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: heading("Daily Macronutrient Composition"),
                      ),
                      IconButton(
                        onPressed: () {
                          showInfoDialog(
                            "Acceptable Macronutrient Distribution Ranges*",
                            macronitrientsImages,
                            macronitrientsHeadings,
                            macronitrientsSubtitles,
                            "Suggested by the USDA*",
                          );
                        },
                        icon: Icon(Icons.info, color: textMedium()),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    //decoration: borderRadius(white, 8),
                    //padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        /*-----------------------Protein------------------*/
                        Container(
                          decoration: borderRadius(white, 10),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  headingSmall(
                                    "Protein: " +
                                        proteinPer.toStringAsFixed(0) +
                                        "%",
                                  ),
                                  Text(
                                    "Daily Amount: " +
                                        proteinGrams.toStringAsFixed(1) +
                                        "g",
                                    style: TextStyle(
                                      color: textLightest(),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Slider(
                                value: proteinPer,
                                min: 0,
                                max: 100,
                                divisions: 100,
                                thumbColor: protien,
                                activeColor: protien,
                                inactiveColor: dividerColor,
                                label: "${proteinPer.toStringAsFixed(0)}%",
                                onChanged: (value) => onProteinChanged(value),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (proteinGrams / weight).toStringAsFixed(
                                              2,
                                            ) +
                                            (userDetail
                                                        .profile
                                                        .preferredMeasurement
                                                        .toLowerCase() ==
                                                    "imperial"
                                                ? " g/lb"
                                                : " g/kg"),
                                      ),
                                      Text(
                                        isImperial
                                            ? "per lb body weight"
                                            : "per kg body weight",
                                        style: TextStyle(
                                          color: textLightest(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        (proteinGrams /
                                                    userDetail
                                                        .dietaryPreference
                                                        .noOfMeals)
                                                .toStringAsFixed(2) +
                                            "g",
                                      ),
                                      Text(
                                        "avg. per meal",
                                        style: TextStyle(
                                          color: textLightest(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        /*-----------------------Carbs------------------*/
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          decoration: borderRadius(white, 10),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  headingSmall(
                                    "Carbs: " +
                                        carbsPer.toStringAsFixed(0) +
                                        "%",
                                  ),
                                  Text(
                                    "Daily Amount: " +
                                        carbsGrams.toStringAsFixed(1) +
                                        "g",
                                    style: TextStyle(
                                      color: textLightest(),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Slider(
                                value: carbsPer,
                                min: 0,
                                max: 100,
                                divisions: 100,
                                thumbColor: carbs,
                                activeColor: carbs,
                                inactiveColor: dividerColor,
                                label: "${carbsPer.toStringAsFixed(0)}%",
                                onChanged: (value) => onCarbsChanged(value),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (carbsGrams / weight).toStringAsFixed(
                                              2,
                                            ) +
                                            (userDetail
                                                        .profile
                                                        .preferredMeasurement
                                                        .toLowerCase() ==
                                                    "imperial"
                                                ? " g/lb"
                                                : " g/kg"),
                                      ),
                                      Text(
                                        isImperial
                                            ? "per lb body weight"
                                            : "per kg body weight",
                                        style: TextStyle(
                                          color: textLightest(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        (carbsGrams /
                                                    userDetail
                                                        .dietaryPreference
                                                        .noOfMeals)
                                                .toStringAsFixed(2) +
                                            "g",
                                      ),
                                      Text(
                                        "avg. per meal",
                                        style: TextStyle(
                                          color: textLightest(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        /*-----------------------Fats------------------*/
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          decoration: borderRadius(white, 10),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  headingSmall(
                                    "Fat: " + fatsPer.toStringAsFixed(0) + "%",
                                  ),
                                  Text(
                                    "Daily Amount: " +
                                        fatsGrams.toStringAsFixed(1) +
                                        "g",
                                    style: TextStyle(
                                      color: textLightest(),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Slider(
                                value: fatsPer,
                                min: 0,
                                max: 100,
                                divisions: 100,
                                thumbColor: fats,
                                activeColor: fats,
                                inactiveColor: dividerColor,
                                label: "${fatsPer.toStringAsFixed(0)}%",
                                onChanged: (value) => onFatsChanged(value),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (fatsGrams / weight).toStringAsFixed(
                                              2,
                                            ) +
                                            (userDetail
                                                        .profile
                                                        .preferredMeasurement
                                                        .toLowerCase() ==
                                                    "imperial"
                                                ? " g/lb"
                                                : " g/kg"),
                                      ),
                                      Text(
                                        isImperial
                                            ? "per lb body weight"
                                            : "per kg body weight",
                                        style: TextStyle(
                                          color: textLightest(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        (fatsGrams /
                                                    userDetail
                                                        .dietaryPreference
                                                        .noOfMeals)
                                                .toStringAsFixed(2) +
                                            "g",
                                      ),
                                      Text(
                                        "avg. per meal",
                                        style: TextStyle(
                                          color: textLightest(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        /*-----------------------Calories------------------*/
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          decoration: borderRadius(white, 10),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  headingSmall("Calories"),
                                  Text(
                                    "Daily Amount: " +
                                        caloriesToReachGoal.toStringAsFixed(1) +
                                        " kcal",
                                    style: TextStyle(
                                      color: textLightest(),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    flex: proteinPer.round(),
                                    child: Container(
                                      height: 8,
                                      color: protien, // Protein color
                                    ),
                                  ),
                                  Expanded(
                                    flex: carbsPer.round(),
                                    child: Container(
                                      height: 8,
                                      color: carbs, // Carbs color
                                    ),
                                  ),
                                  Expanded(
                                    flex: fatsPer.round(),
                                    child: Container(
                                      height: 8,
                                      color: fats, // Fats color
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (caloriesToReachGoal / weight)
                                                .toStringAsFixed(2) +
                                            (userDetail
                                                        .profile
                                                        .preferredMeasurement
                                                        .toLowerCase() ==
                                                    "imperial"
                                                ? " cal/lb"
                                                : " cal/kg"),
                                      ),
                                      Text(
                                        isImperial
                                            ? "per lb body weight"
                                            : "per kg body weight",
                                        style: TextStyle(
                                          color: textLightest(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        (caloriesToReachGoal /
                                                    userDetail
                                                        .dietaryPreference
                                                        .noOfMeals)
                                                .toStringAsFixed(2) +
                                            "g",
                                      ),
                                      Text(
                                        "avg. per meal",
                                        style: TextStyle(
                                          color: textLightest(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  double proteinPer = 30;
  double carbsPer = 50;
  double fatsPer = 20;

  double proteinGrams = 0;
  double carbsGrams = 0;
  double fatsGrams = 0;

  double proteinLimitMetric = 0.8;
  double proteinLimitImperial = 0.36;

  // Slider bounds (% of calories)
  double minProteinPer = 10;
  double maxProteinPer = 80;
  double minCarbsPer = 0;
  double maxCarbsPer = 70;
  double minFatsPer = 20;
  double maxFatsPer = 90;

  void onProteinChanged(double value) {
    setState(() {
      // Clamp protein %
      proteinPer = value.clamp(minProteinPer, maxProteinPer);

      // Remaining % available for carbs+fats
      double remaining = (100 - proteinPer).clamp(0.0, 100.0);

      // keep previous ratio between carbs and fats when protein is changed
      double totalCF = carbsPer + fatsPer;
      if (totalCF <= 0) {
        // fallback if both were zero
        carbsPer = (remaining * 0.6).clamp(minCarbsPer, maxCarbsPer);
        fatsPer = (remaining * 0.4).clamp(minFatsPer, maxFatsPer);
      } else {
        double ratio = carbsPer / totalCF;
        carbsPer = (remaining * ratio).clamp(minCarbsPer, maxCarbsPer);
        fatsPer = (remaining * (1 - ratio)).clamp(minFatsPer, maxFatsPer);
      }

      // final adjustment to ensure sum is exactly 100 (avoid rounding drift)
      double sum = proteinPer + carbsPer + fatsPer;
      if (sum != 100) {
        double diff = 100 - sum;
        // apply diff to carbs first (as a neutral buffer), then fats
        carbsPer = (carbsPer + diff).clamp(minCarbsPer, maxCarbsPer);
        // if still mismatch, adjust fats
        sum = proteinPer + carbsPer + fatsPer;
        if (sum != 100) {
          fatsPer = (100 - proteinPer - carbsPer).clamp(minFatsPer, maxFatsPer);
        }
      }

      _recalculateMacros();
    });
  }

  void onCarbsChanged(double value) {
    setState(() {
      // Set carbs under bounds
      carbsPer = value.clamp(minCarbsPer, maxCarbsPer);

      // Protein stays fixed. Fats = remainder
      double remainingForFats = (100 - proteinPer - carbsPer);

      // If remainingForFats violates fats bounds, clamp and adjust carbs accordingly
      if (remainingForFats < minFatsPer) {
        fatsPer = minFatsPer;
        // recalc carbs so sum is 100
        carbsPer = (100 - proteinPer - fatsPer).clamp(minCarbsPer, maxCarbsPer);
      } else if (remainingForFats > maxFatsPer) {
        fatsPer = maxFatsPer;
        carbsPer = (100 - proteinPer - fatsPer).clamp(minCarbsPer, maxCarbsPer);
      } else {
        fatsPer = remainingForFats;
      }

      // final normalization (fix tiny floating point errors)
      double sum = proteinPer + carbsPer + fatsPer;
      if (sum != 100) {
        fatsPer = (100 - proteinPer - carbsPer).clamp(minFatsPer, maxFatsPer);
      }

      _recalculateMacros();
    });
  }

  void onFatsChanged(double value) {
    setState(() {
      // Set fats under bounds
      fatsPer = value.clamp(minFatsPer, maxFatsPer);

      // Protein stays fixed. Carbs = remainder
      double remainingForCarbs = (100 - proteinPer - fatsPer);

      // If remainingForCarbs violates carbs bounds, clamp and adjust fats accordingly
      if (remainingForCarbs < minCarbsPer) {
        carbsPer = minCarbsPer;
        fatsPer = (100 - proteinPer - carbsPer).clamp(minFatsPer, maxFatsPer);
      } else if (remainingForCarbs > maxCarbsPer) {
        carbsPer = maxCarbsPer;
        fatsPer = (100 - proteinPer - carbsPer).clamp(minFatsPer, maxFatsPer);
      } else {
        carbsPer = remainingForCarbs;
      }

      // final normalization (fix tiny floating point errors)
      double sum = proteinPer + carbsPer + fatsPer;
      if (sum != 100) {
        carbsPer = (100 - proteinPer - fatsPer).clamp(minCarbsPer, maxCarbsPer);
      }

      _recalculateMacros();
    });
  }

  void _recalculateMacros() {
    proteinGrams = (proteinPer / 100) * caloriesToReachGoal / 4;
    carbsGrams = (carbsPer / 100) * caloriesToReachGoal / 4;
    fatsGrams = (fatsPer / 100) * caloriesToReachGoal / 9;

    // Enforce minimum protein requirement by bodyweight
    double weight =
        userDetail.dietaryPreference.weightKg > 0
            ? userDetail.dietaryPreference.weightKg
            : userDetail.dietaryPreference.weightLbs.toDouble();

    bool isMetric =
        userDetail.profile.preferredMeasurement.toLowerCase() == "metric";
    double minProteinGrams =
        isMetric
            ? proteinLimitMetric * userDetail.dietaryPreference.weightKg
            : proteinLimitImperial * userDetail.dietaryPreference.weightLbs;

    if (proteinGrams < minProteinGrams) {
      proteinGrams = minProteinGrams;
      // adjust percentages accordingly
      proteinPer = (proteinGrams * 4 / caloriesToReachGoal) * 100;
      double remaining = 100 - proteinPer;
      double ratio = carbsPer / (carbsPer + fatsPer);
      carbsPer = (remaining * ratio).clamp(minCarbsPer, maxCarbsPer);
      fatsPer = (remaining * (1 - ratio)).clamp(minFatsPer, maxFatsPer);
    }
  }

  bool _isLoading = false;

  void _editPreferences() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    Map<String, dynamic> dataToPost = {
      "physical_goal": physicalGoalController.text,
      "avg_calorie_to_maintain_weight": caloriesToMaintain,
      "daily_calorie_intake": caloriesToReachGoal,
      "protein_percentage": proteinPer.toInt(),
      "carbohydrate_percentage": carbsPer.toInt(),
      "fat_percentage": fatsPer.toInt(),
      "protein_required": proteinGrams.toInt(),
      "carbohydrate_required": carbsGrams.toInt(),
      "fat_required": fatsGrams.toInt(),
      "daily_calorie_deficit_or_surplus_label": weeklyGoalController.text,
      "percentage_or_weight": percentageOrWeightController.text,
    };
    if (selectedPhysicalGoal == 0) {
      dataToPost['daily_calorie_deficit_or_surplus'] = -caloriesDifference;
      dataToPost['avg_calorie_difference'] = -caloriesDifference;
    } else if (selectedPhysicalGoal == 2) {
      dataToPost['daily_calorie_deficit_or_surplus'] = caloriesDifference;
      dataToPost['avg_calorie_difference'] = caloriesDifference;
    } else {
      dataToPost['daily_calorie_deficit_or_surplus'] = 0;
      dataToPost['avg_calorie_difference'] = 0;
    }
    if (percentageOrWeightController.text == "Percentage") {
      if (selectedPhysicalGoal == 2) {
        dataToPost['daily_calorie_deficit_or_surplus'] =
            selectedDifference + 10;
        dataToPost['avg_calorie_difference'] = caloriesDifference;
      } else if (selectedPhysicalGoal == 0) {
        dataToPost['daily_calorie_deficit_or_surplus'] =
            -(selectedDifference + 10);
        dataToPost['avg_calorie_difference'] = caloriesDifference;
      }
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
        showToast("Nutrition Target Updated");
        //showToast(data['dietary_preference'].toString());
        if (widget.saveAndDashboard) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
        }
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

  List<String> caloriesImages = [
    "calorie1.png",
    "calorie2.png",
    "calorie3.png",
    "calorie4.png",
  ];

  List<String> caloriesHeadings = [
    "0.5 lbs/week",
    "1.0 lbs/week",
    "1.5 lbs/week",
    "2.0 lbs/week",
  ];
  List<String> caloriesHeadingsKG = [
    "0.23 kg/week",
    "0.45 kg/week",
    "0.68 kg/week",
    "0.91 kg/week",
  ];
  List<String> caloriesHeadingsDeficitPercentage = [
    "10-15% Calories Deficit",
    "16-20% Calories Deficit",
    "21-24% Calories Deficit",
    "25-30% Calories Deficit",
  ];
  List<String> caloriesHeadingsSurplusPercentage = [
    "10-15% Calories Surplus",
    "16-20% Calories Surplus",
    "21-24% Calories Surplus",
    "25-30% Calories Surplus",
  ];
  List<String> caloriesSubtitle = [
    "= Moderately Low",
    "= Moderate",
    "= Moderately High",
    "= High",
  ];

  List<String> macronitrientsImages = ["protein.png", "carbs.png", "fat.png"];
  List<String> macronitrientsHeadings = ["Protein", "Carbohydrates", "Fat"];
  List<String> macronitrientsSubtitles = [
    "10-35% of calories",
    "45-65% of calories",
    "20-35% of calories",
  ];

  showInfoDialog(
    String title,
    List<String> images,
    List<String> titles,
    List<String> subtitle,
    String note,
  ) {
    List<Widget> widgets = [];
    for (int i = 0; i < images.length; i++) {
      widgets.add(
        Column(
          children: [
            Row(
              children: [
                Container(
                  height: 75,
                  width: 75,
                  padding: EdgeInsets.all(10),
                  child: Image.asset(imagesPath + images[i]),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [heading(titles[i]), SmallHeading(subtitle[i])],
                  ),
                ),
              ],
            ),
            Divider(color: dividerColor, height: 20),
          ],
        ),
      );
    }
    widgets.add(
      Container(
        margin: EdgeInsets.symmetric(horizontal: 50),
        child: Text(
          note,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
      ),
    );
    infoDialog(context, title, Column(children: widgets));
  }

  bool isLoadingNutritionVariables = false;
  Future<void> getNutritionTargetVariables() async {
    final ApiService apiService = ApiService();

    try {
      setState(() {
        isLoadingNutritionVariables = true;
      });

      Map data = await apiService.getWithToken(nutrientsVariable, {});

      setState(() {
        proteinPer = (data['proteinPer'] ?? proteinPer).toDouble();
        carbsPer = (data['carbsPer'] ?? carbsPer).toDouble();
        fatsPer = (data['fatsPer'] ?? fatsPer).toDouble();

        proteinLimitMetric =
            (data['proteinLimitMetric'] ?? proteinLimitMetric).toDouble();

        proteinLimitImperial =
            (data['proteinLimitImperial'] ?? proteinLimitImperial).toDouble();

        minProteinPer = (data['minProteinPer'] ?? minProteinPer).toDouble();
        maxProteinPer = (data['maxProteinPer'] ?? maxProteinPer).toDouble();

        minCarbsPer = (data['minCarbsPer'] ?? minCarbsPer).toDouble();
        maxCarbsPer = (data['maxCarbsPer'] ?? maxCarbsPer).toDouble();

        minFatsPer = (data['minFatsPer'] ?? minFatsPer).toDouble();
        maxFatsPer = (data['maxFatsPer'] ?? maxFatsPer).toDouble();

        // caloriesToMaintain =
        //     (data['minimum_calorie'] ?? caloriesToMaintain).toInt();
        // showToast(caloriesToMaintain.toString());
      });
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
    } finally {
      setState(() {
        isLoadingNutritionVariables = false;
      });
    }
  }
}
