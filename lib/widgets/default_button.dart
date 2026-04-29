import 'package:diet_maker/utils/color_utils.dart';

import 'package:diet_maker/utils/design_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DefaultButton extends StatefulWidget {
  Function click;
  String title;
  bool isLoading;
  DefaultButton(this.title, this.click, {super.key, this.isLoading = false});

  @override
  State<DefaultButton> createState() => _DefaultButtonState();
}

class _DefaultButtonState extends State<DefaultButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.click();
      },
      child: Container(
        //width: 350,
        margin: EdgeInsets.symmetric(horizontal: 40),
        decoration: borderRadius(transparent, 25),
        height: 50,
        clipBehavior: Clip.antiAlias,
        child: Container(
          // width: 200,
          decoration: defaultGradient(),
          child: Center(
            child:
                widget.isLoading
                    ? Container(height: 30, child: SpinKitWave(color: white))
                    : Text(
                      widget.title,
                      style: TextStyle(
                        color: white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
