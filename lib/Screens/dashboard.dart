import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/dietary_preference.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/Models/user_profile.dart';
import 'package:diet_maker/Screens/AddMeal/add_meal_item.dart';
import 'package:diet_maker/Screens/Auth/profile.dart';
import 'package:diet_maker/Screens/Calendar/my_calendar.dart';
import 'package:diet_maker/Screens/CustomRecipes/custom_recipes_screen.dart';
import 'package:diet_maker/Screens/HomeTilesScreens/coaching.dart';
import 'package:diet_maker/Screens/HomeTilesScreens/recipes.dart';
import 'package:diet_maker/Screens/HomeTilesScreens/resources.dart';
import 'package:diet_maker/Screens/MyFoods/add_food_and_serving.dart';
import 'package:diet_maker/Screens/MyFoods/my_foods.dart';
import 'package:diet_maker/Screens/MyProgress/my_progress.dart';
import 'package:diet_maker/Screens/chatbot.dart';
import 'package:diet_maker/Screens/my_meal_plan.dart';
import 'package:diet_maker/Screens/my_meal_plan_calculator.dart';
import 'package:diet_maker/Screens/nutrition_target.dart';
import 'package:diet_maker/main.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';

import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/utils/globals.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/option_widget.dart';
import 'package:diet_maker/widgets/safe_image_loader.dart';
import 'package:diet_maker/widgets/single_branded_food_item_desc.dart';
import 'package:diet_maker/widgets/single_item_desc.dart';
import 'package:diet_maker/widgets/single_recipe_item_desc.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with RouteAware {
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);
  double totalCalories = 2100;
  double progress = 49;

  late LoginResponse userDetail;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  getUserDetails() async {
    userDetail = (await StorageService.getLoginData())!;
    //_getMealPlansRequest();
    _getSchedulesRequest();
    _getAdherenceData();
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Future<void> didPopNext() async {
    // 👇 This runs when you return to this screen
    debugPrint("Returned");
    await _editUser();
    getUserDetails();
  }

  bottomBarWidget() {
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: white,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, color: primaryColor),
                      Text("Home", style: TextStyle(color: primaryColor)),
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Profile()),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings, color: textLightest()),
                        Text(
                          "Settings",
                          style: TextStyle(color: textLightest()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withValues(alpha: 0.35),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatBotScreen(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: borderRadius(primaryColor, 33),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble, color: white),
                        Text(
                          "AI Help",
                          style: TextStyle(color: white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: backgroundColor(),
        title: Container(
          //height: 80,
          margin: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyCalendar()),
                  );
                },
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  margin: EdgeInsets.only(top: 10),
                  decoration: borderRadius(white, 25),
                  child: Row(
                    children: [
                      // Container(
                      //   height: 30,
                      //   width: 30,
                      //   decoration: borderRadius(primaryColor, 15),
                      //   child: Icon(Icons.calendar_month, color: white, size: 20),
                      // ),
                      //SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heading(
                            DateFormat("dd MMM").format(
                              DateFormat(
                                "yyyy-MM-dd hh:mm:ss",
                              ).parse(DateTime.now().toString()),
                            ),
                          ),
                          Text(
                            DateFormat("EEEE").format(
                              DateFormat(
                                "yyyy-MM-dd hh:mm:ss",
                              ).parse(DateTime.now().toString()),
                            ),
                            style: TextStyle(
                              color: textLightest(),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Profile()),
                  );
                },
                child: Container(
                  height: 40,
                  width: 40,
                  child:
                      userDetail.profile.photoUrl == ""
                          ? Image.asset(
                            "assets/images/user_demo.png",
                            height: 40,
                          )
                          : Container(
                            width: 40,
                            height: 40,
                            decoration: borderRadius(white, 75),
                            clipBehavior: Clip.antiAlias,
                            child: SafeNetworkImage(
                              imageUrl: userDetail.profile.photoUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Container(
              margin: EdgeInsets.only(bottom: 50),
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        heading("Meal Plan"),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            todayMealPlanId == 0
                                                ? MyMealPlanCalculator()
                                                : MyMealPlanCalculator(
                                                  mealPlanId: todayMealPlanId,
                                                ),
                                  ),
                                );
                              },
                              child: Text(
                                "Manage",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MyCalendar(tabIndex: 1),
                                  ),
                                );
                              },
                              child: Text(
                                "Schedule",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  mealPlanWidgets().length > 0 && scheduleToday
                      ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Column(children: mealPlanWidgets()),
                      )
                      : Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "No Scheduled Meal Plan for today",
                          style: TextStyle(color: textLightest()),
                        ),
                      ),
                  //calenderWidget(),
                  optionGrid(),
                  setupOptions(),
                ],
              ),
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: bottomBarWidget()),
        ],
      ),
    );
  }

  optionGrid() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading("Shortcuts"),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Coaching()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: borderRadius(white, 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              child: Image.asset(imagesPath + "coach.png"),
                            ),
                            SizedBox(width: 10),
                            headingSmall("Coaching\nPlans"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Recipes()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: borderRadius(white, 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              child: Image.asset(imagesPath + "recipes.png"),
                            ),
                            SizedBox(width: 10),
                            headingSmall("Recipes"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyProgress()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: borderRadius(white, 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              child: Image.asset(imagesPath + "progress.png"),
                            ),
                            SizedBox(width: 10),
                            headingSmall("Progress"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResourcesScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: borderRadius(white, 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(3),
                              child: Image.asset(
                                imagesPath + "resources-1.png",
                              ),
                            ),
                            SizedBox(width: 10),
                            headingSmall("Resources"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  calenderWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                heading("Today"),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          print(selectedDay);
                          if (selectedDay != 0) {
                            selectedDay = --selectedDay;
                          }
                        });
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: borderRadius(white, 15),
                        child: Icon(
                          Icons.keyboard_arrow_left_rounded,
                          color: textDark(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          print(selectedDay);
                          if (selectedDay != 6) {
                            selectedDay = ++selectedDay;
                          }
                        });
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: borderRadius(white, 15),
                        child: Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: textDark(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: getDateWidgets(),
            ),
          ),

          Container(
            margin: EdgeInsets.only(left: 20, top: 20),
            child: heading("Calories"),
          ),

          Container(
            //color: white,
            //height: 500,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: macroNutrients(),
                ),

                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: 310,
                    margin: EdgeInsets.only(left: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "1050",
                          style: TextStyle(
                            color: textDark(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Remaining",
                          style: TextStyle(
                            color: textLightest(),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: 310,
                    margin: EdgeInsets.only(right: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "2100",
                          style: TextStyle(
                            color: textDark(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Target",
                          style: TextStyle(
                            color: textLightest(),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(30),
                  child: DashedCircularProgressBar.aspectRatio(
                    aspectRatio: 1, // width ÷ height
                    valueNotifier: _valueNotifier,
                    progress: progress,
                    startAngle: 260,
                    sweepAngle: 200,
                    foregroundColor: primaryColor,
                    backgroundColor: const Color(0xffcccccc),
                    foregroundStrokeWidth: 40,
                    backgroundStrokeWidth: 40,
                    animation: true,
                    seekSize: 8,
                    seekColor: const Color(0xffeeeeee),
                    child: Center(
                      child: ValueListenableBuilder(
                        valueListenable: _valueNotifier,
                        builder:
                            (_, double value, __) => Column(
                              //mainAxisSize: MainAxisSize.min,
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 90),
                                Text(
                                  '${(value * (totalCalories / 100)).toInt()}',
                                  style: TextStyle(
                                    color: textDark(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 50,
                                  ),
                                ),
                                Text(
                                  'Consumed',
                                  style: TextStyle(
                                    color: textMedium(),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  setupOptions() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading("Plan & Track"),
          SizedBox(height: 20),
          Column(
            children: [
              OptionWidget(Icons.person_2_outlined, "My Profile", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              }),
              OptionWidget(
                Icons.data_saver_on_outlined,
                "My Nutrition Targets",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyNutritionTarget(),
                    ),
                  );
                },
              ),
              OptionWidget(
                Icons.calculate_outlined,
                "My Meal Plan Calculator",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyMealPlanCalculator(),
                    ),
                  );
                },
              ),
              OptionWidget(Icons.calendar_month_outlined, "My Calendar", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyCalendar()),
                );
              }),
              OptionWidget(Icons.food_bank_outlined, "My Foods", () {
                Navigator.push(
                  context,
                  //MaterialPageRoute(builder: (context) => Myfoods()),
                  MaterialPageRoute(builder: (context) => Myfoods()),
                );
              }),
              OptionWidget(Icons.book_outlined, 'My Custom Recipes', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomRecipesScreen(),
                  ),
                );
              }),
              OptionWidget(
                Icons.stacked_line_chart_outlined,
                "My Progress",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyProgress()),
                  );
                },
              ),
              OptionWidget(Icons.edit_note_sharp, "My Meal Plans", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyMealPlan()),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  macroNutrients() {
    return Container(
      decoration: borderRadius(white, 10),
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(top: 340, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Protein", style: TextStyle(color: textLightest())),
              SizedBox(height: 5),
              Container(
                width: (MediaQuery.of(context).size.width - 100) / 3,
                height: 5,
                decoration: borderRadius(dividerColor, 3),
                child: Stack(
                  children: [
                    Container(
                      decoration: borderRadius(protien, 3),
                      height: 5,
                      width: 60,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                "44/78g",
                style: TextStyle(
                  color: textDark(),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Carbs", style: TextStyle(color: textLightest())),
              SizedBox(height: 5),
              Container(
                width: (MediaQuery.of(context).size.width - 100) / 3,
                height: 5,
                decoration: borderRadius(dividerColor, 3),
                child: Stack(
                  children: [
                    Container(
                      decoration: borderRadius(carbs, 3),
                      height: 5,
                      width: 60,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                "44/78g",
                style: TextStyle(
                  color: textDark(),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Fat", style: TextStyle(color: textLightest())),
              SizedBox(height: 5),
              Container(
                width: (MediaQuery.of(context).size.width - 100) / 3,
                height: 5,
                decoration: borderRadius(dividerColor, 3),
                child: Stack(
                  children: [
                    Container(
                      decoration: borderRadius(fats, 3),
                      height: 5,
                      width: 60,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                "44/78g",
                style: TextStyle(
                  color: textDark(),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int selectedDay = 0;

  getDateWidgets() {
    DateTime today = new DateTime.now();
    List<Widget> dates = [];
    List weekdays = ["", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    for (int i = 0; i < 7; i++) {
      dates.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDay = i;
            });
          },
          child: Container(
            margin: EdgeInsets.only(left: i == 0 ? 20 : 0, right: 10),
            decoration: BoxDecoration(
              color: selectedDay == i ? primaryColorLight : white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: selectedDay == i ? primaryColor : Color(0xFFEBEAEA),
              ),
            ),
            //height: 100,
            width: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(weekdays[today.add(Duration(days: i)).weekday]),
                Text(
                  today.add(Duration(days: i)).day.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(
                  selectedDay == i
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off_rounded,
                  color: selectedDay == i ? primaryColor : dividerColor,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return dates;
  }

  bool _isLoading = false;
  var mealPlanFromServer = {};
  List mealPlans = [];
  List completeNutrientBreakdown = [];
  void _getMealPlansRequest(int meal_plan_id) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });

      Map data = await apiService.getWithToken(
        mealPlanById + meal_plan_id.toString(),
        //userDetail.dietaryPreference.primaryMealPlanId.toString(),
        {},
      );
      setState(() {
        mealPlanFromServer = data;
        mealPlans = mealPlanFromServer['meal_meals'];
        completeNutrientBreakdown =
            mealPlanFromServer['complete_nutrient_breakdown'];
        _isLoading = false;
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
      setState(() => _isLoading = false);
    }
  }

  List<Widget> mealPlanWidgets() {
    List<Widget> mealPlanWidgetsList = [];
    for (int i = 0; i < mealPlans.length; i++) {
      mealPlanWidgetsList.add(
        Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.all(10),
          decoration: borderRadius(white, 8),
          child: ExpandablePanel(
            header: heading("Meal " + (i + 1).toString()),
            collapsed: Text(
              "Time: " + mealPlans[i]['meal_time_formatted'],
              style: TextStyle(color: textMedium()),
            ),
            expanded: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Time: " + mealPlans[i]['meal_time_formatted'],
                  style: TextStyle(color: textMedium()),
                ),
                SizedBox(height: 10),
                Column(
                  children: recipeWidget(
                    mealPlans[i]['meal_recipes'],
                    mealPlans[i]['id'],
                    mealPlans[i],
                  ),
                ),
                Column(
                  children: brandedFoodWidget(
                    mealPlans[i]['meal_branded_foods'],
                    mealPlans[i]['id'],
                    mealPlans[i],
                  ),
                ),
                Column(
                  children: foodWidget(
                    mealPlans[i]['meal_foods'],
                    mealPlans[i]['id'],
                    mealPlans[i],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: borderRadius(dividerColor, 20),
                      height: 30,
                      width: 140,
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                Map<String, dynamic> mapToSend = {
                                  "log_date":
                                      adherenceForToday[0]["log"]['log_date'],
                                  "dietary_preference_id":
                                      adherenceForToday[0]["log"]['dietary_preference_id'],
                                  "meal_plan_id":
                                      adherenceForToday[0]["log"]['meal_plan_id'],
                                  "schedule_id": getActiveScheduleId(
                                    schedulesFromServer,
                                  ),
                                  "meal_meal_id": mealPlans[i]['id'],
                                  "is_on_plan": "Yes",
                                };
                                print(getActiveScheduleId(schedulesFromServer));
                                _setAdherenceToServer(mapToSend);
                              },
                              child: Container(
                                height: 35,
                                color:
                                    adherenceForToday[0]["log"]['log_adherences'][i]["is_on_plan"] ==
                                            "Yes"
                                        ? Colors.green
                                        : transparent,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Center(
                                  child: Text(
                                    "On Plan",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          adherenceForToday[0]["log"]['log_adherences'][i]["is_on_plan"] ==
                                                  "Yes"
                                              ? white
                                              : textMedium(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 35,
                            width: 1,
                            color: textLightest(),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Map<String, dynamic> mapToSend = {
                                  "log_date":
                                      adherenceForToday[0]["log"]['log_date'],
                                  "dietary_preference_id":
                                      adherenceForToday[0]["log"]['dietary_preference_id'],
                                  "meal_plan_id":
                                      adherenceForToday[0]["log"]['meal_plan_id'],
                                  "schedule_id": getActiveScheduleId(
                                    schedulesFromServer,
                                  ),
                                  "meal_meal_id": mealPlans[i]['id'],
                                  "is_on_plan": "No",
                                };
                                _setAdherenceToServer(mapToSend);
                              },
                              child: Container(
                                height: 35,
                                color:
                                    adherenceForToday[0]["log"]['log_adherences'][i]["is_on_plan"] ==
                                            "No"
                                        ? Colors.red
                                        : transparent,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Center(
                                  child: Text(
                                    "Off Plan",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          adherenceForToday[0]["log"]['log_adherences'][i]["is_on_plan"] ==
                                                  "No"
                                              ? white
                                              : textMedium(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    // if (mealPlans.length == 3) {
    //   mealPlanWidgetsList.add(
    //     Text(
    //       "No Data Available",
    //       style: TextStyle(color: primaryColor, fontSize: 18),
    //     ),
    //   );
    // }
    return mealPlanWidgetsList;
  }

  bool isLoadingAdherence = false;
  void _setAdherenceToServer(Map<String, dynamic> mapToSend) async {
    print(mapToSend);
    //return;
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        isLoadingAdherence = true;
      });
      showLoadingDialog(context, "Saving data...");

      // print(parameters);
      //return;
      dynamic data = await apiService.postWithToken(addAdherence, mapToSend);
      print("journal----" + data.toString());
      setState(() {
        //showToast("hello");
        hideLoadingDialog(context);
        _getAdherenceData();
        isLoadingAdherence = false;
        //getUserDetails();
      });
      //print(data);
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
      setState(() => isLoadingAdherence = false);
    }
  }

  int? getActiveScheduleId(List schedules) {
    final today = DateTime.now();

    for (final item in schedules) {
      final start = DateTime.parse(item['start_date']);
      final end = DateTime.parse(item['end_date']);

      // Check if today is between start & end (inclusive)
      if (!today.isBefore(start) && !today.isAfter(end)) {
        return item['id'];
      }
    }

    return 0; // No matching schedule found
  }

  List schedulesFromServer = [];

  void _getSchedulesRequest() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        _isLoading = true;
      });

      Map data = await apiService.getWithToken(getSchedule, {});
      setState(() {
        schedulesFromServer = data['table']['data'];
        _isLoading = false;
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
      setState(() => _isLoading = false);
    }
  }

  List<Widget> foodWidget(List foods, int meal_id, dynamic mealPlan) {
    List<Widget> foodWidgetsList = [];
    for (int i = 0; i < foods.length; i++) {
      foodWidgetsList.add(SingleItemDescription(foods[i], mealPlan));
    }

    return foodWidgetsList;
  }

  List<Widget> brandedFoodWidget(List foods, int meal_id, dynamic mealPlan) {
    List<Widget> foodWidgetsList = [];
    for (int i = 0; i < foods.length; i++) {
      foodWidgetsList.add(SingleBrandedFoodItemDescription(foods[i], mealPlan));
    }

    return foodWidgetsList;
  }

  List<Widget> recipeWidget(List recipes, int meal_id, dynamic mealPlan) {
    List<Widget> foodWidgetsList = [];
    for (int i = 0; i < recipes.length; i++) {
      foodWidgetsList.add(SingleRecipeItemDescription(recipes[i], mealPlan));
    }
    return foodWidgetsList;
  }

  _editUser() async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();
    String? dateOfBirth = (await StorageService.getLoginData())?.profile.dob;
    Map<String, dynamic> dataToPost = {
      "timezone": currentTimeZone,
      "dob": dateOfBirth,
    };

    try {
      Map data = await apiService.putRequest(editProfile, {}, dataToPost);
      print(dataToPost);
      print(data);
      setState(() async {
        LoginResponse response = LoginResponse(
          profile: UserProfile.fromJson(data['profile']),
          dietaryPreference: DietaryPreference.fromJson(
            data['dietary_preference'],
          ),
          accessToken: data['access_token'],
        );

        await StorageService.saveLoginData(response);

        // showToast("Profile Updated");
      });
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
      }
    }
  }

  //dynamic adherenceFromServer = {};
  bool isLoadingGetAdherence = false;
  bool scheduleToday = false;
  List adherenceForToday = [];
  int todayMealPlanId = 0;
  void _getAdherenceData() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() {
        isLoadingGetAdherence = true;
      });

      int dietaryPrefs = userDetail.dietaryPreference.id;
      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String startDate = "2026-01-01";

      String dataToSend =
          "?dietary_preference_id=$dietaryPrefs&period=custom&start_date=$startDate&end_date=$todayDate";
      print("testing-----" + getAdherenceLogs + dataToSend);
      Map data = await apiService.getWithToken(
        getAdherenceLogs + dataToSend,
        {},
      );
      setState(() {
        isLoadingGetAdherence = false;
        adherenceForToday = data['list'];
        print("testing-----" + adherenceForToday.toString());
        if (adherenceForToday.isEmpty) {
          scheduleToday = false;
        } else {
          scheduleToday = true;
          todayMealPlanId = adherenceForToday[0]['log']['meal_plan_id'];
          _getMealPlansRequest(adherenceForToday[0]['log']['meal_plan_id']);
        }
      });
      print("Adherence-" + data.toString());
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print(
          "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
        );
      } else {
        print("Unexpected error: $e");
      }
      setState(() => isLoadingGetAdherence = false);
    }
  }

  //--------------------------------------
  // Schedule filtering functions
}
