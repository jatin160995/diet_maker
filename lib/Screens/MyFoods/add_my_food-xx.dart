import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';

class AddMyFood extends StatefulWidget {
  const AddMyFood({super.key});

  @override
  State<AddMyFood> createState() => _AddMyFoodState();
}

class _AddMyFoodState extends State<AddMyFood> {
  TextEditingController foodNameController = TextEditingController();

  // Category
  List<String> categories = [];
  int selectedCategory = 0;
  //SubCategory
  List<String> subCategories = [];
  int selectedSubCategory = 0;
  //varieties
  List<String> varieties = [];
  int selectedvarieties = 0;

  @override
  void initState() {
    _getFoodCategories();
    super.initState();
  }

  getSubCategories() {
    List<dynamic> subCat = foodsCategoriesFromServer[selectedCategory]['child'];
    subCategories = subCat.map((e) => e['title'].toString()).toList();
    print(subCategories);
    getVarieties();
  }

  getVarieties() {
    List<dynamic> varietyList =
        foodsCategoriesFromServer[selectedCategory]['child'][selectedSubCategory]['varieties'];
    varieties = varietyList.map((e) => e['name'].toString()).toList();
    print(varieties);
    //getFoodItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: GestureDetector(
          onTap: () {
            addFoodToServer();
          },
          child: Container(
            height: 50,
            color: primaryColor,
            child: Center(
              child: Text(
                "Save",
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
      appBar: AppBar(
        title: heading("Add Food"),
        backgroundColor: backgroundColor(),
      ),
      body:
          _isLoading
              ? loader("Loading data...")
              : ListView(
                padding: EdgeInsets.all(20),
                children: [
                  SizedBox(height: 20),
                  SmallHeading("Food Name"),
                  CustomEditText(
                    true,
                    16,
                    foodNameController,
                    TextInputType.text,
                    "Food Name",
                  ),

                  SmallHeading("Category"),
                  GestureDetector(
                    onTap: () {
                      showPicker(context, (int index) {
                        setState(() {
                          selectedCategory = index;
                          selectedSubCategory = 0;
                          selectedvarieties = 0;
                          getSubCategories();
                        });
                      }, categories);
                    },
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(categories[selectedCategory]),
                          Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: textLightest(),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(color: dividerColor),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  /////////////////SUB CATEGORY////////////////////
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SmallHeading("Subcategory"),
                      GestureDetector(
                        onTap: () {
                          showPicker(context, (int index) {
                            setState(() {
                              selectedSubCategory = index;
                              selectedvarieties = 0;
                              getVarieties();
                            });
                          }, subCategories);
                        },
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(subCategories[selectedSubCategory]),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: textLightest(),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            border: Border.all(color: dividerColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  /////////////////VARITY////////////////////
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SmallHeading("Varieties"),
                      GestureDetector(
                        onTap: () {
                          showPicker(context, (int index) {
                            setState(() {
                              selectedvarieties = index;
                              //getFoodItems();
                            });
                          }, varieties);
                        },
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(varieties[selectedvarieties]),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: textLightest(),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            border: Border.all(color: dividerColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  bool _isLoading = false;
  List foodsCategoriesFromServer = [];

  void _getFoodCategories() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    try {
      setState(() {
        _isLoading = true;
      });
      foodsCategoriesFromServer = await apiService.getWithToken(
        getFoodCategory,
        {},
      );
      categories =
          foodsCategoriesFromServer.map((e) => e['title'].toString()).toList();
      getSubCategories();
      setState(() {
        _isLoading = false;
      });
      print(foodsCategoriesFromServer);
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

  bool _isAddingFoodLoading = false;

  void addFoodToServer() async {
    if (foodNameController.text == "") {
      showToast("Food Name can not be empty");
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    Map<String, dynamic> dataToPost = {
      "title": foodNameController.text,
      "category_id": foodsCategoriesFromServer[selectedCategory]['id'],
      "sub_category_id":
          foodsCategoriesFromServer[selectedCategory]['child'][selectedSubCategory]['id'],
      "variety_id":
          foodsCategoriesFromServer[selectedCategory]['child'][selectedSubCategory]['varieties'][selectedvarieties]['id'],
    };

    print(dataToPost);

    ///return;
    try {
      setState(() {
        _isAddingFoodLoading = true;
      });
      showLoadingDialog(context, "Adding food...");
      Map data = await apiService.postWithToken(storeFood, dataToPost);

      setState(() async {
        showToast("Food Added");
        hideLoadingDialog(context);
        // Navigator.pop(context);
      });
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
      }
      hideLoadingDialog(context);
      setState(() => _isAddingFoodLoading = false);
    }
  }
}
