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

class BrandedFoodItemDetail extends StatefulWidget {
  dynamic itemData;
  dynamic mealPlan;
  BrandedFoodItemDetail(this.itemData, this.mealPlan, {super.key});

  @override
  State<BrandedFoodItemDetail> createState() => _BrandedFoodItemDetailState();
}

class _BrandedFoodItemDetailState extends State<BrandedFoodItemDetail> {
  ExpandableController breakdownController = ExpandableController();

  @override
  void initState() {
    breakdownController.expanded = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.itemData);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        actions: [
          IconButton(
            onPressed: () {
              _getItemDetails(widget.itemData['branded_food_id']);
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
                    widget.itemData['branded_food']['name'].toString().trim(),
                "Delete",
                () {
                  _deleteBrandedFoodFromMeal();
                },
              );
            },
            icon: Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading("Branded Food Detail"),
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
              headingBig(widget.itemData['branded_food']['name']),
              SizedBox(height: 10),
              SmallHeading("Category"),
              heading(
                widget.itemData['branded_food']['food_category'] == null
                    ? "n/a"
                    : widget.itemData['branded_food']['food_category']['name']
                        .toString(),
              ),
              SizedBox(height: 10),
              SmallHeading("Brand"),
              heading(widget.itemData['branded_food']['brand_owner']['name']),
              SizedBox(height: 10),
              SmallHeading("Amount"),
              heading(
                widget.itemData['food_amount'].toString() +
                    " " +
                    widget
                        .itemData['branded_food_serving_size']['serving_size_unit']['unit'],
              ),
              SizedBox(height: 10),
              SmallHeading("Calories"),
              heading(
                (widget.itemData['branded_food_serving_size']['calorie'] == null
                            ? 0
                            : widget.itemData['branded_food_serving_size']['calorie'] *
                                widget.itemData['food_amount'])
                        .toString() +
                    " kcal",
              ),
            ],
          ),
          Divider(height: 30, color: dividerColor),
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
    );
  }

  List<Widget> nutrientBreakdown() {
    List<Widget> breakdownWidgets = [];
    List completeNutrientBreakdown =
        widget.itemData['branded_food_serving_size']['nutrients'];
    for (int i = 0; i < completeNutrientBreakdown.length; i++) {
      double amount =
          double.parse(completeNutrientBreakdown[i]['amount']) *
          widget.itemData['food_amount'].toDouble();
      breakdownWidgets.add(
        nutritionBreakDownWidget(
          completeNutrientBreakdown[i]['nutrient']['name'],
          amount.toStringAsFixed(2) +
              " " +
              completeNutrientBreakdown[i]['nutrient']['unit_name'],
        ),
      );
    }
    return breakdownWidgets;
  }

  bool _isLoading = false;
  void _deleteBrandedFoodFromMeal() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });
      showLoadingDialog(context, "Deleting food...");

      Map data = await apiService.deleteWithToken(
        deleteMealBrandedFood + widget.itemData['id'].toString(),
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
        getBrandedFoodDetail + foodItemId.toString(),
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
    //print(data);
    //showToast(data.toString());
    List<String> servingUnit = [];
    for (var serving
        in data['serving_sizes'] == null ? [] : data['serving_sizes']) {
      servingUnit.add(serving['serving_size_unit']['unit']);
    }

    return SafeArea(
      child: ListView(
        controller: itemDetailScrollController,
        padding: EdgeInsets.all(20),
        children: [
          SmallHeading("Food Item"),
          heading(data['name']),

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
                  data['serving_sizes'][selectedSelectedUnit]['serving_value'],
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
            ((double.parse(
                      data['serving_sizes'][selectedSelectedUnit]['calorie'] ==
                              null
                          ? "0"
                          : data['serving_sizes'][selectedSelectedUnit]['calorie'],
                    )) *
                    double.parse(
                      servingSizeController.text == ""
                          ? "0"
                          : servingSizeController.text,
                    ))
                .toStringAsFixed(2),
          ),
          nutritionBreakDownWidget(
            "Protein",
            ((double.parse(
                      data['serving_sizes'][selectedSelectedUnit]['protein'],
                    )) *
                    double.parse(
                      servingSizeController.text == ""
                          ? "0"
                          : servingSizeController.text,
                    ))
                .toStringAsFixed(2),
          ),
          nutritionBreakDownWidget(
            "Carbohydrates",
            (double.parse(
                      (data['serving_sizes'][selectedSelectedUnit]['carbohydrate']),
                    ) *
                    double.parse(
                      servingSizeController.text == ""
                          ? "0"
                          : servingSizeController.text,
                    ))
                .toStringAsFixed(2),
          ),
          nutritionBreakDownWidget(
            "Fat",
            ((double.parse(
                      data['serving_sizes'][selectedSelectedUnit]['fat'],
                    )) *
                    double.parse(
                      servingSizeController.text == ""
                          ? "0"
                          : servingSizeController.text,
                    ))
                .toStringAsFixed(2),
          ),
          SizedBox(height: 10),
          SmallHeading("Ingredients"),
          Text(data['ingredients']),
          SizedBox(height: 20),
          DefaultButton("Add Food", () {
            submitFoodToMeal(
              data['fdc_id'],
              data['serving_sizes'][selectedSelectedUnit]['id'],
              servingSizeController.text,
            );
          }),
        ],
      ),
    );
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
      "branded_food_id": food_id,
      "branded_food_serving_size_id": food_serving_size_id,
      "food_amount": double.parse(food_amount),
    };
    print(dataToPost);
    //return;
    try {
      showLoadingDialog(context, "Adding food to meal..");
      print(addMealBrandedFood);
      Map data = await apiService.putRequest(
        addMealBrandedFood + "/" + widget.itemData['id'].toString(),
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
}
