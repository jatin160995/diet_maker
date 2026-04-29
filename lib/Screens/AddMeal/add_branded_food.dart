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
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class AddBrandedFood extends StatefulWidget {
  int meal_id;
  AddBrandedFood(this.meal_id, {super.key});

  @override
  State<AddBrandedFood> createState() => _AddBrandedFoodState();
}

class _AddBrandedFoodState extends State<AddBrandedFood> {
  TextEditingController searchController = TextEditingController();
  late LoginResponse userDetail;
  String result = "";

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
      body: Column(
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
                    "Search Branded Food",
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
                                child: SpinKitCircle(color: primaryColor),
                              )
                              : Icon(
                                Icons.search,
                                color: primaryColor,
                                size: 27,
                              ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 55,
                    decoration: borderRadius(white, 8),
                    child: IconButton(
                      onPressed: () async {
                        String? res = await SimpleBarcodeScanner.scanBarcode(
                          context,
                          barcodeAppBar: const BarcodeAppBar(
                            appBarTitle: 'Test',
                            centerTitle: false,
                            enableBackButton: true,
                            backButtonIcon: Icon(Icons.arrow_back_ios),
                          ),
                          isShowFlashIcon: true,
                          delayMillis: 500,
                          cameraFace: CameraFace.back,
                          //scanFormat: ScanFormat.ONLY_BARCODE,
                        );
                        setState(() {
                          result = res as String;
                          // showToast(result);
                          _getItemDetailsByGTIN(result);
                        });
                        // _searchFood();
                      },
                      icon:
                          _isLoading
                              ? Container(
                                height: 30,
                                child: SpinKitCircle(color: primaryColor),
                              )
                              : Icon(
                                Icons.camera_alt,
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
                  "Total items found : " + foodsFromServer.length.toString(),
                  style: TextStyle(color: textMedium()),
                ),
              )
              : Container(),
          Expanded(
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
    for (int i = 0; i < foodsFromServer.length; i++) {
      searchedItemsWidgets.add(
        GestureDetector(
          onTap: () {
            _getItemDetails(foodsFromServer[i]["fdc_id"]);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.food_bank_outlined, color: primaryColor, size: 19),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodsFromServer[i]["name"].toString().trim(),
                          style: TextStyle(
                            color: textMedium(),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        foodsFromServer[i]['brand_name'].toString() == ""
                            ? Container()
                            : SmallHeading(
                              foodsFromServer[i]['brand_name'].toString(),
                            ),
                      ],
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
        searchBrandedFood + "?keyword=" + searchController.text,
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

  void _getItemDetailsByGTIN(String foodItemId) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoadingItem = true;
      });
      showLoadingDialog(context, "Item details loading..");

      Map data = await apiService.getWithToken(
        getBrandedFoodDetailByUpc + foodItemId.toString(),
        {},
      );

      hideLoadingDialog(context);
      setState(() {
        _isLoadingItem = false;
      });
      if (data.containsKey("fdc_id")) {
        _getItemDetails(data['fdc_id']);
      } else {
        showToast("Food item not found.");
      }

      //itemDetail(data);

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
    servingSizeController.text = "1";
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
          heading(data['name'].toString()),
          SmallHeading("Brand"),
          heading(data['brand_owner']['name'].toString()),

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
            TextInputType.numberWithOptions(decimal: true),
            "",
            backgroundColor: dividerColor,
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
                      data['serving_sizes'][selectedSelectedUnit]['protein'] ==
                              null
                          ? "0"
                          : data['serving_sizes'][selectedSelectedUnit]['protein'],
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
                      (data['serving_sizes'][selectedSelectedUnit]['carbohydrate'] ==
                              null
                          ? "0"
                          : data['serving_sizes'][selectedSelectedUnit]['carbohydrate']),
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
                      data['serving_sizes'][selectedSelectedUnit]['fat'] == null
                          ? "0"
                          : data['serving_sizes'][selectedSelectedUnit]['fat'],
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
      "branded_food_id": food_id,
      "branded_food_serving_size_id": food_serving_size_id,
      "food_amount": double.parse(food_amount),
    };
    print(dataToPost);
    //return;
    try {
      showLoadingDialog(context, "Adding food to meal..");
      print(addMealBrandedFood);
      Map data = await apiService.postWithToken(addMealBrandedFood, dataToPost);
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
