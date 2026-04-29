// lib/Screens/CustomRecipes/custom_recipes_screen.dart
//
// Shows the user's custom recipes.  Two modes:
//
//   Standalone  →  CustomRecipesScreen()
//   Pick mode   →  CustomRecipesScreen(mealMealId: id)
//                  Tapping a recipe shows a detail / add-to-meal sheet.

import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/custom_recipe.dart';
import 'package:diet_maker/Screens/CustomRecipes/custom_recipe_form_screen.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/loading_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomRecipesScreen extends StatefulWidget {
  final int? mealMealId; // non-null → pick mode

  const CustomRecipesScreen({Key? key, this.mealMealId}) : super(key: key);

  @override
  State<CustomRecipesScreen> createState() => _CustomRecipesScreenState();
}

class _CustomRecipesScreenState extends State<CustomRecipesScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  List<CustomRecipe> _recipes = [];

  bool get _pickMode => widget.mealMealId != null;

  // Amount controller (pick mode only)
  final TextEditingController _amountCtrl = TextEditingController(text: '1');
  double _servingAmount = 1.0;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  // ─── API ──────────────────────────────────────────────────────────────────

  Future<void> _fetchRecipes() async {
    setState(() => _isLoading = true);
    try {
      final raw = await _api.getWithToken('food/custom-recipes', {});
      setState(() {
        _recipes = CustomRecipe.listFromResponse(raw);
        _isLoading = false;
      });
    } on ApiException catch (e) {
      showToast(e.message);
      setState(() => _isLoading = false);
    } catch (e) {
      showToast('Could not load recipes');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecipe(int id) async {
    try {
      showLoadingDialog(context, 'Deleting...');
      await _api.deleteWithToken('food/custom-recipes/$id', {});
      hideLoadingDialog(context);
      showToast('Recipe deleted');
      _fetchRecipes();
    } on ApiException catch (e) {
      hideLoadingDialog(context);
      showToast(e.message);
    } catch (e) {
      hideLoadingDialog(context);
      showToast('Could not delete recipe');
    }
  }

  Future<void> _addToMeal(CustomRecipe recipe) async {
    if (widget.mealMealId == null) return;
    try {
      showLoadingDialog(context, 'Adding to meal...');
      await _api.postWithToken('diet/meal-recipes', {
        'meal_meal_id': widget.mealMealId,
        'recipe_id': recipe.id,
        'food_amount': _servingAmount,
      });
      hideLoadingDialog(context);
      showToast('${recipe.title} added');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      hideLoadingDialog(context);
      showToast(e.message);
    } catch (e) {
      hideLoadingDialog(context);
      showToast('Could not add recipe');
    }
  }

  // ─── Detail bottom-sheet ──────────────────────────────────────────────────

  void _showDetail(CustomRecipe recipe) {
    _amountCtrl.text = '1';
    _servingAmount = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor(),
      builder:
          (_) => StatefulBuilder(
            builder: (ctx, setSht) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.75,
                maxChildSize: 0.95,
                builder:
                    (_, scroll) => ListView(
                      controller: scroll,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Title + image
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (recipe.categoryTitle.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      recipe.categoryTitle,
                                      style: TextStyle(
                                        color: textLightest(),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (recipe.imageUrl.isNotEmpty)
                              Container(
                                width: 72,
                                height: 72,
                                margin: const EdgeInsets.only(left: 12),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: LoadingImage(recipe.imageUrl),
                              ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Macros
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _macroTile(
                              'Protein',
                              recipe.protein.toStringAsFixed(1) + 'g',
                              protien,
                            ),
                            _macroTile(
                              'Carbs',
                              recipe.carbohydrate.toStringAsFixed(1) + 'g',
                              carbs,
                            ),
                            _macroTile(
                              'Fat',
                              recipe.fat.toStringAsFixed(1) + 'g',
                              fats,
                            ),
                            _macroTile(
                              'Calories',
                              recipe.calorie.toStringAsFixed(0) + ' kcal',
                              calories,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (recipe.description.isNotEmpty) ...[
                          _sheetHeading('Description'),
                          Text(
                            recipe.description,
                            style: TextStyle(
                              color: textMedium(),
                              fontSize: 14,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (recipe.ingredients.isNotEmpty) ...[
                          _sheetHeading('Ingredients'),
                          Text(
                            recipe.ingredients,
                            style: TextStyle(
                              color: textMedium(),
                              fontSize: 14,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (recipe.instructions.isNotEmpty) ...[
                          _sheetHeading('Instructions'),
                          Text(
                            recipe.instructions,
                            style: TextStyle(
                              color: textMedium(),
                              fontSize: 14,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (recipe.substitution.isNotEmpty) ...[
                          _sheetHeading('Substitutions'),
                          Text(
                            recipe.substitution,
                            style: TextStyle(
                              color: textMedium(),
                              fontSize: 14,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Add-to-meal controls (pick mode)
                        if (_pickMode) ...[
                          const Divider(height: 24),
                          Text(
                            'Servings',
                            style: TextStyle(color: textMedium(), fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          CupertinoTextField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            placeholder: '1',
                            onChanged: (v) {
                              final parsed = double.tryParse(v);
                              if (parsed != null)
                                setSht(() => _servingAmount = parsed);
                            },
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: backgroundColor(),
                              border: Border.all(color: dividerColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _addToMeal(recipe);
                              },
                              child: const Text(
                                'Add to meal',
                                style: TextStyle(
                                  color: white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
              );
            },
          ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _macroTile(String label, String value, Color dot) => Column(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: dot,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: textDark(),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
      Text(label, style: TextStyle(color: textLightest(), fontSize: 11)),
    ],
  );

  Widget _sheetHeading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        color: textDark(),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  // ─── Recipe card ──────────────────────────────────────────────────────────

  Widget _recipeCard(CustomRecipe r) => GestureDetector(
    onTap: () => _showDetail(r),
    child: GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: dividerColor),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 12),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: primaryColorLight,
              ),
              child:
                  r.imageUrl.isNotEmpty
                      ? LoadingImage(r.imageUrl)
                      : const Icon(
                        Icons.restaurant_menu,
                        color: primaryColor,
                        size: 28,
                      ),
            ),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                    style: TextStyle(
                      color: textDark(),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'P ${r.protein.toStringAsFixed(0)}g · '
                    'C ${r.carbohydrate.toStringAsFixed(0)}g · '
                    'F ${r.fat.toStringAsFixed(0)}g · '
                    '${r.calorie.toStringAsFixed(0)} kcal',
                    style: TextStyle(color: textMedium(), fontSize: 12),
                  ),
                  if (r.categoryTitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      r.categoryTitle,
                      style: TextStyle(color: textLightest(), fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),

            // Actions (standalone only)
            if (!_pickMode)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: textLightest(), size: 20),
                onSelected: (val) async {
                  if (val == 'edit') {
                    // Fetch full recipe before opening form
                    showLoadingDialog(context, 'Loading...');
                    try {
                      final raw = await _api.getWithToken(
                        'food/custom-recipes/${r.id}',
                        {},
                      );
                      hideLoadingDialog(context);
                      // final full = CustomRecipe.fromSingleResponse(raw);
                      // final refresh = await Navigator.push<bool>(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => CustomRecipeFormScreen(recipe: full),
                      //   ),
                      // );
                      final refresh = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CustomRecipeFormScreen(
                                recipeId: r.id,
                                recipeTitle: r.title,
                              ),
                        ),
                      );
                      if (refresh == true) _fetchRecipes();
                    } catch (e) {
                      hideLoadingDialog(context);
                      showToast('Could not load recipe details');
                    }
                  } else if (val == 'delete') {
                    showGenericDialog(
                      context,
                      'Delete recipe',
                      'Delete "${r.title}"? This cannot be undone.',
                      'Delete',
                      () => _deleteRecipe(r.id),
                    );
                  }
                },
                itemBuilder:
                    (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar:
          _pickMode
              ? null
              : AppBar(
                backgroundColor: backgroundColor(),
                title: heading(
                  _pickMode ? 'Pick a custom recipe' : 'My custom recipes',
                ),
                actions: [
                  if (!_pickMode)
                    IconButton(
                      icon: const Icon(Icons.add, color: primaryColor),
                      onPressed: () async {
                        final refresh = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomRecipeFormScreen(),
                          ),
                        );
                        if (refresh == true) _fetchRecipes();
                      },
                    ),
                ],
              ),
      body:
          _isLoading
              ? loader('Loading recipes...')
              : _recipes.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.restaurant_menu_outlined,
                      size: 60,
                      color: textLightest(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No custom recipes yet',
                      style: TextStyle(color: textLightest(), fontSize: 16),
                    ),
                    if (!_pickMode) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          final refresh = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomRecipeFormScreen(),
                            ),
                          );
                          if (refresh == true) _fetchRecipes();
                        },
                        child: const Text('Create your first recipe'),
                      ),
                    ],
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchRecipes,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _recipes.length,
                  itemBuilder: (_, i) => _recipeCard(_recipes[i]),
                ),
              ),
      floatingActionButton:
          (!_pickMode && !_isLoading)
              ? FloatingActionButton(
                backgroundColor: primaryColor,
                onPressed: () async {
                  final refresh = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomRecipeFormScreen(),
                    ),
                  );
                  if (refresh == true) _fetchRecipes();
                },
                child: const Icon(Icons.add, color: white),
              )
              : null,
    );
  }
}
