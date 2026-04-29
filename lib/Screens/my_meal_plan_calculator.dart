import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Screens/AddMeal/add_meal_item.dart';
import 'package:diet_maker/Screens/AddMeal/MealPlan/edit_meal.dart';
import 'package:diet_maker/Screens/AddMeal/MealPlan/edit_meal_plan.dart';
import 'package:diet_maker/main.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:diet_maker/widgets/single_branded_food_item_desc.dart';
import 'package:diet_maker/widgets/single_item_desc.dart';
import 'package:diet_maker/widgets/single_recipe_item_desc.dart';
import 'package:diet_maker/widgets/vertical_progress.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class MyMealPlanCalculator extends StatefulWidget {
  int mealPlanId;
  MyMealPlanCalculator({this.mealPlanId = 0, super.key});

  @override
  State<MyMealPlanCalculator> createState() => _MyMealPlanCalculatorState();
}

class _MyMealPlanCalculatorState extends State<MyMealPlanCalculator>
    with RouteAware {
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);

  ExpandableController breakdownController = ExpandableController();
  ExpandableController meal1Controller = ExpandableController();

  // Login
  late LoginResponse userDetail;

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
  Future<void> didPopNext() async {
    // 👇
    debugPrint("Returned");
    _getMealPlansRequest(false);
  }

  @override
  void initState() {
    breakdownController.expanded = true;
    meal1Controller.expanded = true;
    getUserDetails();

    super.initState();
  }

  getUserDetails() async {
    userDetail = (await StorageService.getLoginData())!;
    if (widget.mealPlanId == 0) {
      widget.mealPlanId = userDetail.dietaryPreference.primaryMealPlanId;
    }

    _getMealPlansRequest(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            heading("My Meal Plan Calculator"),
            _isLoading
                ? Container()
                : Text(
                  "Plan Name: " + mealPlanFromServer['title'],
                  style: TextStyle(color: textMedium(), fontSize: 14),
                ),
          ],
        ),
        actions: [
          _isLoading
              ? Container()
              : IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditMealPlanScreen(
                            mealPlanData: mealPlanFromServer,
                          ),
                    ),
                  );
                  _getMealPlansRequest(false);
                },
                icon: Icon(Icons.edit, color: primaryColor),
              ),
        ],
      ),
      body:
          _isLoading
              ? loader("Loading meal plan...")
              : Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.all(20),
                    children: [
                      SizedBox(height: 20),
                      // GestureDetector(
                      //   onTap: () {
                      //     showGenericDialog(
                      //       context,
                      //       "Generate Meal Plan",
                      //       "This will automatically create a personalized meal plan based on your dietary preferences, calorie goals, and schedule. \n\n - The new plan will be tailored to your selected calorie target and macro distribution. \n \n Are you sure you want to continue?",
                      //       "Generate",
                      //       () async {
                      //         autoAssignMealPlan();
                      //         // print(dailyCalories);
                      //       },
                      //     );
                      //   },
                      //   child: Container(
                      //     padding: EdgeInsets.symmetric(vertical: 10),
                      //     decoration: borderRadius(primaryColor, 10),
                      //     child: Center(
                      //       child: Text(
                      //         "Auto generate Plan",
                      //         style: TextStyle(
                      //           color: white,
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Column(children: mealPlanWidgets()),
                      ////Daily Macronutrient & Calories Target---------------------------
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: borderRadius(white, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            heading("Daily Macronutrient & Calorie Target"),
                            // Text(
                            //   "No. of meals : " +
                            //       mealPlanFromServer['total_meal'].toString(),
                            //   style: TextStyle(color: textMedium()),
                            // ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                VerticalProgress(
                                  "Protein",
                                  protien,
                                  mealPlanFromServer['protein_amount']
                                      .toDouble(),
                                  mealPlanFromServer['dietary_preference']['protein_required']
                                      .toDouble(),
                                  "g",
                                ),
                                VerticalProgress(
                                  "Carbs",
                                  carbs,
                                  mealPlanFromServer['carbohydrate_amount']
                                      .toDouble(),
                                  mealPlanFromServer['dietary_preference']['carbohydrate_required']
                                      .toDouble(),
                                  "g",
                                ),
                                VerticalProgress(
                                  "Fats",
                                  fats,
                                  mealPlanFromServer['fat_amount'].toDouble(),
                                  mealPlanFromServer['dietary_preference']['fat_required']
                                      .toDouble(),
                                  "g",
                                ),
                                VerticalProgress(
                                  "Calories",
                                  calories,
                                  mealPlanFromServer['calorie_amount']
                                      .toDouble(),
                                  mealPlanFromServer['dietary_preference']['daily_calorie_intake']
                                      .toDouble(),
                                  "k",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: borderRadius(white, 8),
                        child: ExpandablePanel(
                          controller: breakdownController,
                          header: heading("Complete Nutrient Breakdown"),
                          collapsed: Container(),
                          expanded: Column(
                            children: [
                              SizedBox(height: 15),
                              Column(children: nutrientBreakdown()),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      //DefaultButton("Save", () {}),
                    ],
                  ),
                  calorieLevelWarningBar(),
                ],
              ),
    );
  }

  Widget calorieLevelWarningBar() {
    double currentCalories = mealPlanFromServer['calorie_amount'].toDouble();
    double dailyCaloriesGoal =
        mealPlanFromServer['dietary_preference']['daily_calorie_intake']
            .toDouble();
    int caloriesLevel = 0; //0: Equal, 1: More, -1: Less
    String caloriesMessage = "";
    Color barColor = Colors.blue;
    if (currentCalories < dailyCaloriesGoal) {
      caloriesLevel = -1;
      double caloriesDiff = dailyCaloriesGoal - currentCalories;
      caloriesMessage =
          caloriesDiff.toStringAsFixed(0) + "kcal under your goal";
      barColor = Colors.blue;
    }
    if (currentCalories > dailyCaloriesGoal) {
      caloriesLevel = 1;
      double caloriesDiff = currentCalories - dailyCaloriesGoal;
      caloriesMessage = caloriesDiff.toStringAsFixed(0) + "kcal over your goal";
      barColor = Colors.red;
    }
    if (currentCalories == dailyCaloriesGoal) {
      caloriesLevel = 0;
    }

    return caloriesLevel != 0
        ? Container(
          height: 25,
          color: barColor,
          child: Center(
            child: Text(
              caloriesMessage,
              style: TextStyle(color: white, fontWeight: FontWeight.bold),
            ),
          ),
        )
        : Container();
  }

  List<Widget> nutrientBreakdown() {
    List<Widget> breakdownWidgets = [];
    for (int i = 0; i < completeNutrientBreakdown.length; i++) {
      if (completeNutrientBreakdown[i]['is_primary'] == "No") {
        continue;
      }
      breakdownWidgets.add(
        nutritionBreakDownWidget(
          completeNutrientBreakdown[i]['title'],
          completeNutrientBreakdown[i]['amount'] == 0
              ? "" //+ completeNutrientBreakdown[i]['nutrient_unit_code']
              : completeNutrientBreakdown[i]['amount'].toStringAsFixed(0) +
                  completeNutrientBreakdown[i]['nutrient_unit_code'],
          completeNutrientBreakdown[i]['sub_nutrients'],
        ),
      );
    }
    return breakdownWidgets;
  }

  List<Widget> mealPlanWidgets() {
    List<Widget> mealPlanWidgetsList = [];
    for (int i = 0; i < mealPlans.length; i++) {
      mealPlanWidgetsList.add(
        Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.all(10),
          decoration: borderRadius(white, 8),
          child: ExpandablePanel(
            header: heading("Meal " + (i + 1).toString()),
            collapsed: Text(
              "Time: " + mealPlans[i]['meal_time_formatted'],
              style: TextStyle(color: textMedium()),
            ),
            expanded: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Time: " + mealPlans[i]['meal_time_formatted'],
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
                  children: brandedFoodWidget(
                    mealPlans[i]['meal_branded_foods'],
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
              ],
            ),
          ),
        ),
      );
    }
    return mealPlanWidgetsList;
  }

  List<Widget> brandedFoodWidget(List foods, int meal_id, dynamic mealPlan) {
    List<Widget> foodWidgetsList = [];
    for (int i = 0; i < foods.length; i++) {
      foodWidgetsList.add(SingleBrandedFoodItemDescription(foods[i], mealPlan));
    }

    return foodWidgetsList;
  }

  List<Widget> foodWidget(List foods, int meal_id, dynamic mealPlan) {
    List<Widget> foodWidgetsList = [];
    for (int i = 0; i < foods.length; i++) {
      foodWidgetsList.add(SingleItemDescription(foods[i], mealPlan));
    }
    foodWidgetsList.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMealItem(meal_id, mealPlan),
                ),
              );
              _getMealPlansRequest(false);
            },
            child: Container(
              decoration: borderRadius(secondryColor, 8),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                "Add Food +",
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              //print(mealPlan);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditMealScreen(
                        mealId: meal_id,
                        mealPlanId: mealPlan['meal_plan_id'],
                      ),
                ),
              );
              _getMealPlansRequest(false);
            },
            child: Container(
              decoration: borderRadius(secondryColor, 8),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                "Edit Meal",
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return foodWidgetsList;
  }

  List<Widget> recipeWidget(List recipes, int meal_id, dynamic mealPlan) {
    List<Widget> foodWidgetsList = [];
    for (int i = 0; i < recipes.length; i++) {
      foodWidgetsList.add(SingleRecipeItemDescription(recipes[i], mealPlan));
    }
    // foodWidgetsList.add(
    //   GestureDetector(
    //     onTap: () async {
    //       await Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => AddMealItem(meal_id, mealPlan),
    //         ),
    //       );
    //       _getMealPlansRequest();
    //     },
    //     child: Container(
    //       decoration: borderRadius(secondryColor, 8),
    //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    //       child: Text(
    //         "Add Food +",
    //         style: TextStyle(
    //           color: white,
    //           fontWeight: FontWeight.bold,
    //           fontSize: 14,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return foodWidgetsList;
  }

  Map<String, dynamic> nutritionsCollapse = {};
  nutritionBreakDownWidget(
    String title,
    String value,
    List<dynamic> sub_nutrients,
  ) {
    if (!nutritionsCollapse.containsKey(title)) {
      nutritionsCollapse[title] = false;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          nutritionsCollapse[title] = !nutritionsCollapse[title];
        });
      },
      child: Container(
        color: white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (sub_nutrients.length > 0 ? "+ " : "") + title,
                  style: TextStyle(
                    color: textDark(),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: textDark(),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(height: 15, color: dividerColor),
            nutritionsCollapse[title]
                ? subNutritionWidget(sub_nutrients)
                : Container(),
          ],
        ),
      ),
    );
  }

  subNutritionWidget(List sub_nutrients) {
    List<Widget> subNutrientsWidgetList = [];
    for (int i = 0; i < sub_nutrients.length; i++) {
      subNutrientsWidgetList.add(
        Container(
          margin: EdgeInsets.only(left: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "- " + sub_nutrients[i]['title'],
                      style: TextStyle(
                        color: textDark(),
                        fontSize: 13.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    sub_nutrients[i]['amount'] == 0
                        ? ""
                        : sub_nutrients[i]['amount'].toStringAsFixed(0) +
                            (sub_nutrients[i]['dri'] == 0
                                ? ""
                                : ("/" + sub_nutrients[i]['dri'].toString())) +
                            sub_nutrients[i]['nutrient_unit_code'],
                    style: TextStyle(
                      color: textDark(),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Divider(height: 15, color: dividerColor),
              (sub_nutrients[i]['sub_nutrients'] as List<dynamic>).length > 0
                  ? subNutritionWidget(sub_nutrients[i]['sub_nutrients'])
                  : Container(),
            ],
          ),
        ),
      );
    }
    return Column(children: subNutrientsWidgetList);
  }

  bool _isLoading = false;
  var mealPlanFromServer = {};
  List mealPlans = [];
  List completeNutrientBreakdown = [];
  void _getMealPlansRequest(bool shouldShowLoading) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = shouldShowLoading;
      });

      Map data = await apiService.getWithToken(
        mealPlanById + widget.mealPlanId.toString(),
        {},
      );
      setState(() {
        mealPlanFromServer = data;
        mealPlans = mealPlanFromServer['meal_meals'];
        completeNutrientBreakdown =
            mealPlanFromServer['complete_nutrient_breakdown'];
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

  bool isLoadingAutoAssign = false;
  void autoAssignMealPlan() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    int? dailyCalories =
        (await StorageService.getLoginData())
            ?.dietaryPreference
            .dailyCalorieIntake;
    Map<String, dynamic> mapToSend = {"calories": dailyCalories};
    try {
      setState(() {
        isLoadingAutoAssign = true;
      });
      showLoadingDialog(context, "Generating plans for you...");

      //return;
      dynamic data = await apiService.postWithToken(
        autoGenerateDietPlan,
        mapToSend,
      );
      print("mealPlanNew----" + data.toString());
      setState(() {
        //showToast("hello");
        // userDetail.dietaryPreference.primaryMealPlanId = data['id'];
        hideLoadingDialog(context);
        _getMealPlansRequest(true);

        isLoadingAutoAssign = false;
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
      setState(() => isLoadingAutoAssign = false);
    }
  }
}
