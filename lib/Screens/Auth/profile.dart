import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Screens/Auth/LegalPages/legal_page_webview.dart';
import 'package:diet_maker/Screens/Auth/change_password.dart';
import 'package:diet_maker/Screens/Auth/delete_account.dart';
import 'package:diet_maker/Screens/Auth/edit_profile.dart';
import 'package:diet_maker/Screens/Auth/faq.dart';
import 'package:diet_maker/Screens/Auth/login.dart';
import 'package:diet_maker/Screens/Auth/notification_preferences.dart';
import 'package:diet_maker/Screens/Auth/terms.dart';
import 'package:diet_maker/Screens/Auth/upload_profile_photo.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';

import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/loading_image.dart';
import 'package:diet_maker/widgets/option_widget.dart';
import 'package:diet_maker/widgets/safe_image_loader.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late LoginResponse userDetail;
  bool isLoading = true;

  late String weight;
  late String height;

  getDetails() async {
    userDetail = (await StorageService.getLoginData())!;

    weight =
        (await getUserWeight(
          userDetail.profile.preferredMeasurement,
        )).toString();
    height =
        (await getUserHeight(
          userDetail.profile.preferredMeasurement,
        )).toString();
    print(height);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    print(userDetail.profile.photoUrl + "-----");
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("My Profile"),
      ),
      body:
          isLoading
              ? Center(child: SpinKitWave(color: primaryColor))
              : ListView(
                children: [
                  SizedBox(height: 40),
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
                                  width: 150,
                                  height: 150,
                                  decoration: borderRadius(white, 75),
                                  clipBehavior: Clip.antiAlias,
                                  child: SafeNetworkImage(
                                    imageUrl: userDetail.profile.photoUrl,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                      ),
                      SizedBox(height: 20),
                      headingBig(userDetail.profile.fullName),
                      Text(
                        "User ID: " + userDetail.profile.code,
                        style: TextStyle(color: textMedium(), fontSize: 15),
                      ),
                      SizedBox(height: 30),
                      Container(
                        height: 70,
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: borderRadius(white, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Weight",
                                  style: TextStyle(
                                    color: textLightest(),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  weight,
                                  style: TextStyle(
                                    color: textDark(),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.keyboard_double_arrow_right_rounded,
                              color: primaryColor,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Age",
                                  style: TextStyle(
                                    color: textLightest(),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  userDetail.profile.age.toString() + "y",
                                  style: TextStyle(
                                    color: textDark(),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.keyboard_double_arrow_right_rounded,
                              color: primaryColor,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Height ",
                                  style: TextStyle(
                                    color: textLightest(),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  height,
                                  style: TextStyle(
                                    color: textDark(),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heading("My Account"),
                        SizedBox(height: 20),
                        OptionWidget(
                          Icons.mode_edit_outlined,
                          "Edit Profile",
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfile(),
                              ),
                            );
                            getDetails();
                          },
                        ),
                        OptionWidget(
                          Icons.password_rounded,
                          "Change Password",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePassword(),
                              ),
                            );
                          },
                        ),
                        OptionWidget(
                          Icons.notifications_active_outlined,
                          "Notification Preferences",
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => NotifficationPreferences(),
                              ),
                            );
                            getDetails();
                          },
                        ),
                        // OptionWidget(Icons.support_agent, "Support", () {}),
                        OptionWidget(Icons.logout_rounded, "Logout", () {
                          showGenericDialog(
                            context,
                            "Logout",
                            "Are you sure, you want to logout ?",
                            "Logout",

                            () {
                              logoutUser();
                              // _logoutRequest();
                            },
                          );
                        }),
                        OptionWidget(
                          Icons.delete_outlined,
                          "Deactivate Account",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeleteAccount(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        heading("About Diet Maker"),
                        SizedBox(height: 20),
                        OptionWidget(
                          Icons.note_alt_outlined,
                          "Terms & Conditions",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                    // Terms("Terms of Service"),
                                    WebViewScreen(
                                      title: "Terms & Conditions",
                                      link: tnc,
                                    ),
                              ),
                            );
                          },
                        ),
                        OptionWidget(
                          Icons.privacy_tip_outlined,
                          "Privacy Policy",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => WebViewScreen(
                                      title: "Privacy Policy",
                                      link: privacyPolicy,
                                    ), //Terms("Privacy Policy"),
                              ),
                            );
                          },
                        ),
                        OptionWidget(
                          Icons.warning_amber_rounded,
                          "Disclaimer",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => WebViewScreen(
                                      title: "Disclaimer",
                                      link: disclaimer,
                                    ), // Terms("Disclaimer"),
                              ),
                            );
                          },
                        ),
                        // OptionWidget(Icons.format_quote_outlined, "FAQ", () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(builder: (context) => AllFaqs()),
                        //   );
                        // }),
                      ],
                    ),
                  ),
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

  void _logoutRequest() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });
      showLoadingDialog(context, "Logging out...");
      Map data = await apiService.getWithToken(logout, {});
      logoutUser();
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
