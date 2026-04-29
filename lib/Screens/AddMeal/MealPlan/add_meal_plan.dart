import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Screens/my_meal_plan_calculator.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Assuming showToast, showLoadingDialog etc. are here

class AddMealPlanScreen extends StatefulWidget {
  const AddMealPlanScreen({Key? key}) : super(key: key);

  @override
  State<AddMealPlanScreen> createState() => _AddMealPlanScreenState();
}

class _AddMealPlanScreenState extends State<AddMealPlanScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool _isPrimary = true;
  int _noOfMeals = 3;

  bool _isLoading = false;

  Future<void> submitMealPlan() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final apiService = ApiService();

    final userDetail = (await StorageService.getLoginData())!;
    final dietaryPreferenceId = userDetail.dietaryPreference.id;

    Map<String, dynamic> dataToPost = {
      "title": _titleController.text.trim(),
      "dietary_preference_id": dietaryPreferenceId,
      "color": "#F96A27",
      "is_primary": _isPrimary ? "Yes" : "No",
      "protein_amount": 0,
      "carbohydrate_amount": 0,
      "fat_amount": 0,
      "calorie_amount": 0,
      "activated_at": "",
      "status": "Incomplete",
      "total_meal": _noOfMeals,
    };
    print(dataToPost);

    if (dataToPost["title"].isEmpty) {
      showToast("Please enter plan title");
      return;
    }

    try {
      setState(() => _isLoading = true);
      showLoadingDialog(context, "Creating Meal Plan...");
      Map response = await apiService.postWithToken(createMealPlan, dataToPost);
      hideLoadingDialog(context);
      Navigator.pop(context, true);
      showToast("Meal Plan created successfully!");
    } catch (e) {
      hideLoadingDialog(context);
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
        showToast("Something went wrong. Please try again.");
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void showMealCountPicker() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => Container(
            height: 250,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      CupertinoButton(
                        child: const Text("Done"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: _noOfMeals - 1,
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() => _noOfMeals = index + 1);
                    },
                    children: List.generate(
                      6,
                      (index) => Center(child: Text("${index + 1} Meals")),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("Add New Meal Plan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomEditText(
              true,
              14,
              _titleController,
              TextInputType.text,
              "Plan Title (Max. 10 characters)",
              width: double.infinity,
              length: 10,
            ),
            const SizedBox(height: 25),

            /// Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Set as Primary Plan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                CupertinoSwitch(
                  value: _isPrimary,
                  activeColor: primaryColor,
                  onChanged: (val) => setState(() => _isPrimary = val),
                ),
              ],
            ),
            const SizedBox(height: 25),

            /// Picker for meal count
            GestureDetector(
              onTap: showMealCountPicker,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Number of Meals: $_noOfMeals"),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryColor),
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          showGenericDialog(
                            context,
                            "Generate Meal Plan",
                            "This will automatically create a personalized meal plan based on your calorie goals",
                            "Generate",
                            () async {
                              autoAssignMealPlan();
                              // print(dailyCalories);
                            },
                          );
                        },
                child: const Text(
                  "Auto Generate Plan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 10),
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

            /// Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : submitMealPlan,
                child:
                    _isLoading
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : const Text(
                          "Create Meal Plan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isLoadingAutoAssign = false;
  void autoAssignMealPlan() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    int? dailyCalories =
        (await StorageService.getLoginData())
            ?.dietaryPreference
            .dailyCalorieIntake;
    Map<String, dynamic> mapToSend = {
      "calories": dailyCalories,
      "no_of_meals": _noOfMeals,
      "title": _titleController.text.toString(),
    };
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
      print("mealPlanNew----" + data["id"].toString());

      setState(() {
        //showToast("hello");
        // userDetail.dietaryPreference.primaryMealPlanId = data['id'];
        hideLoadingDialog(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyMealPlanCalculator(mealPlanId: data["id"]),
          ),
        );
        //_getMealPlansRequest();

        isLoadingAutoAssign = false;
      });
      //print(data);
    } catch (e) {
      if (e is ApiException) {
        showToastLong(e.message.toString());
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
