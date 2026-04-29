import 'package:diet_maker/Screens/AddMeal/MealPlan/branded_food_item_detail.dart';
import 'package:diet_maker/Screens/AddMeal/MealPlan/item_detail.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';

class SingleBrandedFoodItemDescription extends StatefulWidget {
  Map itemData;
  dynamic mealPlan;
  SingleBrandedFoodItemDescription(this.itemData, this.mealPlan, {super.key});

  @override
  State<SingleBrandedFoodItemDescription> createState() =>
      _SingleBrandedFoodItemDescriptionState();
}

class _SingleBrandedFoodItemDescriptionState
    extends State<SingleBrandedFoodItemDescription> {
  @override
  Widget build(BuildContext context) {
    var proteinCalculated =
        double.parse(widget.itemData['branded_food_serving_size']['protein']) *
        widget.itemData['food_amount'].toDouble();
    var carbs =
        double.parse(
          widget.itemData['branded_food_serving_size']['carbohydrate'],
        ) *
        widget.itemData['food_amount'].toDouble();
    var fat =
        double.parse(widget.itemData['branded_food_serving_size']['fat']) *
        widget.itemData['food_amount'].toDouble();
    var calories =
        widget.itemData['branded_food_serving_size']['calorie'] == null
            ? 0
            : double.parse(
                  widget.itemData['branded_food_serving_size']['calorie'],
                ) *
                widget.itemData['food_amount'].toDouble();

    print(proteinCalculated);
    // return Container();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    BrandedFoodItemDetail(widget.itemData, widget.mealPlan),
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
                        widget.itemData['branded_food']['name'],
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
                          .itemData['branded_food_serving_size']['serving_size_unit']['unit'],
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
              "Protein:  ${proteinCalculated.toStringAsFixed(0)}g / Carbs: ${carbs.toStringAsFixed(0)}g / Fat: ${fat.toStringAsFixed(0)}g",
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
