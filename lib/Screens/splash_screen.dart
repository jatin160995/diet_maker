import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Screens/Auth/signup.dart';
import 'package:diet_maker/Screens/dashboard.dart';
import 'package:diet_maker/Screens/intro_screens.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/globals.dart';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startScreen() async {
    bool isLoggedIn = await StorageService.isLoggedIn();
    bool isPreferencesPending = true;
    if (isLoggedIn) {
      LoginResponse? userData = await StorageService.getLoginData();
      isPreferencesPending =
          userData?.dietaryPreference.proteinRequired == 0 ? false : true;
    }

    Future.delayed(Duration(milliseconds: 2500), () {
      if (isLoggedIn) {}
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  isLoggedIn
                      ? isPreferencesPending
                          ? Dashboard()
                          : Signup()
                      : IntroScreens(),
        ),
      );
    });
  }

  void initState() {
    super.initState();
    startScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              "assets/images/splash_back.png",
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(.2),
            ),
          ),
          Align(
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Image.asset(logo, color: textDark()),
            ),
          ),
        ],
      ),
    );
  }
}
