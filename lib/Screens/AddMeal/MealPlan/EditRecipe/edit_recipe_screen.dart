import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/widgets/default_button.dart';
import 'package:flutter/material.dart';

class EditRecipeScreen extends StatefulWidget {
  final int recipeId;

  const EditRecipeScreen(this.recipeId, {Key? key}) : super(key: key);

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = true;

  // Controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();
  TextEditingController instructionsController = TextEditingController();
  TextEditingController substitutionController = TextEditingController();

  bool isActive = true;

  List categories = [];
  List foodsData = [];

  int? selectedCategoryId;

  List<Map<String, dynamic>> recipeFoods = [];

  Map<int, List> servingUnitsMap = {}; // food_id -> serving units

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      final recipeRes = await apiService.getWithToken(
        "food/custom-recipes/${widget.recipeId}",
        {},
      );

      final categoryRes = await apiService.get("food/category-with-foods");

      final recipe = recipeRes['data'];

      categories = categoryRes['data'];

      titleController.text = recipe['title'] ?? "";
      descriptionController.text = recipe['description'] ?? "";
      ingredientsController.text = recipe['ingredients'] ?? "";
      instructionsController.text = recipe['instructions'] ?? "";
      substitutionController.text = recipe['substitution'] ?? "";

      isActive = recipe['is_active'] == "Yes";

      selectedCategoryId = recipe['category_id'];

      // Prefill foods
      recipeFoods = List<Map<String, dynamic>>.from(
        recipe['recipeFoods'].map(
          (e) => {
            "food_id": e['food_id'],
            "serving_unit_id": e['serving_unit_id'],
            "amount": e['amount'].toString(),
          },
        ),
      );

      // Load serving units for each food
      for (var item in recipeFoods) {
        await loadServingUnits(item['food_id']);
      }

      setState(() => isLoading = false);
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadServingUnits(int foodId) async {
    if (servingUnitsMap.containsKey(foodId)) return;

    final res = await apiService.get(
      "food/custom-recipes/serving-units/$foodId",
    );

    servingUnitsMap[foodId] = res['data'];

    setState(() {});
  }

  void addFood() {
    setState(() {
      recipeFoods.add({"food_id": null, "serving_unit_id": null, "amount": ""});
    });
  }

  void removeFood(int index) {
    setState(() {
      recipeFoods.removeAt(index);
    });
  }

  List getAllFoods() {
    List allFoods = [];
    for (var cat in categories) {
      for (var sub in cat['subcategories']) {
        for (var variety in sub['varieties']) {
          for (var food in variety['foods']) {
            allFoods.add(food);
          }
        }
      }
    }
    return allFoods;
  }

  Future<void> updateRecipe() async {
    try {
      Map<String, dynamic> body = {
        "title": titleController.text,
        "category_id": selectedCategoryId,
        "description": descriptionController.text,
        "ingredients": ingredientsController.text,
        "instructions": instructionsController.text,
        "substitution": substitutionController.text,
        "is_active": isActive ? "Yes" : "No",
      };

      for (int i = 0; i < recipeFoods.length; i++) {
        body["recipe_foods[$i][food_id]"] = recipeFoods[i]['food_id'];
        body["recipe_foods[$i][serving_unit_id]"] =
            recipeFoods[i]['serving_unit_id'];
        body["recipe_foods[$i][amount]"] = recipeFoods[i]['amount'];
      }

      await apiService.postMultipart(
        "food/custom-recipes/${widget.recipeId}",
        body,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Recipe Updated")));

      Navigator.pop(context, true);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Edit Recipe")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final allFoods = getAllFoods();

    return Scaffold(
      appBar: AppBar(title: Text("Edit Recipe")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: ingredientsController,
              decoration: InputDecoration(labelText: "Ingredients"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: instructionsController,
              decoration: InputDecoration(labelText: "Instructions"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: substitutionController,
              decoration: InputDecoration(labelText: "Substitution"),
            ),

            SizedBox(height: 20),

            /// Foods Section
            Text("Foods", style: TextStyle(fontWeight: FontWeight.bold)),

            SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recipeFoods.length,
              itemBuilder: (context, index) {
                var item = recipeFoods[index];

                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        /// Food Dropdown
                        DropdownButtonFormField<int>(
                          value: item['food_id'],
                          hint: Text("Select Food"),
                          items:
                              allFoods.map<DropdownMenuItem<int>>((food) {
                                return DropdownMenuItem(
                                  value: food['id'],
                                  child: Text(food['name']),
                                );
                              }).toList(),
                          onChanged: (val) async {
                            item['food_id'] = val;
                            item['serving_unit_id'] = null;

                            await loadServingUnits(val!);

                            setState(() {});
                          },
                        ),

                        SizedBox(height: 10),

                        /// Serving Unit Dropdown
                        DropdownButtonFormField<int>(
                          value: item['serving_unit_id'],
                          hint: Text("Serving Unit"),
                          items:
                              (servingUnitsMap[item['food_id']] ?? [])
                                  .map<DropdownMenuItem<int>>((unit) {
                                    return DropdownMenuItem(
                                      value: unit['id'],
                                      child: Text(unit['name']),
                                    );
                                  })
                                  .toList(),
                          onChanged: (val) {
                            item['serving_unit_id'] = val;
                            setState(() {});
                          },
                        ),

                        SizedBox(height: 10),

                        /// Amount
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: "Amount"),
                          onChanged: (val) {
                            item['amount'] = val;
                          },
                          controller: TextEditingController(
                            text: item['amount'],
                          ),
                        ),

                        SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeFood(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 10),

            DefaultButton("Add Food", addFood),

            SizedBox(height: 20),

            DefaultButton("Update Recipe", updateRecipe),
          ],
        ),
      ),
    );
  }
}
