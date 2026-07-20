import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Models/user_profile.dart';
import 'package:diet_maker/Screens/Auth/forgot_password.dart';
import 'package:diet_maker/Screens/Auth/signup.dart';
import 'package:diet_maker/Screens/dashboard.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';

import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/utils/globals.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool _isLoading = false;

  bool isAgreeChecked = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create a new credential with the token
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign the user into Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      showToast("Google Sign-In Error: $e");
      // Handle specific errors (e.g., network issues)
      return null;
    }
  }

  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? 'unknown_android';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    } else {
      return 'unsupported_platform';
    }
  }

  void _loginUser() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    final String? fcmToken = await StorageService.getFcmToken();
    Map<String, dynamic> dataToPost = {
      "email": emailController.text,
      "password": passwordController.text,
      "timezone": currentTimeZone,
      "device": {
        "device_id": await getDeviceId(),
        "firebase_id": fcmToken,
        "device_type": Platform.isIOS ? "iOS" : "Android",
        "category": "mobile",
      },
    };
    try {
      setState(() {
        _isLoading = true;
      });
      Map data = await apiService.post(login, dataToPost);

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

        response.dietaryPreference.proteinRequired == 0
            ? Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Signup()),
            )
            : Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
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

  void _loginUserWithSocial(
    String email,
    String firstName,
    String lastName,
    String providerId,
    String provider,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    final String? fcmToken = await StorageService.getFcmToken();
    Map<String, dynamic> dataToPost = {
      "email": email,
      "first_name": firstName,
      "last_name": lastName,
      "provider_id": providerId,
      "provider": provider, // Facebook, Google, Apple
      "timezone": currentTimeZone,
      "device": {
        "device_id": await getDeviceId(),
        "firebase_id": fcmToken,
        "device_type": Platform.isIOS ? "iOS" : "Android",
        "category": "mobile",
      },
    };
    try {
      setState(() {
        _isLoading = true;
      });
      Map data = await apiService.post(login, dataToPost);
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

        response.dietaryPreference.proteinRequired == 0
            ? Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Signup()),
            )
            : Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
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

  @override
  void initState() {
    // if (Platform.isAndroid) {
    //   _googleSignIn = GoogleSignIn(
    //     serverClientId:
    //         '458505580414-itcrc68seih3io7gf5ct4k9r91aor5ff.apps.googleusercontent.com', // Web Client ID
    //   );
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        child: ListView(
          children: [
            SizedBox(height: 70),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Logo
                Container(
                  width: MediaQuery.of(context).size.width - 150,
                  child: Image.asset(logo, color: textDark()),
                ),
                //Heading
                SizedBox(height: 45),
                headingBig("Eat With Purpose"),
                Text("Log in to manage your meals and reach your goals."),
                SizedBox(height: 45),
                //Social Login
                GestureDetector(
                  onTap: () async {
                    User? user = await signInWithGoogle();

                    if (user != null) {
                      //showToast(user.displayName.toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Welcome, ${user.email}!')),
                      );
                      List name = user.displayName.toString().split(" ");
                      _loginUserWithSocial(
                        user.email!,
                        name.length > 0 ? name[0] : "",
                        name.length > 1 ? name[1] : "",
                        user.uid!,
                        "Google",
                      );
                    } else {
                      showToast("Something went wrong");
                    }
                  },
                  child: Container(
                    decoration: borderRadius(white, 10),
                    height: 45,
                    width: 350,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/google.png", height: 30),
                        heading("    Log in with Google"),
                      ],
                    ),
                  ),
                ),
                // SizedBox(height: 15),
                // Container(
                //   decoration: borderRadius(white, 10),
                //   height: 45,
                //   width: 350,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Image.asset("assets/images/fb.png", height: 30),
                //       heading("    Log in with Facebook"),
                //     ],
                //   ),
                // ),
                //Or Section
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 100, height: 1, color: darkLightText),
                    Text(
                      "    OR   ",
                      style: TextStyle(color: textMedium(), fontSize: 16),
                    ),
                    Container(width: 100, height: 1, color: darkLightText),
                  ],
                ),
                //Login Section
                SizedBox(height: 25),
                CustomEditText(
                  true,
                  14,
                  emailController,
                  TextInputType.text,
                  "Email",
                  width: 350,
                ),
                SizedBox(height: 10),
                CustomEditText(
                  true,
                  14,
                  passwordController,
                  TextInputType.text,
                  "Password",
                  width: 350,
                  isPassword: true,
                ),
                //Forgot Password
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                    );
                  },
                  child: Container(
                    width: 350,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: textMedium(),
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //tnc
                SizedBox(height: 10),
                Container(
                  width: 350,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isAgreeChecked = !isAgreeChecked;
                          });
                        },
                        child: Icon(
                          isAgreeChecked
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isAgreeChecked ? primaryColor : textMedium(),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          style: TextStyle(fontSize: 13),
                          TextSpan(
                            text: "By signing in I agree to the",
                            children: <InlineSpan>[
                              TextSpan(
                                text: " Terms and Conditions, Privacy Policy",
                                style: TextStyle(
                                  color: primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: " and "),
                              TextSpan(
                                text: "Disclaimer",
                                style: TextStyle(
                                  color: primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (!isAgreeChecked) {
                      dismissKeyboard(context);
                      showToast(
                        "Please agree to the Terms & Conditions and Privacy Policy before logging in.",
                      );
                      return;
                    }
                    if (emailController.text == "" ||
                        passwordController == "") {
                      showToast("Please fill Email and Password.");
                      return;
                    }
                    _loginUser();
                  },
                  child: Container(
                    width: 350,
                    decoration: borderRadius(transparent, 25),
                    height: 50,
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: defaultGradient(),
                      child: Center(
                        child:
                            _isLoading
                                ? Container(
                                  height: 30,
                                  child: SpinKitWave(color: white),
                                )
                                : Text(
                                  "Get Started",
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
