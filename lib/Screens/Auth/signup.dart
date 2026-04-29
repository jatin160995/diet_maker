import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Models/user_profile.dart';
import 'package:diet_maker/Screens/Auth/login.dart';
import 'package:diet_maker/Screens/Auth/signup2.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';

import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController fNameController = new TextEditingController();
  TextEditingController lNameController = new TextEditingController();
  TextEditingController ageController = new TextEditingController();
  TextEditingController genderController = new TextEditingController();
  TextEditingController measurementController = TextEditingController();
  List<String> measurements = ["Imperial", "Metric"];

  late String selectedDate;
  late BuildContext buildContext;

  List<String> gender = <String>['Male', 'Female'];
  late LoginResponse userDetail;

  getDetails() async {
    userDetail = (await StorageService.getLoginData())!;
    fNameController = TextEditingController(text: userDetail.profile.firstName);
    lNameController = TextEditingController(text: userDetail.profile.lastName);
    genderController = TextEditingController(text: userDetail.profile.gender);

    ageController = TextEditingController(
      text: userDetail.profile.age.toString(),
    );
    measurementController = TextEditingController(
      text: userDetail.profile.preferredMeasurement,
    );

    selectedDate = userDetail.profile.dob.toString();
    setState(() {});
  }

  @override
  void initState() {
    getDetails();
    ageController.text = "Age";
    genderController.text = "Gender";

    super.initState();
  }

  logoutUser() async {
    await StorageService.clearLoginData();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        title: headingBig("My Profile"),
        backgroundColor: backgroundLight,
        actions: [
          TextButton(
            onPressed: () {
              logoutUser();
            },
            child: Text("Logout", style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
      body: Container(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Step 1",
                  style: TextStyle(color: textLightest(), fontSize: 16),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 7,
                      width: 40,
                      decoration: borderRadius(primaryColor, 4),
                    ),
                    SizedBox(width: 10),
                    Container(
                      height: 7,
                      width: 40,
                      decoration: borderRadius(textLightest(), 4),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              //height: 90,
              margin: EdgeInsets.all(20),
              decoration: borderRadius(lightBackgroundColor(), 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/user_demo.png", height: 80),
                    ],
                  ),
                  SizedBox(height: 20),
                  SmallHeading("First Name"),
                  CustomEditText(
                    true,
                    16,
                    fNameController,
                    TextInputType.text,
                    "First Name",
                  ),
                  SizedBox(height: 10),
                  SmallHeading("Last Name"),
                  CustomEditText(
                    true,
                    16,
                    lNameController,
                    TextInputType.text,
                    "Last Name",
                  ),
                  SizedBox(height: 10),
                  SmallHeading("Age"),
                  GestureDetector(
                    onTap: () {
                      selectDate(buildContext, (d) {
                        setState(() {
                          selectedDate = readableDate(d);
                          ageController.text = calculateAge(d).toString();
                        });
                      });
                    },
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(ageController.text),
                          Icon(Icons.calendar_month, color: textLightest()),
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
                  SmallHeading("Gender"),
                  GestureDetector(
                    onTap: () {
                      showPicker(buildContext, (int index) {
                        setState(() {
                          genderController.text = gender[index];
                        });
                      }, gender);
                    },
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(genderController.text),
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
                  SmallHeading("Preferred Measurement"),
                  GestureDetector(
                    onTap: () {
                      showPicker(context, (int index) {
                        setState(() {
                          measurementController.text = measurements[index];
                        });
                      }, measurements);
                    },
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(measurementController.text),
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
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "We use this information to generate and deliver personalized daily recommendations tailored to you.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: textMedium()),
              ),
            ),
            SizedBox(height: 20),
            DefaultButton("Submit", () {
              _editUser();
            }, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }

  bool _isLoading = false;

  void _editUser() async {
    if (fNameController.text == "" ||
        lNameController.text == "" ||
        ageController.text == "Age" ||
        genderController.text == "Gender" ||
        measurementController.text == "Preferred Measurement") {
      showToast("Please all the fields");
      return;
    }

    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    Map<String, dynamic> dataToPost = {
      "first_name": fNameController.text,
      "last_name": lNameController.text,
      //"email": emailController.text,
      "dob": selectedDate,
      "gender": genderController.text,
      "timezone": currentTimeZone,
      "preferred_measurement": measurementController.text,
    };
    // if (measurementController.text.toLowerCase() == "imperial") {
    //   final parts = heightController.text.split(".");
    //   dataToPost["height_feet"] = parts[0];
    //   dataToPost["height_in"] = parts.length > 1 ? parts[1] : "0";
    //   dataToPost["weight_lbs"] = weightController.text;
    // } else {
    //   dataToPost["height_cm"] = heightController.text;
    //   dataToPost["weight_kg"] = weightController.text;
    // }

    //return;
    try {
      setState(() {
        _isLoading = true;
      });

      Map data = await apiService.putRequest(editProfile, {}, dataToPost);
      print(dataToPost);
      print(data);
      setState(() async {
        LoginResponse response = LoginResponse(
          profile: UserProfile.fromJson(data['profile']),
          dietaryPreference: DietaryPreference.fromJson(
            data['dietary_preference'],
          ),
          accessToken: data['access_token'],
        );

        await StorageService.saveLoginData(response);
        _isLoading = false;
        //showToast("Profile Updated");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Signup2()),
        );
      });
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
      }
      setState(() => _isLoading = false);
    }
  }
}
