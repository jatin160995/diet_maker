import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class SmallHeading extends StatelessWidget {
  String heading;
  SmallHeading(this.heading, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Text(heading, style: TextStyle(color: textMedium(), fontSize: 12)),
    );
  }
}
