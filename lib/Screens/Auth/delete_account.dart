import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Screens/Auth/login.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:flutter/material.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        title: heading("Delete"),
        backgroundColor: backgroundColor(),
      ),
      body: ListView(
        padding: EdgeInsets.all(30),
        children: [
          SizedBox(height: 50),
          Text(
            "Delete your account?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textDark(),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.hide_source, color: primaryColor),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headingSmall("Permanently Delete Your Account"),
                    Text(
                      "Deleting your account permanently removes your profile, meal plans, preferences, and progress data from our system. You will no longer receive notifications or have access to your account. This action cannot be undone.",
                      style: TextStyle(color: textMedium(), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Icon(Icons.delete_forever, color: primaryColor),
          //     SizedBox(width: 10),
          //     Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           headingSmall("Deleting your account is permanent"),
          //           Text(
          //             "Deleting your account will permanently erase all your data, including meal plans, nutrition targets, and progress history. Once deleted, your account cannot be recovered.",
          //             style: TextStyle(color: textMedium(), fontSize: 13),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          SizedBox(height: 30),
          DefaultButton("Delete Account", isLoading: _isLoading, () {
            showGenericDialog(
              context,
              "Delete Accoount",
              "Are you sure, you want to De-activate account ?",
              "Delete",
              () {
                deactivateAccount();
              },
            );
          }),
          // SizedBox(height: 10),
          // DefaultButton("Delete Account", () {}),
        ],
      ),
    );
  }

  logoutUser() async {
    await StorageService.clearLoginData();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (route) => false,
    );
  }

  bool _isLoading = false;
  deactivateAccount() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });

      await apiService.getWithToken(deactivateAccountUrl, {});
      setState(() {
        _isLoading = false;
        logoutUser();
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
