import 'package:diet_maker/Screens/AddMeal/MealPlan/item_detail.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';

class SingleItemDescription extends StatefulWidget {
  Map itemData;
  dynamic mealPlan;
  SingleItemDescription(this.itemData, this.mealPlan, {super.key});

  @override
  State<SingleItemDescription> createState() => _SingleItemDescriptionState();
}

class _SingleItemDescriptionState extends State<SingleItemDescription> {
  @override
  Widget build(BuildContext context) {
    var protein = widget.itemData['daily_macro_nutrient']['protein_amount'];
    var carbs = widget.itemData['daily_macro_nutrient']['carbohydrate_amount'];
    var fat = widget.itemData['daily_macro_nutrient']['fat_amount'];
    var calories = widget.itemData['daily_macro_nutrient']['calorie_amount'];
    // var protein =
    //     widget.itemData['food_serving_size']['protein'] *
    //     widget.itemData['food_amount'];
    // var carbs =
    //     widget.itemData['food_serving_size']['carbohydrate'] *
    //     widget.itemData['food_amount'];
    // var fat =
    //     widget.itemData['food_serving_size']['fat'] *
    //     widget.itemData['food_amount'];
    // var calories =
    //     widget.itemData['food_serving_size']['calorie'] *
    //     widget.itemData['food_amount'];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetail(widget.itemData, widget.mealPlan),
          ),
        );
      },
      child: Container(
        color: white,
        padding: EdgeInsets.only(left: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.itemData['food']['title'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textDark(),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Container(height: 50, width: 1, color: dividerColor),
                SizedBox(width: 10),

                Column(
                  children: [
                    Text(
                      widget.itemData['food_amount'].toString(),
                      style: TextStyle(
                        color: textDark(),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget
                          .itemData['food_serving_size']['serving_size_unit']['unit'],
                      style: TextStyle(
                        color: textLightest(),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 10),
                Container(height: 50, width: 1, color: dividerColor),
                SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      calories.toStringAsFixed(0),
                      style: TextStyle(
                        color: textDark(),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Calories",
                      style: TextStyle(
                        color: textLightest(),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              "Protein:  ${protein.toStringAsFixed(0)}g / Carbs: ${carbs.toStringAsFixed(0)}g / Fat: ${fat.toStringAsFixed(0)}g",
              style: TextStyle(
                color: textMedium(),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            Divider(height: 30, color: dividerColor),
          ],
        ),
      ),
    );
  }
}
