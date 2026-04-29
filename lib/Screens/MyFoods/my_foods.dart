import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Screens/AddMeal/add_food.dart';
import 'package:diet_maker/Screens/MyFoods/add_food_and_serving.dart';
import 'package:diet_maker/Screens/MyFoods/add_my_food-xx.dart';
import 'package:diet_maker/Screens/MyFoods/my_food_item_detail.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';

class Myfoods extends StatefulWidget {
  const Myfoods({super.key});

  @override
  State<Myfoods> createState() => _MyfoodsState();
}

class _MyfoodsState extends State<Myfoods> {
  @override
  void initState() {
    _getMyFoods(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: heading("My Foods"),
        backgroundColor: backgroundColor(),
      ),
      body:
          _isLoading
              ? loader("Loading foods...")
              : ListView(
                padding: EdgeInsets.all(20),
                children: myFoodWidgets(),
              ),
      bottomNavigationBar: SafeArea(
        child: GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              //MaterialPageRoute(builder: (context) => AddMyFood()),
              MaterialPageRoute(builder: (context) => AddFoodWithServing()),
            );
            _getMyFoods(false);
          },
          child: Container(
            height: 50,
            color: primaryColor,
            child: Center(
              child: Text(
                "Add Food",
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> myFoodWidgets() {
    List<Widget> myFoodWidgetList = [];
    for (int i = 0; i < myFoodsFromServer.length; i++) {
      myFoodWidgetList.add(
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyFoodItemDetail(myFoodsFromServer[i]),
              ),
            );

            _getMyFoods(false);
          },
          child: Container(
            color: white,
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading(myFoodsFromServer[i]['title']),
                Column(
                  children: servingSizesWidget(
                    myFoodsFromServer[i]['food_serving_sizes'],
                  ),
                ),
                SizedBox(height: 10),
                Divider(color: dividerColor),
              ],
            ),
          ),
        ),
      );
    }
    if (myFoodWidgetList.length == 0) {
      myFoodWidgetList.add(Center(child: Text("No data available")));
    }
    return myFoodWidgetList;
  }

  List<Widget> servingSizesWidget(List servingSizes) {
    List<Widget> servingSizeWidgetList = [];
    for (int i = 0; i < servingSizes.length; i++) {
      servingSizeWidgetList.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SmallHeading(
              "Serving Size: " +
                  servingSizes[i]['serving_value'].toString() +
                  " " +
                  servingSizes[i]['serving_size_unit']['unit'],
            ),
            SmallHeading(
              "Calories: " + servingSizes[i]['calorie'].toString() + "kcal",
            ),
          ],
        ),
      );
    }
    return servingSizeWidgetList;
  }

  bool _isLoading = false;
  List myFoodsFromServer = [];
  void _getMyFoods(bool loadingState) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    try {
      setState(() {
        _isLoading = loadingState;
      });
      Map data = await apiService.getWithToken(getMyFoods, {});
      myFoodsFromServer = data['table']['data'];
      setState(() {
        _isLoading = false;
      });
      print(myFoodsFromServer);
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
      setState(() => _isLoading = false);
    }
  }
}
