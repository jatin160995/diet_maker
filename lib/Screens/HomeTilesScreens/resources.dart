// import 'dart:convert';

// import 'package:diet_maker/Exception/api_exception.dart';
// import 'package:diet_maker/services/storage_service.dart';
// import 'package:diet_maker/utils/api_endpoints.dart';
// import 'package:diet_maker/utils/color_utils.dart';
// import 'package:diet_maker/utils/design_utils.dart';
// import 'package:expandable/expandable.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class Resources extends StatefulWidget {
//   const Resources({super.key});

//   @override
//   State<Resources> createState() => _ResourcesState();
// }

// class _ResourcesState extends State<Resources> {
//   @override
//   void initState() {
//     getAllFaqs();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: white,
//       appBar: AppBar(
//         backgroundColor: backgroundColor(),
//         title: heading("Resources"),
//       ),
//       body:
//           _isLoading
//               ? loader("Loading FAQs...")
//               : ListView(
//                 padding: EdgeInsets.all(20),
//                 children: [
//                   // heading("10 Must-Know Tips Before Starting your Meal Plan"),
//                   SizedBox(height: 20),
//                   Column(children: faqWidgets()),
//                 ],
//               ),
//     );
//   }

//   List<Widget> faqWidgets() {
//     List<Widget> faqWidgetList = [];
//     for (int i = 0; i < allFaqFromServer.length; i++) {
//       faqWidgetList.add(
//         Container(
//           padding: EdgeInsets.all(10),
//           decoration: borderRadius(backgroundColor(), 8),
//           margin: EdgeInsets.symmetric(vertical: 8),
//           child: ExpandablePanel(
//             header: Container(
//               margin: EdgeInsets.only(bottom: 8),
//               child: Text(
//                 allFaqFromServer[i]['topic'],
//                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//               ),
//             ),
//             collapsed: Text(
//               allFaqFromServer[i]['content'].toString(),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(color: textMedium()),
//             ),
//             expanded: Text(
//               allFaqFromServer[i]['content'],
//               style: TextStyle(color: textMedium()),
//             ),
//           ),
//         ),
//       );
//     }
//     return faqWidgetList;
//   }

//   bool _isLoading = false;
//   List<dynamic> allFaqFromServer = [];
//   getAllFaqs() async {
//     String? token = (await StorageService.getLoginData())?.accessToken;
//     print('$baseUrl$allFaqs');
//     print(token);
//     setState(() {
//       _isLoading = true;
//     });
//     final response = await http.get(
//       Uri.parse('$baseUrl$allResources'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         if (token != null) 'Authorization': 'Bearer $token',
//       },
//     );
//     print(response.body);
//     // print(response.statusCode);
//     if (response.statusCode == 200) {
//       allFaqFromServer = json.decode(response.body);
//       setState(() {
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//       throw ApiException(
//         message:
//             json.decode(response.body)['message'] ?? 'Something went wrong',
//         code: response.statusCode,
//         errorBody: "API Error",
//       );
//     }
//   }
// }
import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';
// Import your utilities and services here

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  // Controllers for the input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final ApiService apiService = ApiService();

  bool _isLoading =
      false; // To manage button state, though not used in your sample

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // Adapted function to handle newsletter subscription
  Future<void> _subscribeToNewsletter() async {
    // Dismiss the keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    // Basic Validation
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      showToast("Please enter your name and email.");
      return;
    }

    // Set loading state
    setState(() => _isLoading = true);

    // Setting up the data for the API
    Map<String, dynamic> mapToSend = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
    };
    print("Newsletter data: $mapToSend");

    try {
      showLoadingDialog(context, "Subscribing...");

      // Perform the POST request to the newsletter API
      Map<String, dynamic> data = await apiService.postWithToken(
        newsletterSubscribe,
        mapToSend,
      );

      hideLoadingDialog(context);

      if (data['success']) {
        showToast("Success! You are now subscribed to our newsletter.");
        // Clear fields on successful submission
        nameController.clear();
        emailController.clear();
      } else {
        // Handle success: false, if API returns a non-200 status but a success: false body
        showToast("Subscription failed. Please try again.");
      }
    } catch (e) {
      hideLoadingDialog(context);

      if (e is ApiException) {
        // Handle specific API errors
        if (e.code == 422) {
          // This often means validation failed (e.g., email already exists)
          showToast("Subscription failed: Email may already be registered.");
        } else {
          showToast("Server Error: Please try again.");
        }
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        // Handle unexpected network or parsing errors
        showToast("An unexpected error occurred.");
        print("Unexpected error: $e");
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: heading("Resources"),
        backgroundColor: backgroundColor(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Subscribe to our newsletter for fitness tips and updates!',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24.0),

            // Name Field
            SmallHeading("Name"),
            CustomEditText(
              true,
              14,
              nameController,
              TextInputType.text,
              "Full Name",
            ),

            ///
            SizedBox(height: 10),

            SmallHeading("Email"),
            CustomEditText(
              true,
              14,
              emailController,
              TextInputType.emailAddress,
              "Email",
            ),
            const SizedBox(height: 32.0),

            // Subscribe Button
            ElevatedButton(
              onPressed: _isLoading ? null : _subscribeToNewsletter,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Subscribe',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
