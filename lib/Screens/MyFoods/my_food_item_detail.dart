import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Screens/MyFoods/add_serving_size.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';

class MyFoodItemDetail extends StatefulWidget {
  dynamic myfoodItem;
  MyFoodItemDetail(this.myfoodItem, {super.key});

  @override
  State<MyFoodItemDetail> createState() => _MyFoodItemDetailState();
}

class _MyFoodItemDetailState extends State<MyFoodItemDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: heading(widget.myfoodItem['title']),
        backgroundColor: backgroundColor(),
        actions: [
          IconButton(
            onPressed: () {
              showGenericDialog(
                context,
                "Delete " + widget.myfoodItem['title'] + "?",
                "Are you sure to delete this Food? ",
                "Delete",
                () async {
                  await _deleteMyFood();
                },
              );
            },
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddServingSize(widget.myfoodItem),
              ),
            );
          },
          child: Container(
            height: 50,
            color: primaryColor,
            child: Center(
              child: Text(
                "+ Add more Serving Size",
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
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          // Container(
          //   decoration: borderRadius(backgroundColor(), 10),
          //   padding: EdgeInsets.all(10),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       SmallHeading("Category"),
          //       heading(widget.myfoodItem['category']['title']),
          //       SizedBox(height: 10),
          //       SmallHeading("Subcategory"),
          //       heading(widget.myfoodItem['sub_category']['title']),
          //       SizedBox(height: 10),
          //       SmallHeading("Variety"),
          //       heading(widget.myfoodItem['variety']['name']),
          //     ],
          //   ),
          // ),
          SizedBox(height: 20),
          Column(
            children: servingSizesWidget(
              widget.myfoodItem['food_serving_sizes'],
            ),
          ), //serving sizes,
        ],
      ),
    );
  }

  List<Widget> servingSizesWidget(List servingSizes) {
    List<Widget> servingSizeWidgetList = [];
    for (int i = 0; i < servingSizes.length; i++) {
      servingSizeWidgetList.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                heading(
                  "Serving Size: " +
                      servingSizes[i]['serving_size_unit']['unit'],
                ),
                IconButton(
                  onPressed: () async {
                    showGenericDialog(
                      context,
                      "Delete ?",
                      "Are you sure to delete this serving size ? \nServing Size: " +
                          servingSizes[i]['serving_size_unit']['unit'],
                      "Delete",
                      () async {
                        await _deleteServingSize(servingSizes[i]['id'], i);
                        setState(() {
                          (widget.myfoodItem['food_serving_sizes'] as List)
                              .removeAt(i);
                        });
                      },
                    );
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            //SizedBox(height: 5),
            Text(
              "Protein: " +
                  (servingSizes[i]['protein'] *
                          servingSizes[i]['serving_value'])
                      .toStringAsFixed(2) +
                  "g / " +
                  "Carbs: " +
                  (servingSizes[i]['carbohydrate'] *
                          servingSizes[i]['serving_value'])
                      .toStringAsFixed(2) +
                  "g / " +
                  "Fat: " +
                  (servingSizes[i]['fat'] * servingSizes[i]['serving_value'])
                      .toStringAsFixed(2) +
                  "g",
              style: TextStyle(color: textMedium(), fontSize: 14),
            ),
            Text(
              (servingSizes[i]['calorie'] * servingSizes[i]['serving_value'])
                      .toStringAsFixed(2) +
                  " kcal",
              style: TextStyle(
                color: textMedium(),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(height: 30, color: dividerColor),
          ],
        ),
      );
    }
    return servingSizeWidgetList;
  }

  bool _isLoading = false;
  _deleteServingSize(int servingSizeId, int index) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });
      showLoadingDialog(context, "Deleting serving size...");

      Map data = await apiService.deleteWithToken(
        deleteMyFoodsServiceSizes(widget.myfoodItem['id'], servingSizeId),
        {},
      );
      setState(() {
        _isLoading = false;
        showToast("Serving Size Deleted Successfully");
        hideLoadingDialog(context);
        Navigator.pop(context, index);
      });
      print(data);
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
      hideLoadingDialog(context);
      setState(() => _isLoading = false);
    }
  }

  _deleteMyFood() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });
      showLoadingDialog(
        context,
        "Deleting " + widget.myfoodItem['title'] + "...",
      );

      Map data = await apiService.deleteWithToken(
        deleteMyFood + widget.myfoodItem['id'].toString(),
        {},
      );
      setState(() {
        _isLoading = false;
        showToast("Food Deleted Successfully");
        hideLoadingDialog(context);
        Navigator.pop(context);
      });
      print(data);
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
      hideLoadingDialog(context);
      setState(() => _isLoading = false);
    }
  }
}
