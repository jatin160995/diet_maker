import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AddFoodWithServing extends StatefulWidget {
  const AddFoodWithServing({super.key});

  @override
  State<AddFoodWithServing> createState() => _AddFoodWithServingState();
}

class _AddFoodWithServingState extends State<AddFoodWithServing> {
  // Food fields
  TextEditingController foodNameController = TextEditingController();

  // Category
  List<String> categories = [];
  int selectedCategory = 0;

  // SubCategory
  List<String> subCategories = [];
  int selectedSubCategory = 0;

  // Varieties
  List<String> varieties = [];
  int selectedVariety = 0;

  // Serving size fields (from add_serving_size.dart)
  int selectedUnitMeasurement = 0;
  TextEditingController servingAmountController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();

  // Nutrients
  List nutrientListFromServer = [];
  List<String> nutrientList = [];
  List nutrientsToCollect = [];
  Map<int, dynamic> nutrientValuesForLocal = {};
  Map<String, bool> nutritionsCollapse = {};

  int carbs = 0;
  int protein = 0;
  int fat = 0;

  // Server data holders
  bool _isLoading = false;
  bool isSavingLoading = false;
  List foodsCategoriesFromServer = [];
  List servingSizesFromServer = [];
  List<String> servingSizes = [];

  @override
  void initState() {
    super.initState();
    _getFoodCategories();
    _getServingSizes();
    _getNutrients();
  }

  // -------------------- LOADERS / API GETS --------------------
  void _getFoodCategories() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    try {
      setState(() => _isLoading = true);
      foodsCategoriesFromServer = await apiService.getWithToken(
        getFoodCategory,
        {},
      );
      categories =
          foodsCategoriesFromServer.map((e) => e['title'].toString()).toList();
      // init subcategories and varieties
      getSubCategories();
      setState(() => _isLoading = false);
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

  void getSubCategories() {
    try {
      List<dynamic> subCat =
          foodsCategoriesFromServer[selectedCategory]['child'];
      subCategories = subCat.map((e) => e['title'].toString()).toList();
      // set default indexes
      selectedSubCategory = 0;
      getVarieties();
    } catch (e) {
      subCategories = [];
      varieties = [];
      print("getSubCategories error: $e");
    }
  }

  void getVarieties() {
    try {
      List<dynamic> varietyList =
          foodsCategoriesFromServer[selectedCategory]['child'][selectedSubCategory]['varieties'];
      varieties = varietyList.map((e) => e['name'].toString()).toList();
      selectedVariety = 0;
    } catch (e) {
      varieties = [];
      print("getVarieties error: $e");
    }
  }

  void _getServingSizes() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    try {
      // don't override _isLoading while loading categories
      servingSizesFromServer = await apiService.getWithToken(
        getServingSizeUnits,
        {},
      );
      servingSizes =
          servingSizesFromServer.map((e) => e['unit'].toString()).toList();
      setState(() {});
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
    }
  }

