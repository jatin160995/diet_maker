import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AddFood extends StatefulWidget {
  int meal_id;
  AddFood(this.meal_id, {super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  TextEditingController searchController = TextEditingController();
  late LoginResponse userDetail;

  getUserDetails() async {
    userDetail = (await StorageService.getLoginData())!;
    setState(() {});
  }

  @override
  void initState() {
    searchController.addListener(() {
      print(searchController.text);
    });
    getUserDetails();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isFoodsLoading
              ? loader("Loading...")
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: CustomEditText(
                            true,
                            14,
                            searchController,
                            TextInputType.text,
                            "Search Food",
                            textInputAction: TextInputAction.search,
                            onSubmitted: (v) {
                              _searchFood();
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 55,
                            decoration: borderRadius(white, 8),
                            child: IconButton(
                              onPressed: () {
                                _searchFood();
                              },
                              icon:
                                  _isLoading
                                      ? Container(
                                        height: 30,
                                        child: SpinKitCircle(
                                          color: primaryColor,
                                        ),
                                      )
                                      : Icon(
                                        Icons.search,
                                        color: primaryColor,
                                        size: 27,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  foodsFromServer.length > 0
                      ? Container(
                        padding: EdgeInsets.only(left: 20, bottom: 20),
                        child: Text(
                          "Total items found : " +
                              foodsFromServer.length.toString(),
                          style: TextStyle(color: textMedium()),
                        ),
                      )
                      : Container(),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(20),
                      children: [Column(children: searchedItemsList())],
                    ),
                  ),
                ],
              ),
    );
  }

  List<Widget> myFoodItemsWidgetList() {
    List<Widget> searchedItemsWidgets = [];
    for (int i = 0; i < myFoodsFromServer.length; i++) {
      searchedItemsWidgets.add(
        GestureDetector(
          onTap: () {
            _getItemDetails(myFoodsFromServer[i]["id"]);
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
                      myFoodsFromServer[i]["title"].toString().trim(),
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

  List<Widget> searchedItemsList() {
    List<Widget> searchedItemsWidgets = [];
    for (int i = 0; i < foodsFromServer.length; i++) {
      searchedItemsWidgets.add(
        GestureDetector(
          onTap: () {
            _getItemDetails(foodsFromServer[i]["id"]);
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
                      foodsFromServer[i]["title"].toString().trim(),
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
  List foodsFromServer = [];
  _searchFood() async {
    if (searchController.text == "") {
      showToast("Fill keyword to search");
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });

      foodsFromServer = await apiService.getWithToken(
        searchFood + "?keyword=" + searchController.text,
        {},
      );
      setState(() {
        _isLoading = false;
      });
      print(foodsFromServer);
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

  bool _isFoodsLoading = false;
  List myFoodsFromServer = [];
  void _getMyFoods(bool loadingState) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    try {
      setState(() {
        _isFoodsLoading = loadingState;
      });
      Map data = await apiService.getWithToken(getMyFoods, {});
      myFoodsFromServer = data['table']['data'];
      setState(() {
        _isFoodsLoading = false;
      });
      print(myFoodsFromServer);
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
      setState(() => _isFoodsLoading = false);
    }
  }
}
