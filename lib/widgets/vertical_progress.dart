import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:flutter/material.dart';

class VerticalProgress extends StatefulWidget {
  String heading;
  Color color;
  double currentValue;
  double totalValue;
  String unit;
  VerticalProgress(
    this.heading,
    this.color,
    this.currentValue,
    this.totalValue,
    this.unit, {
    super.key,
  });

  @override
  State<VerticalProgress> createState() => _VerticalProgressState();
}

class _VerticalProgressState extends State<VerticalProgress> {
  double totalHeight = 150;
  double progress = 0;
  double extraProgress = 0;

  calculateValues() {
    setState(() {
      if (widget.currentValue == 0) {
        progress = 0;
        return;
      }
      progress = (totalHeight / widget.totalValue) * widget.currentValue;
      if (progress > totalHeight) {
        progress = (totalHeight / widget.currentValue) * widget.totalValue;
        extraProgress = totalHeight - progress;
      }
    });
  }

  @override
  void initState() {
    calculateValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.heading,
          style: TextStyle(color: textMedium(), fontSize: 13),
        ),
        SizedBox(height: 10),
        Container(
          width: 40,
          height: totalHeight,
          decoration: borderRadius(dividerColor, 20),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Container(
                width: 40,
                height: totalHeight,
                decoration: borderRadius(dividerColor, 20),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  //decoration: borderRadius(widget.color, 10),
                  color: widget.color,
                  height: progress,
                ),
                // color: , height: 75),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(color: one, height: extraProgress),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: widget.currentValue.toStringAsFixed(0),
            style: TextStyle(
              color: textDark(),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            children: <TextSpan>[
              TextSpan(
                text:
                    "\n/" + widget.totalValue.toStringAsFixed(0) + widget.unit,
                style: TextStyle(
                  color: textMedium(),
                  fontSize: 11.5,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
