import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // for showToast, showLoadingDialog, etc.

class EditMealScreen extends StatefulWidget {
  final int mealId;
  final int mealPlanId;

  const EditMealScreen({
    Key? key,
    required this.mealId,
    required this.mealPlanId,
  }) : super(key: key);

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  String get formattedTime {
    if (_selectedTime == null) return "Select Meal Time";
    final hour = _selectedTime!.hour.toString().padLeft(2, '0');
    final minute = _selectedTime!.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00";
  }

  String get formattedTimeToDisplay {
    if (_selectedTime == null) return "Select Meal Time";

    final hour = _selectedTime!.hourOfPeriod.toString().padLeft(2, '0');
    final minute = _selectedTime!.minute.toString().padLeft(2, '0');
    final period = _selectedTime!.period == DayPeriod.am ? "AM" : "PM";

    return "$hour:$minute $period";
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,

      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> submitEditMeal() async {
    if (_selectedTime == null) {
      showToast("Please select meal time");
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final apiService = ApiService();

    Map<String, dynamic> dataToPost = {
      "meal_plan_id": widget.mealPlanId,
      "meal_time": formattedTime,
    };

    print(dataToPost);

    try {
      setState(() => _isLoading = true);
      showLoadingDialog(context, "Updating Meal...");

      final endpoint = "diet/meal-meals/${widget.mealId}";
      await apiService.putRequest(endpoint, {}, dataToPost);

      hideLoadingDialog(context);
      showToast("Meal updated successfully!");
      Navigator.pop(context, true);
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

  Future<void> confirmDeleteMeal() async {
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text("Delete Meal"),
            content: const Text("Are you sure you want to delete this meal?"),
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
                  //deleteMeal();
                },
              ),
            ],
          ),
    );
  }

  // Future<void> deleteMeal() async {
  //   final apiService = ApiService();

  //   try {
  //     setState(() => _isLoading = true);
  //     showLoadingDialog(context, "Deleting Meal...");

  //     final endpoint = "diet/meal-meals/${widget.mealId}";
  //     await apiService.deleteWithToken(endpoint, {});

  //     hideLoadingDialog(context);
  //     showToast("Meal deleted successfully!");
  //     Navigator.pop(context, true);
  //   } catch (e) {
  //     hideLoadingDialog(context);
  //     if (e is ApiException) {
  //       showToast(e.message.toString());
  //       print("API Error: ${e.message}, status: ${e.code}");
  //       print("Details: ${e.errorBody}");
  //     } else {
  //       print("Unexpected error: $e");
  //       showToast("Something went wrong while deleting meal.");
  //     }
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: heading("Edit Meal"),
        backgroundColor: backgroundColor(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            smallHeading("Set new meal time"),
            SizedBox(height: 5),
            GestureDetector(
              onTap: _selectTime,
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
                    Text(
                      formattedTimeToDisplay,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Column(
              children: [
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
                    onPressed: _isLoading ? null : submitEditMeal,
                    child:
                        _isLoading
                            ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Update Meal",
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : confirmDeleteMeal,
                    child: const Text(
                      "Delete Meal",
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
