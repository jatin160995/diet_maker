import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

defaultGradient() {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [secondryColor, primaryColor],
    ),
  );
}

borderRadius(Color backgroundColor, double radius) {
  return BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

Widget smallHeading(String title) {
  return Container(
    //margin: EdgeInsets.all(15),
    child: Text(
      title,
      style: TextStyle(
        color: textDark(),
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}

Widget heading(String title) {
  return Container(
    //margin: EdgeInsets.all(15),
    child: Text(
      title,
      style: TextStyle(
        color: textDark(),
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget headingSmall(String title) {
  return Container(
    //margin: EdgeInsets.all(15),
    child: Text(
      title,
      style: TextStyle(
        color: textDark(),
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget headingBig(String title) {
  return Container(
    child: Text(
      title,
      style: TextStyle(
        color: textDark(),
        fontSize: 23,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget loader(String message) {
  return Center(
    child: Container(
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(child: SpinKitWave(color: primaryColor)),
          Text(message),
        ],
      ),
    ),
  );
}

nutritionBreakDownWidget(String title, String value) {
  return Container(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: textDark(), fontSize: 15)),
            Text(
              value,
              style: TextStyle(
                color: textDark(),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Divider(height: 15, color: dividerColor),
      ],
    ),
  );
}
