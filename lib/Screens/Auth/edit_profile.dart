import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Models/user_profile.dart';
import 'package:diet_maker/Screens/Auth/upload_profile_photo.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/utils/globals.dart';
import 'package:diet_maker/widgets/app_popups.dart';

import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:diet_maker/widgets/safe_image_loader.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController fNameController = new TextEditingController();
  TextEditingController lNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController measurementController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController activityController = TextEditingController();
  TextEditingController mealsController = TextEditingController();
  TextEditingController ageController = new TextEditingController();
  TextEditingController dietTitleController = new TextEditingController();
  List<String> measurements = ["Imperial", "Metric"];
  List<String> activityLevels = [
    "Sedentary",
    "Lightly Active",
    "Moderately Active",
    "Very Active",
    "Extreme Activity",
  ];
  Map activityLevelValues = {
    "Sedentary": "1.2",
    "Lightly Active": "1.375",
    "Moderately Active": "1.55",
    "Very Active": "1.7",
    "Extreme Activity": "1.9",
  };
  List<String> meals = ["1", "2", "3", "4", "5", "6"];

  late LoginResponse userDetail;
  bool isLoading = true;
  String selectedDate = "";
  String savedDate = "";

  getDetails() async {
    userDetail = (await StorageService.getLoginData())!;
    //print(userDetail.profile.dob.toString() + "------------");
    savedDate = userDetail.profile.dob;
    fNameController = TextEditingController(text: userDetail.profile.firstName);
    lNameController = TextEditingController(text: userDetail.profile.lastName);
    emailController = TextEditingController(text: userDetail.profile.email);
    ageController = TextEditingController(
      text: userDetail.profile.age.toString(),
    );
    measurementController = TextEditingController(
      text: userDetail.profile.preferredMeasurement,
    );
    dietTitleController = TextEditingController(
      text: userDetail.dietaryPreference.title,
    );
    mealsController = TextEditingController(
      text: userDetail.dietaryPreference.noOfMeals.toString(),
    );
    activityController = TextEditingController(
      text: userDetail.dietaryPreference.activityLevelTitle.toString(),
    );
    selectedDate = userDetail.profile.dob.toString();

    await getVariableValues();
    setState(() {
      isLoading = false;
    });
  }

  getVariableValues() async {
    userDetail = (await StorageService.getLoginData())!;
    heightController = TextEditingController(
      text: await getUserHeight(measurementController.text),
    );
    weightController = TextEditingController(
      text: await getUserWeight(measurementController.text),
    );
  }

  @override
  void initState() {
    ageController.text = "Age";
    measurementController.text = "Preferred Measurement";
    heightController.text = "Height";
    weightController.text = "Weight";
    //activityController.text = "Current Activity Level";
    mealsController.text = "0";
    getDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("Edit Profile"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UploadPhotoScreen(),
                    ),
                  );
                  getDetails();
                },
                child:
                    userDetail.profile.photoUrl == ""
                        ? Image.asset(
                          "assets/images/user_demo.png",
                          height: 100,
                        )
                        : Container(
                          decoration: borderRadius(white, 75),
                          clipBehavior: Clip.antiAlias,
                          width: 150,
                          height: 150,
                          child: SafeNetworkImage(
                            imageUrl: userDetail.profile.photoUrl,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
            ],
          ),
          SizedBox(height: 10),
          SmallHeading("First Name"),

          CustomEditText(
            true,
            15,
            fNameController,
            TextInputType.text,
            "First Name",
          ),
          SizedBox(height: 10),
          SmallHeading("Last Name"),
          CustomEditText(
            true,
            15,
            lNameController,
            TextInputType.text,
            "Last Name",
          ),
          SizedBox(height: 10),
          SmallHeading("Email"),

          CustomEditText(
            true,
            15,
            emailController,
            TextInputType.text,
            "Email",
          ),

          SizedBox(height: 10),
          SmallHeading("Age"),
          GestureDetector(
            onTap: () {
              selectDate(context, (d) {
                setState(() {
                  //print(d.toString());
                  selectedDate = readableDate(d);
                  ageController.text = calculateAge(d).toString();
                });
              }, initialDateString: savedDate);
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
          SizedBox(height: 30),

          DefaultButton("Update Profile", () {
            _editUser();
          }, isLoading: _isLoading),
          SizedBox(height: 30),
          headingBig("Personal Setup"),
          // SizedBox(height: 10),

          // SmallHeading("Diet Title"),

          // CustomEditText(
          //   true,
          //   15,
          //   dietTitleController,
          //   TextInputType.text,
          //   "Diet Title",
          // ),
          SizedBox(height: 10),
          SmallHeading("Preferred Measurement"),
          GestureDetector(
            onTap: () {
              showPicker(context, (int index) {
                setState(() {
                  measurementController.text = measurements[index];
                  getVariableValues();
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
          SizedBox(height: 10),
          SmallHeading(
            "Height (" +
                (measurementController.text == measurements[1]
                    ? "cm)"
                    : "Feet/Inch)"),
          ),
          GestureDetector(
            onTap: () {
              showDecimalPicker(
                context,
                (value) {
                  setState(() {
                    heightController.text = value;
                    // print("Selected height: $value");
                  });
                },
                measurementController.text == measurements[1] ? 100 : 0,
                measurementController.text == measurements[1] ? 121 : 10,
                measurementController.text == measurements[1] ? 10 : 12,
              );
            },
            child: Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(heightController.text),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallHeading("Current Activity Level"),
              IconButton(
                onPressed: () {
                  showActivityLevelInfoDialog();
                },
                icon: Icon(Icons.info, color: textMedium()),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              showPicker(context, (int index) {
                setState(() {
                  activityController.text = activityLevels[index];
                });
              }, activityLevels);
            },
            child: Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(activityController.text),
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
          SmallHeading(
            "Weight (" +
                (measurementController.text == measurements[1]
                    ? "kg)"
                    : "lbs)"),
          ),
          GestureDetector(
            onTap: () {
              showDecimalPicker(
                context,
                (value) {
                  setState(() {
                    weightController.text = value;
                    // print("Selected height: $value");
                  });
                },
                measurementController.text == measurements[1] ? 45 : 100,
                measurementController.text == measurements[1] ? 91 : 200,
                measurementController.text == measurements[1] ? 10 : 10,
              );
            },
            child: Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(weightController.text),
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

          // SmallHeading("Number of meals"),
          // GestureDetector(
          //   onTap: () {
          //     showPicker(context, (int index) {
          //       setState(() {
          //         mealsController.text = meals[index];
          //       });
          //     }, meals);
          //   },
          //   child: Container(
          //     height: 60,
          //     padding: EdgeInsets.symmetric(horizontal: 15),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(mealsController.text),
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
          DefaultButton("Update Setup", () {
            _editPreferences();
          }, isLoading: _isLoadingDietary),
        ],
      ),
    );
  }

  showActivityLevelInfoDialog() {
    infoDialog(
      context,
      "Activity Level Info",
      Column(
        children: [
          //Level 1---------------------
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                child: Image.asset(imagesPath + "activity1.png"),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Sedentary"),
                    SmallHeading(
                      "Little or no exercise; mostly sitting or desk work.",
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: dividerColor, height: 20),
          //Level 2---------------------
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                child: Image.asset(imagesPath + "activity2.png"),
              ),

              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Light Active"),
                    SmallHeading("Light exercise/sports 1-3 days/week."),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: dividerColor, height: 20),
          //Level 3---------------------
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                child: Image.asset(imagesPath + "activity3.png"),
              ),

              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Moderately Active"),
                    SmallHeading("Moderate exercise/sports 3-5 days/week."),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: dividerColor, height: 20),
          //Level 4---------------------
          Row(
            children: [
              Container(
                width: 80,
                child: Image.asset(imagesPath + "activity4.png"),
                height: 80,
              ),

              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Very Active"),
                    SmallHeading(
                      "Hard exercise/sports 6-7 days/week or a physical job.",
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: dividerColor, height: 20),
          //Level 5---------------------
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                child: Image.asset(imagesPath + "activity5.png"),
              ),

              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Extremely Active"),
                    SmallHeading(
                      "Very hard daily training and physically demanding work",
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: dividerColor, height: 20),
        ],
      ),
    );
  }

  bool _isLoading = false;

  _editUser() async {
    if (fNameController.text == "" || lNameController.text == "") {
      showToast("First Name and Last name can not be empty");
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    Map<String, dynamic> dataToPost = {
      "first_name": fNameController.text,
      "last_name": lNameController.text,
      "email": emailController.text,
      "dob": selectedDate,
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

    print(dataToPost);
    //return;
    try {
      setState(() {
        _isLoading = true;
      });
      // showLoadingDialog(context, "Updating...");
      Map data = await apiService.putRequest(editProfile, {}, dataToPost);

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
        // hideLoadingDialog(context);
        // _editPreferences();
        showToast("Profile Updated");
      });
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
      }
      // hideLoadingDialog(context);
      setState(() => _isLoading = false);
    }
  }

  bool _isLoadingDietary = false;
  _editPreferences() async {
    // if (dietTitleController.text == "") {
    //   showToast("Diet title can not be empty");
    //   return;
    // }

    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    Map<String, dynamic> dataToPost = {
      //"title": dietTitleController.text,
      "preferred_measurement": measurementController.text,
      "no_of_meals": mealsController.text,
      "activity_level": activityLevelValues[activityController.text],
    };
    if (measurementController.text.toLowerCase() == "imperial") {
      //dataToPost["height_feet"] = ;

      var parts = [];
      if (heightController.text.contains("\"")) {
        parts = heightController.text
            .replaceAll("\"", "")
            .replaceAll("'", "")
            .split(" ");
      } else {
        parts = heightController.text.split(".");
      }

      dataToPost["height_in"] =
          (int.parse(parts[0]) * 12) +
          int.parse(parts[1]); //parts.length > 1 ? parts[1] : "0";
      dataToPost["weight_lbs"] = weightController.text;
    } else {
      dataToPost["height_cm"] = heightController.text;
      dataToPost["weight_kg"] = weightController.text;
    }

    // print(dataToPost);
    //return;
    setState(() {
      _isLoadingDietary = true;
    });
    await _editUser();
    try {
      Map data = await apiService.putRequest(
        editDietaryPreferences + userDetail.dietaryPreference.id.toString(),
        {},
        dataToPost,
      );

      setState(() async {
        LoginResponse response = LoginResponse(
          profile: UserProfile.fromJson(data['profile']),
          dietaryPreference: DietaryPreference.fromJson(
            data['dietary_preference'],
          ),
          accessToken: userDetail.accessToken,
        );

        await StorageService.saveLoginData(response);
        _isLoadingDietary = false;

        showToast("Dietary Preferences Updated");
        _editCaloriesToMaintain();
      });
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
      }
      setState(() => _isLoadingDietary = false);
    }
  }

  void _editCaloriesToMaintain() async {
    userDetail = (await StorageService.getLoginData())!;
    final calories = calculateCaloriesToMaintainWeight(
      preferredMeasurement: userDetail!.profile.preferredMeasurement,
      weightKg: userDetail.dietaryPreference.weightKg.toDouble(),
      weightLbs: userDetail.dietaryPreference.weightLbs.toDouble(),
      heightCm: userDetail.dietaryPreference.heightCm.toDouble(),
      heightIn: userDetail.dietaryPreference.heightIn.toDouble(),
      age: userDetail.dietaryPreference.age,
      gender: userDetail.profile.gender,
      activityLevel: userDetail.dietaryPreference.activityLevel,
    );

    final ApiService apiService = ApiService();

    Map<String, dynamic> dataToPost = {
      "avg_calorie_to_maintain_weight": calories,
    };
    //print(dataToPost);
    //return;
    try {
      setState(() {
        _isLoading = true;
      });
      Map data = await apiService.putRequest(
        editDietaryPreferences + userDetail.dietaryPreference.id.toString(),
        {},
        dataToPost,
      );

      setState(() async {
        LoginResponse response = LoginResponse(
          profile: UserProfile.fromJson(data['profile']),
          dietaryPreference: DietaryPreference.fromJson(
            data['dietary_preference'],
          ),
          accessToken: userDetail.accessToken,
        );

        await StorageService.saveLoginData(response);
        _isLoading = false;
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

  int calculateCaloriesToMaintainWeight({
    required String preferredMeasurement,
    required double weightKg,
    required double weightLbs,
    required double heightCm,
    required double heightIn,
    required int age,
    required String gender,
    required double activityLevel,
  }) {
    double bmr = 0;
    //print(activityLevel);
    if (preferredMeasurement.toLowerCase() == "imperial") {
      //imperials Formula
      if (gender.toLowerCase() == "male") {
        bmr = (4.536 * weightLbs) + (15.88 * heightIn) - (5 * age) + 5;
      } else {
        bmr = (4.536 * weightLbs) + (15.88 * heightIn) - (5 * age) - 161;
      }
    } else {
      // Metric Formula
      if (gender.toLowerCase() == "male") {
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
      } else {
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
      }
    }

    return (bmr * activityLevel).toInt();
  }
}
