// lib/Models/custom_recipe.dart
//
// Matches the actual API responses documented below.
//
// LIST   GET api/food/custom-recipes
//   { "data": [ { "id", "title", "category_id", "category_title",
//                 "image_url", "description", "ingredients",
//                 "instructions", "substitution",
//                 "protein", "carbohydrate", "fat", "calorie",
//                 "is_active", "is_custom", "created_at", ... } ] }
//
// SINGLE GET api/food/custom-recipes/{id}
//   { "data": { "recipe": { ...same fields as above... },
//               "recipeFoods": [ { "id", "food_id", "serving_unit_id",
//                                  "amount", "primary_category_id",
//                                  "secondary_category_id", "variety_id" } ] } }
//
// CATEGORIES  GET api/food/custom-recipes/recipe-categories
//   { "data": [ { "value": 1, "label": "Breakfast" } ] }
//
// SERVING UNITS (per recipe)  GET api/food/custom-recipes/serving-units/{recipe_id}
//   { "data": [ { "value": 4, "label": "gram" } ] }
//
// FOOD SERVING SIZES  GET api/food/foods/{food_id}
//   { "food_serving_sizes": [ { "id", "serving_size_unit_id",
//     "average_serving_size", "protein", "carbohydrate", "fat",
//     "calorie", ... } ] }

// ─── value / label pair (categories, serving-unit options) ────────────────────

class ValueLabel {
  final int value;
  final String label;

  const ValueLabel({required this.value, required this.label});

  factory ValueLabel.fromJson(Map<String, dynamic> json) =>
      ValueLabel(value: json['value'] as int, label: json['label'].toString());

