// lib/utils/recipe_clone_helper.dart
//
// Call cloneRecipe() from anywhere — it fetches the recipe detail,
// builds the correct payload, posts to food/custom-recipes, and
// returns true on success.
//
// Usage:
//   await cloneRecipe(context, recipeId: 5, recipeTitle: 'Apple Pie Oats');

import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:flutter/material.dart';

Future<bool> cloneRecipe(
  BuildContext context, {
  required int recipeId,
  String recipeTitle = 'Recipe',
}) async {
  final api = ApiService();

  // ── Step 1: confirm ────────────────────────────────────────────────────────
  bool confirmed = false;
  await showGenericDialog(
    context,
    'Clone recipe',
    'This will create an editable copy of "$recipeTitle" in your custom recipes.',
    'Clone',
    () => confirmed = true,
  );
  if (!confirmed) return false;

  // ── Step 2: fetch full recipe detail ──────────────────────────────────────
  showLoadingDialog(context, 'Cloning recipe...');
  try {
    final raw = await api.getWithToken('food/recipes/$recipeId', {});

    // ── Step 3: build multipart fields ──────────────────────────────────────
    final fields = <String, String>{
      'title': 'Copy of ${raw['title'] ?? recipeTitle}',
      'category_id': (raw['category_id'] ?? 1).toString(),
      'description': raw['description']?.toString() ?? '',
      'ingredients': raw['ingredients']?.toString() ?? '',
      'instructions': raw['instructions']?.toString() ?? '',
      'substitution': raw['substitution']?.toString() ?? '',
      'is_active': 'Yes',
    };

    // Map recipe_foods[] — each item has food_id, food_serving_size.id, amount
    // The create API expects:
    //   recipe_foods[i][food_id]
    //   recipe_foods[i][serving_unit_id]  ← food_serving_size.id
    //   recipe_foods[i][amount]
    final recipeFoods = raw['recipe_foods'] as List<dynamic>? ?? [];
    int idx = 0;
    for (final f in recipeFoods) {
      final foodId = f['food_id'];
      final servingSize = f['food_serving_size'] as Map<String, dynamic>?;
      final servingSizeId = servingSize?['id'];
      final amount = f['amount'] ?? f['food_amount'] ?? 1;

      if (foodId == null || servingSizeId == null) continue;

      fields['recipe_foods[$idx][food_id]'] = foodId.toString();
      fields['recipe_foods[$idx][serving_unit_id]'] = servingSizeId.toString();
      fields['recipe_foods[$idx][amount]'] = amount.toString();
      idx++;
    }

    // ── Step 4: post to create custom recipe ─────────────────────────────────
    // Note: image is intentionally skipped — the original image URL is not a
    // local file so we cannot re-upload it. The user can add one when editing.
    await api.postMultipart('food/custom-recipes', fields);

    hideLoadingDialog(context);
    showToast('"Copy of $recipeTitle" saved to My Custom Recipes');
    return true;
  } on ApiException catch (e) {
    hideLoadingDialog(context);
    showToast(e.message);
    return false;
  } catch (e) {
    hideLoadingDialog(context);
    showToast('Could not clone recipe. Please try again.');
    return false;
  }
}
