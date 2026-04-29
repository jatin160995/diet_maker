import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Screens/my_meal_plan_calculator.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class ItemDetail extends StatefulWidget {
  dynamic itemData;
  dynamic mealPlan;
  ItemDetail(this.itemData, this.mealPlan, {super.key});

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  ExpandableController breakdownController = ExpandableController();

  @override
  void initState() {
    super.initState();
    breakdownController.expanded = true;
    Future.delayed(Duration(milliseconds: 500), () {
      _getMealItemDetails();
    });
  }

  itemDetail(Map itemData) {
    servingSizeController = TextEditingController();
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,
      builder: (BuildContext context) {
        servingSizeController.addListener(() {
          setState(() {});
        });
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              onTap: () {
                dismissKeyboard(context);
              },
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.8,
                color: backgroundColor(),
                child: itemDetailWidget(itemData, setState),
              ),
            );
          },
        );
      },
    );
  }

  int selectedSelectedUnit = 0;
  late TextEditingController servingSizeController;
  ScrollController itemDetailScrollController = new ScrollController();
  itemDetailWidget(Map data, StateSetter setState) {
    //Serving Unit
    List<String> servingUnit = [];
    for (var serving in data['food_serving_sizes']) {
      servingUnit.add(serving['serving_size_unit']['unit']);
    }

    return SafeArea(
      child: ListView(
        controller: itemDetailScrollController,
        padding: EdgeInsets.all(20),
        children: [
          SmallHeading("Food Item"),
          heading(data['title']),
          Divider(color: dividerColor, height: 25),

          SmallHeading("Unit of Measurement"),
          GestureDetector(
            onTap: () {
              showPicker(context, (int index) {
                setState(() {
                  selectedSelectedUnit = index;
                });
              }, servingUnit);
            },
            child: Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(servingUnit[selectedSelectedUnit]),
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
          SmallHeading("Avg. Serving Size"),
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['food_serving_sizes'][selectedSelectedUnit]['average_serving_size'],
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: dividerColor,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              border: Border.all(color: dividerColor),
            ),
          ),
          SizedBox(height: 10),
          SmallHeading("Enter Serving Size"),
          CustomEditText(
            true,
            14,
            servingSizeController,
            TextInputType.number,
            "",
          ),
          SizedBox(height: 10),
          Divider(height: 35, color: dividerColor),
          heading("Complete Nutrient Breakdown"),
          SizedBox(height: 10),
          nutritionBreakDownWidget(
            "Calories",
            ((data['food_serving_sizes'][selectedSelectedUnit]['calorie']) *
                    double.parse(
                      servingSizeController.text == ""
                          ? "0"
                          : servingSizeController.text,
                    ))
                .toStringAsFixed(2),
          ),
          nutritionBreakDownWidget(
            "Protein",
            ((data['food_serving_sizes'][selectedSelectedUnit]['protein']) *
                    double.parse(
                      servingSizeController.text == ""
                          ? "0"
                          : servingSizeController.text,
                    ))
                .toStringAsFixed(2),
          ),
          nutritionBreakDownWidget(
            "Carbohydrates",
            ((data['food_serving_sizes'][selectedSelectedUnit]['carbohydrate']) *
                    double.parse(
                      servingSizeController.text == ""
                          ? "0"
                          : servingSizeController.text,
                    ))
                .toStringAsFixed(2),
          ),
          nutritionBreakDownWidget(
            "Fat",
            ((data['food_serving_sizes'][selectedSelectedUnit]['fat']) *
                    double.parse(
                      servingSizeController.text == ""
                          ? "0"
                          : servingSizeController.text,
                    ))
                .toStringAsFixed(2),
          ),
          SizedBox(height: 20),
          DefaultButton("Update Food", () {
            submitFoodToMeal(
              data['id'],
              data['food_serving_sizes'][selectedSelectedUnit]['id'],
              servingSizeController.text,
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.itemData);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _getItemDetails(widget.itemData['food_id']);
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              showGenericDialog(
                context,
                "Delete ?",
                "Are you sure you want to delete this food item from the meal plan ?\n\n" +
                    "Item Name: " +
                    widget.itemData['food']['title'].toString().trim(),
                "Delete",
                () {
                  _deleteFoodFromMeal();
                },
              );
            },
            icon: Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
        backgroundColor: backgroundColor(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading("Food Detail"),
            SmallHeading(
              "Meal Time: " + widget.mealPlan['meal_time_formatted'],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallHeading("Item Name"),
              headingBig(widget.itemData['food']['title']),
              SizedBox(height: 10),
              SmallHeading("Category"),
              widget.itemData['food']['category'] == null
                  ? Text("N/A")
                  : heading(
                    widget.itemData['food']['category']['title'].toString(),
                  ),
              SizedBox(height: 10),
              SmallHeading("Sub Category"),
              widget.itemData['food']['sub_category'] == null
                  ? Text("N/A")
                  : heading(
                    widget.itemData['food']['sub_category']['title'].toString(),
                  ),
              SizedBox(height: 10),
              SmallHeading("Amount"),
              heading(
                widget.itemData['food_amount'].toString() +
                    " " +
                    widget
                        .itemData['food_serving_size']['serving_size_unit']['unit'],
              ),
              SizedBox(height: 10),
              SmallHeading("Calories"),
              heading(
                (widget.itemData['food_serving_size']['calorie'] *
                            widget.itemData['food_amount'])
                        .toStringAsFixed(1) +
                    " kcal",
              ),
            ],
          ),
          Divider(height: 30, color: dividerColor),
          SizedBox(height: 20),
          // Container(
          //   //padding: EdgeInsets.all(10),
          //   decoration: borderRadius(white, 8),
          //   child: ExpandablePanel(
          //     controller: breakdownController,
          //     header: heading("Complete Nutrient Breakdown"),
          //     collapsed: Container(),
          //     expanded: Column(
          //       children: [
          //         SizedBox(height: 15),
          //         Column(children: nutrientBreakdown()),
          //       ],
          //     ),
          //   ),
          // ),
          itemDetailsLoading
              ? loader("Loading Details..")
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heading("Calories & Macronutrients per amount"),
                  SizedBox(height: 20),
                  nutritionBreakDownWidget(
                    "Calories",
                    (itemDetailsFromServer['daily_macro_nutrient']['calorie_amount'])
                        .toStringAsFixed(2),
                  ),
                  nutritionBreakDownWidget(
                    "Protein",
                    ((itemDetailsFromServer['daily_macro_nutrient']['protein_amount']))
                        .toStringAsFixed(2),
                  ),
                  nutritionBreakDownWidget(
                    "Carbohydrates",
                    ((itemDetailsFromServer['daily_macro_nutrient']['carbohydrate_amount']))
                        .toStringAsFixed(2),
                  ),
                  nutritionBreakDownWidget(
                    "Fat",
                    ((itemDetailsFromServer['daily_macro_nutrient']['fat_amount']))
                        .toStringAsFixed(2),
                  ),
                  SizedBox(height: 20),
                  Container(
                    //padding: EdgeInsets.all(10),
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
                ],
              ),
        ],
      ),
    );
  }

  // List<Widget> nutrientBreakdown() {
  //   List<Widget> breakdownWidgets = [];
  //   List completeNutrientBreakdown =
  //       widget.itemData['food_serving_size']['food_nutrients'];
  //   for (int i = 0; i < completeNutrientBreakdown.length; i++) {
  //     double amount =
  //         completeNutrientBreakdown[i]['amount'].toDouble() *
  //         widget.itemData['food_amount'].toDouble();
  //     breakdownWidgets.add(
  //       nutritionBreakDownWidget(
  //         completeNutrientBreakdown[i]['nutrient']['title'],
  //         amount.toStringAsFixed(2) +
  //             " " +
  //             completeNutrientBreakdown[i]['nutrient']['nutrient_unit_code'],
  //       ),
  //     );
  //   }
  //   return breakdownWidgets;
  // }

  List<Widget> nutrientBreakdown() {
    List<Widget> breakdownWidgets = [];
    List completeNutrientBreakdown =
        itemDetailsFromServer['complete_nutrient_breakdown'];
    for (int i = 0; i < completeNutrientBreakdown.length; i++) {
      if (completeNutrientBreakdown[i]['is_primary'] == "No") {
        continue;
      }
      breakdownWidgets.add(
        _nutritionBreakDownWidget(
          completeNutrientBreakdown[i]['title'],
          completeNutrientBreakdown[i]['amount'] == 0
              ? "" //+ completeNutrientBreakdown[i]['nutrient_unit_code']
              : completeNutrientBreakdown[i]['amount'].toString() +
                  completeNutrientBreakdown[i]['nutrient_unit_code'],
          completeNutrientBreakdown[i]['sub_nutrients'],
        ),
      );
    }
    return breakdownWidgets;
  }

  Map<String, dynamic> nutritionsCollapse = {};
  _nutritionBreakDownWidget(
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
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    sub_nutrients[i]['amount'] == 0
                        ? ""
                        : sub_nutrients[i]['amount'].toString() +
                            sub_nutrients[i]['nutrient_unit_code'],
                    style: TextStyle(
                      color: textDark(),
                      fontSize: 15,
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
  void _deleteFoodFromMeal() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });
      showLoadingDialog(context, "Deleting food...");

      Map data = await apiService.deleteWithToken(
        deleteMealFood + widget.itemData['id'].toString(),
        {},
      );
      setState(() {
        _isLoading = false;
        showToast("Food Deleted Successfully");
        hideLoadingDialog(context);
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyMealPlanCalculator()),
        );
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
      hideLoadingDialog(context);
      setState(() => _isLoading = false);
    }
  }

  void submitFoodToMeal(
    int food_id,
    int food_serving_size_id,
    String food_amount,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    Map<String, dynamic> dataToPost = {
      "meal_meal_id": widget.itemData['meal_meal_id'],
      "food_id": food_id,
      "food_serving_size_id": food_serving_size_id,
      "food_amount": double.parse(food_amount),
    };
    print(dataToPost);
    //return;
    try {
      showLoadingDialog(context, "Adding food to meal..");
      Map data = await apiService.putRequest(
        addMealFood + "/" + widget.itemData['id'].toString(),
        {},
        dataToPost,
      );
      Navigator.pop(context);
      Navigator.pop(context);
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

  bool _isLoadingItem = false;

  void _getItemDetails(int foodItemId) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoadingItem = true;
      });
      showLoadingDialog(context, "Item details loading..");

      Map data = await apiService.getWithToken(
        getFoodDetail + foodItemId.toString(),
        {},
      );

      hideLoadingDialog(context);

      setState(() {
        _isLoadingItem = false;
      });
      itemDetail(data);
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
      setState(() => _isLoadingItem = false);
      hideLoadingDialog(context);
    }
  }

  dynamic itemDetailsFromServer = {};
  bool itemDetailsLoading = true;

  void _getMealItemDetails() async {
    //FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        itemDetailsLoading = true;
      });
      // showLoadingDialog(context, "Item details loading..");

      Map data = await apiService.getWithToken(
        getFoodItemDetails + widget.itemData['id'].toString(),
        {},
      );

      // hideLoadingDialog(context);

      setState(() {
        itemDetailsFromServer = data;
        itemDetailsLoading = false;
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
      setState(() => itemDetailsLoading = false);
      //hideLoadingDialog(context);
    }
  }
}
