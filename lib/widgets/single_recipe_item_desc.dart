import 'package:diet_maker/Screens/AddMeal/MealPlan/recipe_detail.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';

class SingleRecipeItemDescription extends StatefulWidget {
  Map itemData;
  dynamic mealPlan;
  SingleRecipeItemDescription(this.itemData, this.mealPlan, {super.key});

  @override
  State<SingleRecipeItemDescription> createState() =>
      _SingleRecipeItemDescriptionState();
}

class _SingleRecipeItemDescriptionState
    extends State<SingleRecipeItemDescription> {
  @override
  Widget build(BuildContext context) {
    var protein =
        widget.itemData['recipe']['protein'] * widget.itemData['food_amount'];
    var carbs =
        widget.itemData['recipe']['carbohydrate'] *
        widget.itemData['food_amount'];
    var fat = widget.itemData['recipe']['fat'] * widget.itemData['food_amount'];
    var calories =
        widget.itemData['recipe']['calorie'] * widget.itemData['food_amount'];
    return GestureDetector(
      onTap: () {
        print(widget.itemData);
        print(widget.mealPlan);
        //return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RecipeDetail(widget.itemData, widget.mealPlan),
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
                  child: Text(
                    widget.itemData['recipe']['title'],
                    //textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textDark(),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
                    // Text(
                    //   widget
                    //       .itemData['food_serving_size']['serving_size_unit']['unit'],
                    //   style: TextStyle(
                    //     color: textLightest(),
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.normal,
                    //   ),
                    // ),
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
