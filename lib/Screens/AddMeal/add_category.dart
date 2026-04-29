import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';

class AddCategory extends StatefulWidget {
  int meal_id;
  AddCategory(this.meal_id, {super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  @override
  void initState() {
    _getFoodCategories();
    super.initState();
  }

  // Category
  List<String> categories = [];
  int selectedCategory = 0;
  //SubCategory
  List<String> subCategories = [];
  int selectedSubCategory = 0;
  //varieties
  List<String> varieties = [];
  int selectedvarieties = 0;
  //Food Item
  List<String> foodItems = [];
  int selectedfoodItem = 0;

  getSubCategories() {
    List<dynamic> subCat = foodsCategoriesFromServer[selectedCategory]['child'];
    subCategories = subCat.map((e) => e['title'].toString()).toList();
    print(subCategories);
    getVarieties();
  }

  getVarieties() {
    List<dynamic> varietyList =
        foodsCategoriesFromServer[selectedCategory]['child'][selectedSubCategory]['varieties'];
    varieties = varietyList.map((e) => e['name'].toString()).toList();
    print(varieties);
    getFoodItems();
  }

  getFoodItems() {
    List<dynamic> items =
        foodsCategoriesFromServer[selectedCategory]['child'][selectedSubCategory]['varieties'][selectedvarieties]['foods'];
    foodItems = items.map((e) => e['title'].toString()).toList();
    print(foodItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? loader("Loading Categories...")
              : Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SmallHeading("Category"),
                            GestureDetector(
                              onTap: () {
                                showPicker(context, (int index) {
                                  setState(() {
                                    selectedCategory = index;
                                    selectedSubCategory = 0;
                                    selectedvarieties = 0;
                                    getSubCategories();
                                  });
                                }, categories);
                              },
                              child: Container(
                                height: 60,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(categories[selectedCategory]),
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
                          ],
                        ),
                        SizedBox(width: 10),
                        /////////////////SUB CATEGORY////////////////////
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SmallHeading("Subcategory"),
                            GestureDetector(
                              onTap: () {
                                showPicker(context, (int index) {
                                  setState(() {
                                    selectedSubCategory = index;
                                    selectedvarieties = 0;
                                    getVarieties();
                                  });
                                }, subCategories);
                              },
                              child: Container(
                                height: 60,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        subCategories[selectedSubCategory],
                                      ),
                                    ),
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
                          ],
                        ),
                        /////////////////VARITY////////////////////
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SmallHeading("Variety"),
                            GestureDetector(
                              onTap: () {
                                showPicker(context, (int index) {
                                  setState(() {
                                    selectedvarieties = index;
                                    getFoodItems();
                                  });
                                }, varieties);
                              },
                              child: Container(
                                height: 60,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(varieties[selectedvarieties]),
                                    ),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 30,
                    margin: EdgeInsets.only(top: 300, left: 20),
                    child: Text(
                      "Total items found : " +
                          searchedItemsList().length.toString(),
                      style: TextStyle(color: textMedium()),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 320),
                    child: ListView(
                      padding: EdgeInsets.all(20),
                      children: searchedItemsList(),
                    ),
                  ),
                ],
              ),
    );
  }

  List<Widget> searchedItemsList() {
    List<Widget> searchedItemsWidgets = [];
    for (int i = 0; i < foodItems.length; i++) {
      searchedItemsWidgets.add(
        GestureDetector(
          onTap: () {
            _getItemDetails(
              foodsCategoriesFromServer[selectedCategory]['child'][selectedSubCategory]['varieties'][selectedvarieties]['foods'][i]["id"],
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.food_bank_outlined, color: primaryColor, size: 19),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      foodItems[i].toString().trim(),
                      style: TextStyle(
                        color: textMedium(),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(color: dividerColor, height: 25),
            ],
          ),
        ),
      );
    }
    return searchedItemsWidgets;
  }

  bool _isLoading = false;
  List foodsCategoriesFromServer = [];

  void _getFoodCategories() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    try {
      setState(() {
        _isLoading = true;
      });
      foodsCategoriesFromServer = await apiService.getWithToken(
        getFoodCategory,
        {},
      );
      categories =
          foodsCategoriesFromServer.map((e) => e['title'].toString()).toList();
      getSubCategories();
      setState(() {
        _isLoading = false;
      });
      print(foodsCategoriesFromServer);
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

  itemDetail(Map itemData) {
    servingSizeController = TextEditingController();

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            servingSizeController.addListener(() {
              print("text changed");
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
            TextInputType.numberWithOptions(decimal: true),
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
          DefaultButton("Add Food", () {
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

  void submitFoodToMeal(
    int food_id,
    int food_serving_size_id,
    String food_amount,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    Map<String, dynamic> dataToPost = {
      "meal_meal_id": widget.meal_id,
      "food_id": food_id,
      "food_serving_size_id": food_serving_size_id,
      "food_amount": double.parse(food_amount),
    };
    print(dataToPost);
    //return;
    try {
      showLoadingDialog(context, "Adding food to meal..");
      Map data = await apiService.postWithToken(addMealFood, dataToPost);
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
