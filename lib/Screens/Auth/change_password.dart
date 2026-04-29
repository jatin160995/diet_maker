import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldController = new TextEditingController();
  TextEditingController newController = new TextEditingController();
  TextEditingController confirmController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("Change Password"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SizedBox(height: 10),
          Text("Old Password"),
          SizedBox(height: 8),
          CustomEditText(
            true,
            15,
            oldController,
            TextInputType.text,
            "Old Password",
            isPassword: true,
          ),
          SizedBox(height: 10),
          Text("New Password"),
          SizedBox(height: 8),
          CustomEditText(
            true,
            15,
            newController,
            TextInputType.text,
            "New Password",
            isPassword: true,
          ),
          SizedBox(height: 10),
          Text("Confirm Password"),
          SizedBox(height: 8),
          CustomEditText(
            true,
            15,
            confirmController,
            TextInputType.text,
            "Confirm Password",
            isPassword: true,
          ),

          SizedBox(height: 30),

          DefaultButton("Update", () {
            _editPassword();
          }, isLoading: _isLoading),
        ],
      ),
    );
  }

  bool _isLoading = false;

  void _editPassword() async {
    if (oldController.text == "" ||
        newController.text == "" ||
        confirmController.text == "") {
      showToast("Please fill all fields");
      return;
    }

    if (newController.text != confirmController.text) {
      showToast("New password and Old password doesn't matched. ");
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    Map<String, dynamic> dataToPost = {
      "old_password": oldController.text,
      "new_password": newController.text,
    };
    try {
      setState(() {
        _isLoading = true;
      });
      Map data = await apiService.patchRequest(updatePassword, {}, dataToPost);

      setState(() async {
        _isLoading = false;
        showToast("Password Updated");
        oldController.clear();
        newController.clear();
        confirmController.clear();
      });
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
