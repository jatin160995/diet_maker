import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/custom_recipe.dart';
import 'package:diet_maker/Screens/AddMeal/MealPlan/EditRecipe/edit_recipe_screen.dart';
import 'package:diet_maker/Screens/CustomRecipes/custom_recipe_form_screen.dart';
import 'package:diet_maker/Screens/my_meal_plan_calculator.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:diet_maker/widgets/loading_image.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class RecipeDetail extends StatefulWidget {
  dynamic itemData;
  dynamic mealPlan;
  RecipeDetail(this.itemData, this.mealPlan, {super.key});

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  ExpandableController breakdownController = ExpandableController();

  @override
  void initState() {
    breakdownController.expanded = true;
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      //showToast("message");
      _getMealItemDetails();
    });
  }

  void _openEditRecipeScreen(int recipeId) async {
    showLoadingDialog(context, 'Loading...');
    try {
      final ApiService api = ApiService();
      //final raw = await api.getWithToken('food/custom-recipes/$recipeId', {});
      final raw = await api.getWithToken('food/recipes/$recipeId', {});
      hideLoadingDialog(context);
      final recipe = CustomRecipe.fromSingleResponse(raw);
      // final refresh = await Navigator.push<bool>(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => CustomRecipeFormScreen(recipe: recipe),
      //   ),
      // );
      final refresh = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => CustomRecipeFormScreen(
                recipeId: recipe.id,
                recipeTitle: recipe.title,
              ),
        ),
      );
      if (refresh == true && mounted) Navigator.pop(context);
    } catch (e) {
      hideLoadingDialog(context);
      showToast('Could not load recipe');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.itemData['meal_recipe_foods']);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        actions: [
          IconButton(
            onPressed: () {
              _getItemDetails(widget.itemData['recipe_id']);
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
                    widget.itemData['recipe']['title'].toString().trim(),
                "Delete",
                () {
                  _deleteFoodFromMeal();
                },
              );
            },
            icon: Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading("Recipe Detail"),
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SmallHeading("Item Name"),
                        headingBig(widget.itemData['recipe']['title']),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    height: 80,
                    width: 80,
                    clipBehavior: Clip.antiAlias,
                    decoration: borderRadius(white, 10),
                    child: LoadingImage(
                      widget.itemData['recipe']['image_url'].toString(),
                    ),
                  ),
                ],
              ),
              Divider(height: 30, color: dividerColor),

              SizedBox(height: 10),
              heading("Description"),
              Text(widget.itemData['recipe']['description']),
              Divider(height: 30, color: dividerColor),
              SizedBox(height: 10),
              heading("Ingredients"),
              Text(widget.itemData['recipe']['ingredients']),
              Divider(height: 30, color: dividerColor),
              SizedBox(height: 10),
              heading("Instructions"),
              Text(widget.itemData['recipe']['instructions']),
              Divider(height: 30, color: dividerColor),
              SizedBox(height: 10),
              heading("Amount"),
              Text(widget.itemData['food_amount'].toString()),
              SizedBox(height: 10),
            ],
          ),
          Divider(height: 30, color: dividerColor),
          // SizedBox(height: 20),
          // Container(
          //   //padding: EdgeInsets.all(10),
          //   decoration: borderRadius(white, 8),
          //   child: ExpandablePanel(
          //     controller: breakdownController,
          //     header: heading("Macronutrient Breakdown"),
          //     collapsed: Container(),
          //     expanded: Column(
          //       children: [
          //         SizedBox(height: 15),
          //         Column(
          //           children: [
          //             // nutrientBreakdown(),
          //             macroNutrient(
          //               widget.itemData['recipe']['protein'].toDouble(),
          //               "Protein",
          //               " g",
          //             ),
          //             macroNutrient(
          //               widget.itemData['recipe']['carbohydrate'].toDouble(),
          //               "Carbohydrate",
          //               " g",
          //             ),
          //             macroNutrient(
          //               widget.itemData['recipe']['fat'].toDouble(),
          //               "Fat",
          //               " g",
          //             ),
          //             macroNutrient(
          //               widget.itemData['recipe']['calorie'].toDouble(),
          //               "Calorie",
          //               " kcal",
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // Divider(height: 30, color: dividerColor),
          // SizedBox(height: 20),
          // Container(
          //   //padding: EdgeInsets.all(10),
          //   decoration: borderRadius(white, 8),
          //   child: ExpandablePanel(
          //     controller: breakdownController,
          //     header: heading("Macro Nutrient Breakdown"),
          //     collapsed: Container(),
          //     expanded: Column(
          //       children: [
          //         SizedBox(height: 15),
          //         Column(children: nutrientBreakdown()),
          //       ],
          //     ),
          //   ),
          // ),
          //SizedBox(height: 20),
          SizedBox(height: 20),
          itemDetailsLoading
              ? loader("Loading Details..")
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  heading("Foods"),
                  SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: foodList(),
                  ),
                  SizedBox(height: 10),
                  itemDetailsFromServer['recipe']['is_custom']
                      ? Column(
                        children: [
                          DefaultButton("Edit Foods", () {
                            _openEditRecipeScreen(widget.itemData['recipe_id']);
                          }),
                          SizedBox(height: 20),
                        ],
                      )
                      : Container(),
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

  List<Widget> foodList() {
    List mealRecipeFoods = widget.itemData['meal_recipe_foods'];

    List<Widget> foodWidgetList = [];
    for (int i = 0; i < mealRecipeFoods.length; i++) {
      foodWidgetList.add(
        // Container(

        //   decoration: borderRadius(white, 8),
        //   child: ExpandablePanel(

        //     header: Row(

        //       children: [
        //         Expanded(
        //           child: Text(
        //             mealRecipeFoods[i]['food']['title'],
        //             style: TextStyle(
        //               color: textDark(),
        //               fontSize: 15,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //         ),
        //         Text(
        //           "  (" +
        //               mealRecipeFoods[i]['food_amount'].toString() +
        //               " " +
        //               mealRecipeFoods[i]['food_serving_size']['serving_size_unit']['unit']
        //                   .toString() +
        //               ")",
        //           style: TextStyle(
        //             color: textDark(),
        //             fontSize: 15,
        //             fontWeight: FontWeight.normal,
        //           ),
        //         ),
        //       ],
        //     ),
        //     collapsed: Container(),
        //     expanded: Container(
        //       margin: EdgeInsets.only(bottom: 5),
        //       child: Container(
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: foodIngredientList(
        //             mealRecipeFoods[i]['food_serving_size']['food_nutrients'],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        Container(
          color: white,
          padding: EdgeInsets.only(left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Text(
                      mealRecipeFoods[i]['food']['title'],
                      //textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textDark(),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(height: 50, width: 1, color: dividerColor),
                  SizedBox(width: 10),

                  Column(
                    children: [
                      Text(
                        mealRecipeFoods[i]['food_amount'].toString() +
                            " " +
                            mealRecipeFoods[i]['food_serving_size']['serving_size_unit']['unit']
                                .toString(),
                        style: TextStyle(
                          color: textDark(),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Text(
                      //   widget
                      //       .itemData['food_serving_size']['serving_size_unit']['unit'],
                      //   style: TextStyle(
                      //     color: textLightest(),
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.normal,
                      //   ),
                      // ),
                    ],
                  ),

                  SizedBox(width: 10),
                  Container(height: 50, width: 1, color: dividerColor),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Text(
                        mealRecipeFoods[i]['food_serving_size']['calorie']
                            .toStringAsFixed(0),
                        style: TextStyle(
                          color: textDark(),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Calories",
                        style: TextStyle(
                          color: textLightest(),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                "Protein:  ${mealRecipeFoods[i]['food_serving_size']['protein'].toStringAsFixed(0)}g / Carbs: ${mealRecipeFoods[i]['food_serving_size']['carbohydrate'].toStringAsFixed(0)}g / Fat: ${mealRecipeFoods[i]['food_serving_size']['fat'].toStringAsFixed(0)}g",
                style: TextStyle(
                  color: textMedium(),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Divider(height: 30, color: dividerColor),
            ],
          ),
        ),
      );
      //foodWidgetList.add(Divider(height: 10, color: dividerColor));
      foodWidgetList.add(SizedBox(height: 10));
    }

    return foodWidgetList;
  }

  List<Widget> foodIngredientList(List<dynamic> ingredients) {
    List<Widget> foodingredientsWidgetList = [];
    for (int i = 0; i < ingredients.length; i++) {
      foodingredientsWidgetList.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ingredients[i]['nutrient']['title']),
                Text(
                  ingredients[i]['amount'].toStringAsFixed(1) +
                      ingredients[i]['nutrient']['nutrient_unit_code'],
                ),
              ],
            ),
            Divider(height: 20, color: dividerColor),
          ],
        ),
      );
    }

    return foodingredientsWidgetList;
  }

  Widget macroNutrient(double amount, String title, String suffix) {
    // List completeNutrientBreakdown =
    //     widget.itemData['food_serving_size']['food_nutrients'];

    double totalAmount = amount * widget.itemData['food_amount'].toDouble();

    return nutritionBreakDownWidget(
      title,
      totalAmount.toStringAsFixed(2) + " " + suffix,
    );
  }

  // List<Widget> nutrientBreakdown() {
  //   List<Widget> breakdownWidgets = [];
  //   List completeNutrientBreakdown = [];
  //   if (widget.itemData["serving_sizes"].lenght > 0) {
  //     completeNutrientBreakdown =
  //         widget.itemData['serving_sizes'][0]['nutrients'];
  //   }
  //   for (int i = 0; i < completeNutrientBreakdown.length; i++) {
  //     String amount = completeNutrientBreakdown[i]['amount'];
  //     breakdownWidgets.add(
  //       nutritionBreakDownWidget(
  //         completeNutrientBreakdown[i]['nutrient']['title'],
  //         completeNutrientBreakdown[i]['amount'] +
  //             " " +
  //             completeNutrientBreakdown[i]['nutrient']['nutrient_unit_code'],
  //       ),
  //     );
  //   }
  //   return breakdownWidgets;
  // }

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
        deleteMealRecipe + widget.itemData['id'].toString(),
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
  void _getItemDetails(int recipeItemId) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoadingItem = true;
      });
      showLoadingDialog(context, "Recipe details loading..");

      Map data = await apiService.getWithToken(
        getFoodRecipesDetail + recipeItemId.toString(),
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            servingSizeController.addListener(() {
              //print("text changed");
              setState(() {});
            });
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

    return SafeArea(
      child: Stack(
        children: [
          ListView(
            controller: itemDetailScrollController,
            padding: EdgeInsets.all(20),
            children: [
              SmallHeading("Recipe"),
              heading(data['title']),
              Divider(color: dividerColor, height: 25),
              LoadingImage(data['image_url'].toString()),
              SizedBox(height: 10),

              SmallHeading("Amount"),
              CustomEditText(
                true,
                14,
                servingSizeController,
                TextInputType.number,
                "",
              ),
              SizedBox(height: 10),
              Divider(height: 35, color: dividerColor),
              heading("Macronutrient Breakdown"),
              SizedBox(height: 10),
              nutritionBreakDownWidget(
                "Calories",
                ((data['calorie']) *
                        double.parse(
                          servingSizeController.text == ""
                              ? "0"
                              : servingSizeController.text,
                        ))
                    .toStringAsFixed(2),
              ),
              nutritionBreakDownWidget(
                "Protein",
                ((data['protein']) *
                        double.parse(
                          servingSizeController.text == ""
                              ? "0"
                              : servingSizeController.text,
                        ))
                    .toStringAsFixed(2),
              ),
              nutritionBreakDownWidget(
                "Carbohydrates",
                ((data['carbohydrate']) *
                        double.parse(
                          servingSizeController.text == ""
                              ? "0"
                              : servingSizeController.text,
                        ))
                    .toStringAsFixed(2),
              ),
              nutritionBreakDownWidget(
                "Fat",
                ((data['fat']) *
                        double.parse(
                          servingSizeController.text == ""
                              ? "0"
                              : servingSizeController.text,
                        ))
                    .toStringAsFixed(2),
              ),
              SizedBox(height: 20),
              heading("Description"),
              Text(data['description']),
              Divider(height: 30, color: dividerColor),

              heading("Ingredients"),
              Text(data['ingredients']),
              Divider(height: 30, color: dividerColor),

              heading("Substitutions"),
              Text(data['substitution'].toString()),
              Divider(height: 30, color: dividerColor),

              heading("Instructions"),
              Text(data['instructions']),

              SizedBox(height: 70),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DefaultButton("Add Recipe", () {
              submitRecipeToMeal(data['id'], servingSizeController.text);
            }),
          ),
        ],
      ),
    );
  }

  void submitRecipeToMeal(int recipe_id, String food_amount) async {
    if (food_amount == "") {
      showToast("Enter Food Amount");
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    Map<String, dynamic> dataToPost = {
      "meal_meal_id": widget.itemData['meal_meal_id'],
      "recipe_id": recipe_id,
      "food_amount": double.parse(food_amount),
    };
    print(dataToPost);
    //return;
    try {
      showLoadingDialog(context, "Adding Recipe to meal..");
      Map data = await apiService.putRequest(
        addMealRecipe + "/" + widget.itemData['id'].toString(),
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

  // Customised Values----------------------------------------

  List<Widget> nutrientBreakdown() {
    // print("here_is_testing----" + itemDetailsFromServer.toString());

    List<Widget> breakdownWidgets = [];
    if (itemDetailsFromServer.toString() == "{}") {
      return [];
    }

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
        getRecipeItemDetails + widget.itemData['id'].toString(),
        {},
      );
      print("here_is_testing" + data.toString());
      print(
        "here_is_testing" +
            getFoodItemDetails +
            widget.itemData['id'].toString(),
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
