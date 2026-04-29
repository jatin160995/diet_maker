import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/utils/globals.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';

class Coaching extends StatefulWidget {
  const Coaching({super.key});

  @override
  State<Coaching> createState() => _CoachingState();
}

class _CoachingState extends State<Coaching> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController goalController = new TextEditingController();
  TextEditingController coachingTypeController = new TextEditingController();

  int selectedcoachingType = 0;

  @override
  void initState() {
    super.initState();
    coachingTypeController.text = coachingTypeList[selectedcoachingType];
  }

  List<String> coachingTypeList = [
    "Diet & Nutrition",
    "Fitness & Training",
    "Lifestyle & Habits",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("Coaching Plans"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Container(
            decoration: borderRadius(white, 20),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(imagesPath + "coach.jpg"),
          ),
          SizedBox(height: 20),
          Text(
            "Diet Maker is a meal-planning software platform.\n\nSome users choose to work with a coach who may use Diet Maker as part of their workflow. Coaching services are offered separately and are governed by a separate coaching agreement. Coaching services are not part of the Diet Maker app or Service.\n\nComplete the form below to receive information about available coaching plans and next steps by email.",
            style: TextStyle(color: textDark(), fontSize: 14),
          ),
          SizedBox(height: 20),
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

          ///
          SizedBox(height: 10),
          SmallHeading("Your Goal"),
          CustomEditText(
            true,
            14,
            goalController,
            TextInputType.text,
            "e.g. Lose 5 kg, Gain muscle, Improve energy levels",
          ),

          // ///
          // SizedBox(height: 10),
          // SmallHeading("Preferred Coaching Type"),
          // GestureDetector(
          //   onTap: () {
          //     showPicker(context, (int index) {
          //       setState(() {
          //         coachingTypeController.text = coachingTypeList[index];
          //         selectedcoachingType = index;
          //       });
          //     }, coachingTypeList);
          //   },
          //   child: Container(
          //     height: 60,
          //     padding: EdgeInsets.symmetric(horizontal: 15),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(coachingTypeList[selectedcoachingType]),
          //         Icon(
          //           Icons.keyboard_arrow_down_outlined,
          //           color: textLightest(),
          //         ),
          //       ],
          //     ),
          //     decoration: BoxDecoration(
          //       color: white,
          //       borderRadius: BorderRadius.all(Radius.circular(15)),
          //       border: Border.all(color: dividerColor),
          //     ),
          //   ),
          // ),
          SizedBox(height: 30),
          DefaultButton("Submit Request", () {
            sendValuesToServer();
          }, isLoading: _isLoading),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  bool _isLoading = false;

  sendValuesToServer() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    //Setting up the data
    Map<String, dynamic> mapToSend = {};
    if (nameController.text == "" ||
        emailController.text == "" ||
        goalController.text == "" ||
        coachingTypeController.text == "") {
      showToast("Fill all required fields.");
      return;
    }

    // Navigator.pop(context);
    // return;
    mapToSend = {
      "name": nameController.text,
      "email": emailController.text,
      "goal": goalController.text,
      "coaching_type": coachingTypeController.text,
    };
    print(mapToSend);

    //return;
    try {
      showLoadingDialog(context, "Sending request...");
      Map data = await apiService.postWithToken(submitCoaching, mapToSend);
      if (data['success']) {
        hideLoadingDialog(context);
        showToast(
          "Thank you! Our coaching team will review your request and get back to you soon.",
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (e is ApiException) {
        if (e.code == 422) {
          showToast("Something went wrong");
        }
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
