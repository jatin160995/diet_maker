import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/utils/recipe_clone_helper.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:diet_maker/widgets/loading_image.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  @override
  void initState() {
    // TODO: implement initState
    _getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("Recipes"),
      ),
      body:
          _isLoading
              ? loader("Loading Recipes...")
              : ListView(children: recipesWidgetList()),
    );
  }

  List<Widget> recipesWidgetList() {
    List<Widget> recipesWidget = [];
    for (int i = 0; i < recipesFromServer.length; i++) {
      // print(recipesFromServer[i]['title'] + "---------------");
      recipesWidget.add(
        ExpandablePanel(
          //controller: breakdownController,
          theme: const ExpandableThemeData(
            hasIcon: false, // This removes the arrow
          ),
          //controller: ExpandableController(initialExpanded: true),
          header: Container(
            //padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        decoration: borderRadius(white, 10),
                        height: 80,
                        width: 80,
                        clipBehavior: Clip.antiAlias,
                        child: LoadingImage(
                          recipesFromServer[i]['image_url'].toString(),
                        ),
                      ),
                      SizedBox(width: 20),
                      heading(recipesFromServer[i]['title']),
                    ],
                  ),
                ),
                Divider(height: 1, color: dividerColor),
              ],
            ),
          ),
          collapsed: Container(),
          expanded: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: recipeItems(recipesFromServer[i]['recipes']),
            ),
          ),
        ),
      );
    }
    return recipesWidget;
  }

  List<Widget> recipeItems(List<dynamic> recipeItemsList) {
    List<Widget> recipeItemsWidget = [];
    for (int i = 0; i < recipeItemsList.length; i++) {
      // print(recipeItemsList[i]['title'] + "---------------");
      recipeItemsWidget.add(
        GestureDetector(
          onTap: () {
            _getItemDetails(recipeItemsList[i]['id']);
          },
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    clipBehavior: Clip.antiAlias,
                    decoration: borderRadius(white, 8),
                    child: LoadingImage(
                      recipeItemsList[i]['image_url'].toString(),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      recipeItemsList[i]['title'],
                      style: TextStyle(color: textMedium(), fontSize: 16),
                    ),
                  ),
                ],
              ),
              Divider(height: 20, color: dividerColor),
            ],
          ),
        ),
      );
    }
    return recipeItemsWidget;
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

              // SmallHeading("Amount"),
              // CustomEditText(
              //   true,
              //   14,
              //   servingSizeController,
              //   TextInputType.number,
              //   "",
              // ),
              SizedBox(height: 10),
              Divider(height: 35, color: dividerColor),
              heading("Complete Nutrient Breakdown"),
              SizedBox(height: 10),
              nutritionBreakDownWidget(
                "Calories",
                ((data['calorie'])).toStringAsFixed(2),
              ),
              nutritionBreakDownWidget(
                "Protein",
                ((data['protein'])).toStringAsFixed(2),
              ),
              nutritionBreakDownWidget(
                "Carbohydrates",
                ((data['carbohydrate'])).toStringAsFixed(2),
              ),
              nutritionBreakDownWidget(
                "Fat",
                ((data['fat'])).toStringAsFixed(2),
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

              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  await cloneRecipe(
                    context,
                    recipeId: data['id'] as int,
                    recipeTitle: data['title']?.toString() ?? 'Recipe',
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColorLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.copy_outlined, color: primaryColor, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Clone to My Custom Recipes',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 70),
            ],
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: DefaultButton("Add Recipe", () {
          //     // submitRecipeToMeal(data['id'], servingSizeController.text);
          //   }),
          // ),
        ],
      ),
    );
  }

  nutritionBreakDownWidget(String title, String value) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: textDark(), fontSize: 15)),
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
        ],
      ),
    );
  }

  bool _isLoading = false;
  List recipesFromServer = [];

  void _getRecipes() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    try {
      setState(() {
        _isLoading = true;
      });
      recipesFromServer = await apiService.getWithToken(getFoodRecipes, {});

      setState(() {
        _isLoading = false;
      });
      print(recipesFromServer);
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
}
