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

class AddServingSize extends StatefulWidget {
  dynamic myfoodItem;
  AddServingSize(this.myfoodItem, {super.key});

  @override
  State<AddServingSize> createState() => _AddServingSizeState();
}

class _AddServingSizeState extends State<AddServingSize> {
  int selectedUnitMeasuremnt = 0;
  //
  TextEditingController servingAmountController = new TextEditingController();
  TextEditingController caloriesController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    _getServingSizes();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.myfoodItem);
    return GestureDetector(
      onTap: () {
        dismissKeyboard(context);
      },
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          child: GestureDetector(
            onTap: () {
              isSavingloading ? () {} : _setMyFoodServingSize();
            },
            child: Container(
              height: 50,
              color: primaryColor,
              child: Center(
                child:
                    isSavingloading
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
          title: heading(widget.myfoodItem['title']),
          backgroundColor: backgroundColor(),
        ),
        body:
            _isLoading
                ? loader("Loading...")
                : SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SmallHeading("Unit of Measurement"),
                      GestureDetector(
                        onTap: () {
                          showPicker(context, (int index) {
                            setState(() {
                              selectedUnitMeasuremnt = index;
                            });
                          }, servingSizes);
                        },
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(servingSizes[selectedUnitMeasuremnt]),
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
                      SizedBox(height: 20),
                      SmallHeading("Serving Amount"),
                      CustomEditText(
                        !isSavingloading,
                        16,
                        servingAmountController,
                        TextInputType.number,
                        "Enter Serving Amount",
                      ),
                      SizedBox(height: 20),
                      SmallHeading("Calories (kcal)"),
                      CustomEditText(
                        !isSavingloading,
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
                      Column(children: nutrientBreakdown()),
                    ],
                  ),
                ),
      ),
    );
  }

  List<Widget> nutrientBreakdown() {
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

  List nutrientsToCollect = [];
  Map<int, dynamic> nutrientValuesForLocal = {};
  int carbs = 0;
  int protein = 0;
  int fat = 0;

  collectValues(int nutrient_id, int amount, String unit, String title) {
    bool foundInLoop = false;
    for (int i = 0; i < nutrientsToCollect.length; i++) {
      if (nutrientsToCollect[i]["nutrient_id"] == nutrient_id) {
        if (amount != 0) {
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
          nutrientsToCollect.remove(i);
          nutrientValuesForLocal[nutrient_id] = {
            "nutrient_id": nutrient_id,
            "amount": amount,
            "unit": unit,
          };
        }
        foundInLoop = true;
        break;
      }
    }
    if (!foundInLoop) {
      nutrientsToCollect.add({
        "nutrient_id": nutrient_id,
        "amount": amount,
        "unit": unit,
      });
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

    print(nutrientsToCollect);
  }

  Map<String, dynamic> nutritionsCollapse = {};
  nutritionBreakDownWidget(
    String title,
    String unit,
    List<dynamic> sub_nutrients,
    int id,
  ) {
    TextEditingController textEditingController = new TextEditingController();
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
          nutritionsCollapse[title] = !nutritionsCollapse[title];
        });
      },
      child: Container(
        color: white,
        //height: 50,
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
                // Text(
                //   value,
                //   style: TextStyle(
                //     color: textDark(),
                //     fontSize: 15,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                unit == ""
                    ? Container(height: 40)
                    : Container(
                      height: 40,
                      color: backgroundColor(),
                      width: 100,
                      child: CupertinoTextField(
                        enabled: !isSavingloading,
                        controller: textEditingController,
                        placeholder: unit,
                        keyboardType: TextInputType.number,
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
      TextEditingController textEditingController = new TextEditingController();

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
                          enabled: !isSavingloading,
                          controller: textEditingController,
                          placeholder: sub_nutrients[i]['nutrient_unit_code'],
                          keyboardType: TextInputType.number,
                        ),
                      ),
                  // Text(
                  //   sub_nutrients[i]['amount'] == 0
                  //       ? ""
                  //       : sub_nutrients[i]['amount'].toString() +
                  //           sub_nutrients[i]['nutrient_unit_code'],
                  //   style: TextStyle(
                  //     color: textDark(),
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.normal,
                  //   ),
                  // ),
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
  List servingSizesFromServer = [];
  List<String> servingSizes = [];

  void _getServingSizes() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    try {
      setState(() {
        _isLoading = true;
      });
      servingSizesFromServer = await apiService.getWithToken(
        getServingSizeUnits,
        {},
      );
      servingSizes =
          servingSizesFromServer.map((e) => e['unit'].toString()).toList();
      //getSubCategories();
      _getNutrients();
      print(servingSizes);
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

  List nutrientListFromServer = [];
  List<String> nutrientList = [];

  void _getNutrients() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    try {
      setState(() {
        _isLoading = true;
      });
      nutrientListFromServer = await apiService.getWithToken(
        getNutrientTreeList,
        {},
      );

      //getSubCategories();
      setState(() {
        _isLoading = false;
      });
      print(nutrientList);
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

  bool isSavingloading = false;
  void _setMyFoodServingSize() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    if (servingAmountController.text == "") {
      showToast("Please Fill Serving Amount");
      return;
    }
    if (caloriesController.text == "") {
      showToast("Please Fill Calories");
      return;
    }
    // if (protein == 0) {
    //   showToast("Please Fill Protein");
    //   return;
    // }
    // if (carbs == 0) {
    //   showToast("Please Fill Carbohydrates");
    //   return;
    // }
    // if (fat == 0) {
    //   showToast("Please Fill Fat");
    //   return;
    // }

    Map<String, dynamic> mapToSend = {
      "serving_value": int.parse(servingAmountController.text),
      "serving_size_unit_id":
          servingSizesFromServer[selectedUnitMeasuremnt]['id'],
      "protein": protein,
      "carbohydrate": carbs,
      "fat": fat,
      "calorie": int.parse(caloriesController.text),
      "food_nutrients": nutrientsToCollect,
    };
    print(mapToSend);
    // print(protein);
    // print(carbs);
    // print(fat);

    //return;

    try {
      setState(() {
        isSavingloading = true;
      });

      Map data = await apiService.postWithToken(
        setMyFoodsServiceSizes(widget.myfoodItem['id']),
        mapToSend,
      );
      setState(() {
        isSavingloading = false;
        showToast("Serving size added.");
        Navigator.pop(context);
        Navigator.pop(context, 0);
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
      setState(() => isSavingloading = false);
    }
  }
}
