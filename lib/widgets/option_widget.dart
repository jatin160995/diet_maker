import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:flutter/material.dart';

class OptionWidget extends StatefulWidget {
  IconData iconData;
  String text;
  Function click;
  OptionWidget(this.iconData, this.text, this.click, {super.key});

  @override
  State<OptionWidget> createState() => _OptionWidgetState();
}

class _OptionWidgetState extends State<OptionWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.click();
      },
      child: Container(
        height: 60,
        margin: EdgeInsets.only(bottom: 15),
        decoration: borderRadius(white, 28),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: borderRadius(primaryColorLight, 22.5),
                  child: Center(
                    child: Icon(widget.iconData, color: primaryColor),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  widget.text,
                  style: TextStyle(
                    color: textDark(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_outlined,
              color: textLightest(),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