  /// Unwraps { "data": [...] } or bare list.
  static List<ValueLabel> listFromResponse(dynamic json) {
    List<dynamic> raw;
    if (json is List) {
      raw = json;
    } else if (json is Map && json['data'] is List) {
      raw = json['data'] as List<dynamic>;
    } else {
      raw = [];
    }
    return raw
        .map((e) => ValueLabel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// ─── Serving size from GET api/food/foods/{id} → food_serving_sizes[] ─────────

class FoodServingSize {
  final int id;
  final int servingSizeUnitId;
  final String averageServingSize; // human-readable, e.g. "248 grams"
  final double protein;
  final double carbohydrate;
  final double fat;
  final double calorie;

  const FoodServingSize({
    required this.id,
    required this.servingSizeUnitId,
    required this.averageServingSize,
    required this.protein,
    required this.carbohydrate,
    required this.fat,
    required this.calorie,
  });

  factory FoodServingSize.fromJson(Map<String, dynamic> j) => FoodServingSize(
    id: j['id'] ?? 0,
    servingSizeUnitId: j['serving_size_unit_id'] ?? 0,
    averageServingSize: j['average_serving_size']?.toString() ?? '',
    protein: (j['protein'] ?? 0).toDouble(),
    carbohydrate: (j['carbohydrate'] ?? 0).toDouble(),
    fat: (j['fat'] ?? 0).toDouble(),
    calorie: (j['calorie'] ?? 0).toDouble(),
  );

  static List<FoodServingSize> listFromFoodResponse(dynamic json) {
    final raw =
        (json is Map ? json['food_serving_sizes'] : null) as List<dynamic>? ??
        [];
    return raw
        .map((e) => FoodServingSize.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// ─── A single food row inside a custom recipe ────────────────────────────────
// NOTE: The API recipeFoods[] does NOT include food title or unit label.
// Those are resolved locally using food detail or category-with-foods data.

class CustomRecipeFood {
  final int id; // recipeFoods row id (0 for new unsaved rows)
  final int foodId;
  final int servingUnitId; // maps to FoodServingSize.id (not unit_id)
  final double amount;

  // Filled in locally after resolving against food detail data:
  String foodTitle;
  String servingUnitLabel; // e.g. "248 grams"

  CustomRecipeFood({
    required this.id,
    required this.foodId,
    required this.servingUnitId,
    required this.amount,
    this.foodTitle = '',
    this.servingUnitLabel = '',
  });

  factory CustomRecipeFood.fromJson(Map<String, dynamic> j) => CustomRecipeFood(
    id: j['id'] ?? 0,
    foodId: j['food_id'] ?? 0,
    servingUnitId: j['serving_unit_id'] ?? 0,
    amount: (j['amount'] ?? 0).toDouble(),
  );
}

// ─── Main CustomRecipe model ──────────────────────────────────────────────────

class CustomRecipe {
  final int id;
  final int categoryId;
  final String categoryTitle; // present directly in list response items
  final String title;
  final String description;
  final String ingredients;
  final String instructions;
  final String substitution;
  final String isActive;
  final String imageUrl;
  final double protein;
  final double carbohydrate;
  final double fat;
  final double calorie;
  final bool isCustom;
  final List<CustomRecipeFood> recipeFoods;
  final String createdAt;

  const CustomRecipe({
    required this.id,
    required this.categoryId,
    required this.categoryTitle,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.substitution,
    required this.isActive,
    required this.imageUrl,
    required this.protein,
    required this.carbohydrate,
    required this.fat,
    required this.calorie,
    required this.isCustom,
    required this.recipeFoods,
    required this.createdAt,
  });

  // ── Shared field parser ────────────────────────────────────────────────────
  static CustomRecipe _fromMap(
    Map<String, dynamic> d, {
    List<CustomRecipeFood> foods = const [],
  }) {
    return CustomRecipe(
      id: d['id'] ?? 0,
      categoryId: d['category_id'] ?? 0,
      categoryTitle: d['category_title']?.toString() ?? '',
      title: d['title']?.toString() ?? '',
      description: d['description']?.toString() ?? '',
      ingredients: d['ingredients']?.toString() ?? '',
      instructions: d['instructions']?.toString() ?? '',
      substitution: d['substitution']?.toString() ?? '',
      isActive: d['is_active']?.toString() ?? 'Yes',
      imageUrl: d['image_url']?.toString() ?? '',
      protein: (d['protein'] ?? 0).toDouble(),
      carbohydrate: (d['carbohydrate'] ?? 0).toDouble(),
      fat: (d['fat'] ?? 0).toDouble(),
      calorie: (d['calorie'] ?? 0).toDouble(),
      isCustom: d['is_custom'] == true,
      recipeFoods: foods,
      createdAt: d['created_at']?.toString() ?? '',
    );
  }

  // ── Parse LIST response:  { "data": [ {...}, ... ] } ──────────────────────
  static List<CustomRecipe> listFromResponse(dynamic json) {
    final List<dynamic> raw;
    if (json is List) {
      raw = json;
    } else if (json is Map && json['data'] is List) {
      raw = json['data'] as List<dynamic>;
    } else {
      raw = const [];
    }
    return raw.map((e) => _fromMap(e as Map<String, dynamic>)).toList();
  }

  // ── Parse SINGLE response:
  //    { "data": { "recipe": {...}, "recipeFoods": [...] } }
  // static CustomRecipe fromSingleResponse(dynamic json) {
  //   final Map<String, dynamic> outer;
  //   if (json is Map && json['data'] is Map) {
  //     outer = json['data'] as Map<String, dynamic>;
  //   } else if (json is Map) {
  //     outer = json;
  //   } else {
  //     throw const FormatException('Unexpected shape for single custom recipe');
  //   }

  //   final recipeMap = outer['recipe'] as Map<String, dynamic>? ?? outer;
  //   final foodsRaw = outer['recipeFoods'] as List<dynamic>? ?? [];
  //   final foods =
  //       foodsRaw
  //           .map((f) => CustomRecipeFood.fromJson(f as Map<String, dynamic>))
  //           .toList();

  //   return _fromMap(recipeMap, foods: foods);
  // }
  static CustomRecipe fromSingleResponse(dynamic json) {
    final Map<String, dynamic> outer;

    if (json is Map && json['data'] is Map) {
      outer = Map<String, dynamic>.from(json['data']);
    } else if (json is Map) {
      outer = Map<String, dynamic>.from(json);
    } else {
      throw const FormatException('Unexpected shape for single custom recipe');
    }

    final recipeMap =
        outer['recipe'] != null
            ? Map<String, dynamic>.from(outer['recipe'])
            : outer;

    final foodsRaw = outer['recipeFoods'] as List<dynamic>? ?? [];

    final foods =
        foodsRaw
            .map((f) => CustomRecipeFood.fromJson(Map<String, dynamic>.from(f)))
            .toList();

    return _fromMap(recipeMap, foods: foods);
  }
}
