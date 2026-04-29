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

class EditMealPlanScreen extends StatefulWidget {
  final Map<dynamic, dynamic> mealPlanData;

  const EditMealPlanScreen({Key? key, required this.mealPlanData})
    : super(key: key);

  @override
  State<EditMealPlanScreen> createState() => _EditMealPlanScreenState();
}

class _EditMealPlanScreenState extends State<EditMealPlanScreen> {
  late TextEditingController _titleController;
  bool _isPrimary = false;
  bool _isLoading = false;

  late int mealPlanId;
  late int dietaryPreferenceId;

  @override
  void initState() {
    super.initState();
    final data = widget.mealPlanData;
    mealPlanId = data['id'];
    dietaryPreferenceId = data['dietary_preference_id'];
    _titleController = TextEditingController(text: data['title'] ?? "");
    _isPrimary = (data['is_primary'] == "Yes");
  }

  Future<void> updateMealPlan() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final apiService = ApiService();

    Map<String, dynamic> dataToPut = {
      "title": _titleController.text.trim(),
      "dietary_preference_id": dietaryPreferenceId,
      //"color": "#F96A27",
      "is_primary": _isPrimary ? "Yes" : "No",
      // "protein_amount": widget.mealPlanData['protein_amount'] ?? 0,
      // "carbohydrate_amount": widget.mealPlanData['carbohydrate_amount'] ?? 0,
      // "fat_amount": widget.mealPlanData['fat_amount'] ?? 0,
      // "calorie_amount": widget.mealPlanData['calorie_amount'] ?? 0,
      // "activated_at": widget.mealPlanData['activated_at'] ?? "",
      "status": widget.mealPlanData['status'] ?? "Complete",
    };

    try {
      setState(() => _isLoading = true);
      showLoadingDialog(context, "Updating meal plan...");

      await apiService.putRequest("$editMealPlan$mealPlanId", {}, dataToPut);

      hideLoadingDialog(context);
      showToast("Meal plan updated successfully!");
      Navigator.pop(context, true);
    } catch (e) {
      hideLoadingDialog(context);
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        showToast("Unexpected error: $e");
        print(e);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> confirmDeleteMealPlan() async {
    if (_isPrimary) {
      showToast("You can't delete Primary Meal Plan.");
      return;
    }
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text("Delete Meal Plan"),
            content: const Text(
              "Are you sure you want to delete this meal plan?",
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text("Delete"),
                onPressed: () {
                  Navigator.pop(context);
                  deleteMealPlan();
                },
              ),
            ],
          ),
    );
  }

  Future<void> deleteMealPlan() async {
    final apiService = ApiService();

    try {
      setState(() => _isLoading = true);
      showLoadingDialog(context, "Deleting meal plan...");

      await apiService.deleteWithToken("$editMealPlan$mealPlanId", {});

      hideLoadingDialog(context);
      showToast("Meal plan deleted successfully!");
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    } catch (e) {
      hideLoadingDialog(context);
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
      } else {
        showToast("Unexpected error while deleting meal plan.");
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPrimaryPlan = _isPrimary;

    return Scaffold(
      appBar: AppBar(
        title: heading("Edit Meal Plan"),
        backgroundColor: backgroundColor(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmallHeading("Meal Plan Title (Max. 10 characters)"),
            CustomEditText(
              true,
              16,
              _titleController,
              TextInputType.text,
              "Meal Plan Title",
              width: double.infinity,
              length: 10,
            ),

            const SizedBox(height: 20),
            if (!isPrimaryPlan)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Set as Primary",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  CupertinoSwitch(
                    value: _isPrimary,
                    activeColor: const Color(0xFFF96A27),
                    onChanged: (val) {
                      setState(() => _isPrimary = val);
                    },
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text(
                      "Primary Plan",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF96A27),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : updateMealPlan,
                    child:
                        _isLoading
                            ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Update Meal Plan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 12),
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
                    onPressed: _isLoading ? null : confirmDeleteMealPlan,
                    child: const Text(
                      "Delete Meal Plan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