  void _getNutrients() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    try {
      nutrientListFromServer = await apiService.getWithToken(
        getNutrientTreeList,
        {},
      );
      // Initialize primary macros to 0 immediately after fetching
      _initializePrimaryNutrients();
      setState(() {});
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
    }
  }

  // -------------------- NUTRIENT INITIALIZATION & COLLECTION --------------------

  // Helper to pre-fill primary nutrients with 0
  void _initializePrimaryNutrients() {
    // Clear variables
    nutrientsToCollect.clear();
    nutrientValuesForLocal.clear();
    carbs = 0;
    protein = 0;
    fat = 0;

    for (var nutrient in nutrientListFromServer) {
      if (nutrient['is_primary'] == "Yes") {
        int nutrientId = nutrient['id'];
        String unit = nutrient['nutrient_unit_code'];

        Map<String, dynamic> initialValue = {
          "nutrient_id": nutrientId,
          "amount": 0,
          "unit": unit,
        };

        // Add to server list
        nutrientsToCollect.add(initialValue);
        // Add to local map for UI
        nutrientValuesForLocal[nutrientId] = initialValue;
      }
    }
  }

  collectValues(int nutrient_id, int amount, String unit, String title) {
    // Check if it is a mandatory primary macro
    bool isPrimaryMacro =
        (title == "Protein" || title == "Fat" || title == "Carbohydrates");

    bool foundInLoop = false;
    for (int i = 0; i < nutrientsToCollect.length; i++) {
      if (nutrientsToCollect[i]["nutrient_id"] == nutrient_id) {
        // Update if amount is not zero OR if it is a primary macro (keep it even if 0)
        if (amount != 0 || isPrimaryMacro) {
          nutrientsToCollect[i] = {
            "nutrient_id": nutrient_id,
            "amount": amount,
            "unit": unit,
          };
          nutrientValuesForLocal[nutrient_id] = {
            "nutrient_id": nutrient_id,
            "amount": amount,
            "unit": unit,
          };
        } else {
          // If sub-nutrient is 0, remove it
          nutrientsToCollect.removeAt(i);
          nutrientValuesForLocal.remove(nutrient_id);
        }
        foundInLoop = true;
        break;
      }
    }

    // If not found (for sub-nutrients) add it if amount > 0
    if (!foundInLoop && amount != 0) {
      Map<String, dynamic> newValue = {
        "nutrient_id": nutrient_id,
        "amount": amount,
        "unit": unit,
      };
      nutrientsToCollect.add(newValue);
      nutrientValuesForLocal[nutrient_id] = newValue;
    }

    if (title == "Protein") {
      protein = amount;
    }
    if (title == "Fat") {
      fat = amount;
    }
    if (title == "Carbohydrate") {
      carbs = amount;
    }
  }

  // -------------------- UI for nutrient breakdown --------------------
  Widget nutritionBreakDownWidget(
    String title,
    String unit,
    List<dynamic> sub_nutrients,
    int id,
  ) {
    TextEditingController textEditingController = TextEditingController();

    if (nutrientValuesForLocal.containsKey(id)) {
      textEditingController.text =
          nutrientValuesForLocal[id]['amount'].toString();
    }
    textEditingController.addListener(() {
      collectValues(
        id,
        textEditingController.text == ""
            ? 0
            : int.parse(textEditingController.text),
        unit,
        title,
      );
    });
    if (!nutritionsCollapse.containsKey(title)) {
      nutritionsCollapse[title] = false;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          nutritionsCollapse[title] = !nutritionsCollapse[title]!;
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
                unit == ""
                    ? Container(height: 40)
                    : Container(
                      height: 40,
                      color: backgroundColor(),
                      width: 100,
                      child: CupertinoTextField(
                        enabled: !isSavingLoading,
                        controller: textEditingController,
                        placeholder: unit,
                        keyboardType: TextInputType.number,
                      ),
                    ),
              ],
            ),
            Divider(height: 15, color: dividerColor),
            nutritionsCollapse[title]!
                ? subNutritionWidget(sub_nutrients)
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget subNutritionWidget(List sub_nutrients) {
    List<Widget> subNutrientsWidgetList = [];
    for (int i = 0; i < sub_nutrients.length; i++) {
      TextEditingController textEditingController = TextEditingController();

      if (nutrientValuesForLocal.containsKey(sub_nutrients[i]['id'])) {
        textEditingController.text =
            nutrientValuesForLocal[sub_nutrients[i]['id']]['amount'].toString();
      }
      textEditingController.addListener(() {
        collectValues(
          sub_nutrients[i]['id'],
          textEditingController.text == ""
              ? 0
              : int.parse(textEditingController.text),
          sub_nutrients[i]['nutrient_unit_code'],
          sub_nutrients[i]['title'],
        );
      });
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
                  sub_nutrients[i]['nutrient_unit_code'] == ""
                      ? Container(height: 40)
                      : Container(
                        height: 40,
                        color: backgroundColor(),
                        width: 100,
                        child: CupertinoTextField(
                          enabled: !isSavingLoading,
                          controller: textEditingController,
                          placeholder: sub_nutrients[i]['nutrient_unit_code'],
                          keyboardType: TextInputType.number,
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

  List<Widget> nutrientBreakdownWidgets() {
    List<Widget> breakdownWidgets = [];
    for (int i = 0; i < nutrientListFromServer.length; i++) {
      if (nutrientListFromServer[i]['is_primary'] == "No") {
        continue;
      }
      breakdownWidgets.add(
        nutritionBreakDownWidget(
          nutrientListFromServer[i]['title'],
          nutrientListFromServer[i]['nutrient_unit_code'],
          nutrientListFromServer[i]['sub_nutrients'],
          nutrientListFromServer[i]['id'],
        ),
      );
    }
    return breakdownWidgets;
  }

  // -------------------- SUBMIT (create food then add serving size) --------------------
  void _submitAll() async {
    // Validations (food + serving basics)
    if (foodNameController.text.trim() == "") {
      showToast("Food Name can not be empty");
      return;
    }
    if (foodsCategoriesFromServer.isEmpty) {
      showToast("Categories not loaded yet");
      return;
    }
    if (servingAmountController.text == "") {
      showToast("Please Fill Serving Amount");
      return;
    }
    if (caloriesController.text == "") {
      showToast("Please Fill Calories");
      return;
    }

    // Removed strict checks for protein/carbs/fat > 0 since we now allow 0.

    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    Map<String, dynamic> dataToPost = {
      "title": foodNameController.text.trim(),
      "category_id": 0,
      "sub_category_id": 0,
      "variety_id": 0,
    };

    try {
      setState(() {
        isSavingLoading = true;
      });
      showLoadingDialog(context, "Adding food...");

      // --- Create Food ---
      Map foodResp = await apiService.postWithToken(storeFood, dataToPost);
      if (foodResp == null || foodResp['id'] == null) {
        hideLoadingDialog(context);
        showToast("Failed to create food");
        setState(() => isSavingLoading = false);
        return;
      }
      final int createdFoodId = foodResp['id'];

      // --- Prepare serving size map ---
      Map<String, dynamic> mapToSend = {
        "serving_value": int.parse(servingAmountController.text),
        "serving_size_unit_id":
            servingSizesFromServer[selectedUnitMeasurement]['id'],
        "protein": protein,
        "carbohydrate": carbs,
        "fat": fat,
        "calorie": int.parse(caloriesController.text),
        "food_nutrients": nutrientsToCollect,
      };

      // --- Add Serving Size using returned food id ---
      Map serveResp = await apiService.postWithToken(
        setMyFoodsServiceSizes(createdFoodId),
        mapToSend,
      );

      // success
      hideLoadingDialog(context);
      setState(() {
        isSavingLoading = false;
      });
      showToast("Food and serving size added.");
      Navigator.pop(context, true);
    } catch (e) {
      hideLoadingDialog(context);
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
        showToast("Error occurred while saving. Please try again.");
      }
      setState(() {
        isSavingLoading = false;
      });
    }
  }

  // -------------------- BUILD UI --------------------
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        dismissKeyboard(context);
      },
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          child: GestureDetector(
            onTap: () {
              isSavingLoading ? () {} : _submitAll();
            },
            child: Container(
              height: 50,
              color: primaryColor,
              child: Center(
                child:
                    isSavingLoading
                        ? SpinKitWave(color: white)
                        : Text(
                          "Save",
                          style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
              ),
            ),
          ),
        ),
        appBar: AppBar(
          title: heading("Add Food & Serving"),
          backgroundColor: backgroundColor(),
        ),
        body:
            _isLoading
                ? loader("Loading data...")
                : SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //
                      children: [
                        SizedBox(height: 10),
                        SmallHeading("Food Name"),
                        CustomEditText(
                          true,
                          16,
                          foodNameController,
                          TextInputType.text,
                          "Food Name",
                        ),
                        SizedBox(height: 24),
                        heading("Serving Size Details"),
                        SizedBox(height: 12),
                        SmallHeading("Unit of Measurement"),
                        GestureDetector(
                          onTap: () {
                            showPicker(context, (int index) {
                              setState(() {
                                selectedUnitMeasurement = index;
                              });
                            }, servingSizes);
                          },
                          child: Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  servingSizes.isNotEmpty
                                      ? servingSizes[selectedUnitMeasurement]
                                      : "Select unit",
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
                        SizedBox(height: 16),
                        SmallHeading("Serving Amount"),
                        CustomEditText(
                          !isSavingLoading,
                          16,
                          servingAmountController,
                          TextInputType.number,
                          "Enter Serving Amount",
                        ),
                        SizedBox(height: 16),
                        SmallHeading("Calories (kcal)"),
                        CustomEditText(
                          !isSavingLoading,
                          16,
                          caloriesController,
                          TextInputType.number,
                          "Enter Calories",
                        ),
                        SizedBox(height: 10),
                        Divider(height: 30, color: dividerColor),
                        SizedBox(height: 5),
                        heading("Complete Nutrition Breakdown"),
                        SizedBox(height: 10),
                        Column(children: nutrientBreakdownWidgets()),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
