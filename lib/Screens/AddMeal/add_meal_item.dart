import 'package:diet_maker/Screens/AddMeal/add_branded_food.dart';
import 'package:diet_maker/Screens/AddMeal/add_category.dart';
import 'package:diet_maker/Screens/AddMeal/add_food.dart';
import 'package:diet_maker/Screens/AddMeal/add_my_food_to_meal.dart';
import 'package:diet_maker/Screens/AddMeal/add_recipe.dart';
import 'package:diet_maker/Screens/CustomRecipes/custom_recipes_screen.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';

class AddMealItem extends StatefulWidget {
  int meal_id;
  dynamic mealPlan;
  AddMealItem(this.meal_id, this.mealPlan, {super.key});

  @override
  State<AddMealItem> createState() => _AddMealItemState();
}

class _AddMealItemState extends State<AddMealItem> {
  TextEditingController searchController = TextEditingController();

  int _selectedIndex = 0;
  List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    screens = [
      AddFood(widget.meal_id),
      AddCategory(widget.meal_id),
      AddRecipe(widget.meal_id),
      AddBrandedFood(widget.meal_id),
      AddMyFoodToMeal(widget.meal_id),
      CustomRecipesScreen(mealMealId: widget.meal_id),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: Column(
          children: [
            heading("Add Food/Recipe"),
            SmallHeading(
              "Meal Time: " + widget.mealPlan['meal_time_formatted'],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // CustomEditText(
          //   true,
          //   14,
          //   searchController,
          //   TextInputType.text,
          //   "Search Food",
          // ),
          // Container(
          //   height: 60,
          //   decoration: BoxDecoration(color: backgroundColor()),
          //   child: ListView(
          //     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     scrollDirection: Axis.horizontal,
          //     children: <Widget>[
          //       _buildNavItem('Common\nFoods', 0),
          //       _buildNavItem('Branded\nFoods', 3),
          //       _buildNavItem('My\nFoods', 4),
          //       _buildNavItem('Category', 1),
          //       _buildNavItem('Recipe', 2),
          //     ],
          //   ),
          // ),
          Stack(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(color: backgroundColor()),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  children: <Widget>[
                    SizedBox(width: 10),
                    _buildNavItem('Common\nFoods', 0),
                    _buildNavItem('Branded\nFoods', 3),
                    _buildNavItem('My\nFoods', 4),
                    _buildNavItem('Category', 1),
                    _buildNavItem('Recipes', 2),
                    _buildNavItem('My\nRecipes', 5),
                    SizedBox(width: 10),
                  ],
                ),
              ),

              // Right-side fade effect to indicate scrollable items
              Align(
                alignment: Alignment.centerRight,
                child: IgnorePointer(
                  ignoring: true, // So it doesn't block taps
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: textLightest(),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          backgroundColor(), // solid background color
                          backgroundColor().withOpacity(
                            0,
                          ), // fades to transparent
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(child: Container(child: screens[_selectedIndex])),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _selectedIndex == index ? primaryColor : Colors.grey,
                fontWeight:
                    _selectedIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
