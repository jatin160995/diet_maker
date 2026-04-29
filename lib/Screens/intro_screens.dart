import 'package:carousel_slider/carousel_slider.dart';
import 'package:diet_maker/Screens/Auth/login.dart';
import 'package:diet_maker/utils/color_utils.dart';

import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/utils/globals.dart';
import 'package:flutter/material.dart';

class IntroScreens extends StatefulWidget {
  const IntroScreens({super.key});

  @override
  State<IntroScreens> createState() => _IntroScreensState();
}

class _IntroScreensState extends State<IntroScreens> {
  List<Widget> items = [];
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
          Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 150,
                  child: Image.asset(logo, color: textDark()),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: CarouselSlider(
                    items: getItems(),
                    options: CarouselOptions(
                      height: 500,
                      aspectRatio: 16 / 9,
                      viewportFraction: 1,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.3,
                      //onPageChanged: (t){},
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Container(
                      width: 350,
                      decoration: borderRadius(transparent, 25),
                      height: 50,
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        decoration: defaultGradient(),
                        child: Center(
                          child: Text(
                            "Sign Up",
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
                  SizedBox(height: 20),
                  Text(
                    "Already have an account",
                    style: TextStyle(color: textMedium(), fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Container(
                      height: 40,
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: textMedium(),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List text = [
    "Plan smarter.\nStay on track.\nChange everything.",
    "Set your meals in advance.\nTake Control.",
    //"Keep consistent with flexible structure and support.",
  ];
  List images = [
    "assets/images/intro1.png",
    "assets/images/intro1.png",
    // "assets/images/intro3.png",
  ];

  getItems() {
    List<Widget> items = [];
    for (int i = 0; i < text.length; i++) {
      items.add(
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                text[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textDark(),

                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(images[i], height: 300),
            ],
          ),
        ),
      );
    }

    return items;
  }
}
