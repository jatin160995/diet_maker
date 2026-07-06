// // lib/Screens/CustomRecipes/custom_recipe_form_screen.dart

// import 'dart:io';

// import 'package:diet_maker/Exception/api_exception.dart';
// import 'package:diet_maker/Models/custom_recipe.dart';
// import 'package:diet_maker/services/api_service.dart';
// import 'package:diet_maker/utils/app_helpers.dart';
// import 'package:diet_maker/utils/color_utils.dart';
// import 'package:diet_maker/utils/design_utils.dart';
// import 'package:diet_maker/widgets/app_popups.dart';
// import 'package:diet_maker/widgets/custom_edit_text.dart';
// import 'package:diet_maker/widgets/small_heading.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// // ─── Local data class for one food row in the form ────────────────────────────

// class _FoodRow {
//   int? foodId;
//   String foodTitle = '';

//   int? servingSizeId;
//   String servingSizeLabel = '';

//   List<FoodServingSize> availableSizes = [];
//   bool loadingSizes = false;

//   String amount = '';
//   final TextEditingController amountCtrl = TextEditingController();

//   _FoodRow({
//     this.foodId,
//     this.foodTitle = '',
//     this.servingSizeId,
//     this.servingSizeLabel = '',
//     String amount = '',
//   }) {
//     this.amount = amount;
//     amountCtrl.text = amount;
//   }

//   void dispose() => amountCtrl.dispose();
// }

// // ─── Screen ───────────────────────────────────────────────────────────────────

// class CustomRecipeFormScreen extends StatefulWidget {
//   // Pass the recipe ID for edit mode, null for create mode.
//   // We fetch full details ourselves using food/recipes/{id}.
//   final int? recipeId;
//   final String? recipeTitle; // optional — for the app bar while loading

//   const CustomRecipeFormScreen({Key? key, this.recipeId, this.recipeTitle})
//     : super(key: key);

//   @override
//   State<CustomRecipeFormScreen> createState() => _CustomRecipeFormScreenState();
// }

// class _CustomRecipeFormScreenState extends State<CustomRecipeFormScreen> {
//   final ApiService _api = ApiService();
//   final ImagePicker _picker = ImagePicker();

//   bool get _isEdit => widget.recipeId != null;

//   // ── Text controllers ──────────────────────────────────────────────────────
//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   final _ingrCtrl = TextEditingController();
//   final _instrCtrl = TextEditingController();
//   final _subCtrl = TextEditingController();

//   bool _isActive = true;
//   File? _pickedImage;
//   String? _existingImageUrl;
//   bool _isSaving = false;

//   // ── Loading state ─────────────────────────────────────────────────────────
//   bool _isLoadingRecipe = false; // true while fetching recipe detail for edit

//   // ── Category picker ───────────────────────────────────────────────────────
//   List<ValueLabel> _categories = [];
//   int? _selectedCategoryValue;
//   String _selectedCategoryLabel = 'Select category';
//   bool _loadingCats = false;

//   // ── Food search data ──────────────────────────────────────────────────────
//   List<Map<String, dynamic>> _allFoods = [];
//   bool _loadingFoods = false;

//   // Cache: food_id → List<FoodServingSize>
//   final Map<int, List<FoodServingSize>> _sizesCache = {};

//   // ── Recipe food rows ──────────────────────────────────────────────────────
//   final List<_FoodRow> _rows = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//     _loadAllFoods().then((_) {
//       // Once foods are loaded, fetch recipe details if editing
//       if (_isEdit) _fetchAndPrefill();
//     });
//   }

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _descCtrl.dispose();
//     _ingrCtrl.dispose();
//     _instrCtrl.dispose();
//     _subCtrl.dispose();
//     for (final r in _rows) r.dispose();
//     super.dispose();
//   }

//   // ─── Loaders ──────────────────────────────────────────────────────────────

//   Future<void> _loadCategories() async {
//     setState(() => _loadingCats = true);
//     try {
//       final raw = await _api.getWithToken(
//         'food/custom-recipes/recipe-categories',
//         {},
//       );
//       setState(() {
//         _categories = ValueLabel.listFromResponse(raw);
//         _loadingCats = false;
//       });
//     } catch (_) {
//       setState(() => _loadingCats = false);
//     }
//   }

//   Future<void> _loadAllFoods() async {
//     setState(() => _loadingFoods = true);
//     try {
//       final dynamic raw = await _api.getWithToken(
//         'food/category-with-foods',
//         {},
//       );
//       final List<dynamic> topList = raw is List ? raw : [];
//       final List<Map<String, dynamic>> flat = [];
//       for (final cat in topList) {
//         for (final child in (cat['child'] as List<dynamic>? ?? [])) {
//           for (final variety in (child['varieties'] as List<dynamic>? ?? [])) {
//             for (final food in (variety['foods'] as List<dynamic>? ?? [])) {
//               flat.add({
//                 'id': food['id'],
//                 'title': food['title']?.toString() ?? '',
//               });
//             }
//           }
//         }
//       }
//       setState(() {
//         _allFoods = flat;
//         _loadingFoods = false;
//       });
//     } catch (_) {
//       setState(() => _loadingFoods = false);
//     }
//   }

//   Future<List<FoodServingSize>> _getServingSizes(int foodId) async {
//     if (_sizesCache.containsKey(foodId)) return _sizesCache[foodId]!;
//     try {
//       final raw = await _api.getWithToken('food/foods/$foodId', {});
//       final sizes = FoodServingSize.listFromFoodResponse(raw);
//       _sizesCache[foodId] = sizes;
//       return sizes;
//     } catch (_) {
//       return [];
//     }
//   }

//   // ─── Fetch recipe detail and prefill (edit mode) ──────────────────────────
//   // Uses GET food/recipes/{id} which returns recipe_foods[] with
//   // food_serving_size objects that already contain macros.

//   Future<void> _fetchAndPrefill() async {
//     setState(() => _isLoadingRecipe = true);
//     try {
//       // NEW endpoint — richer response with recipe_foods[].food_serving_size
//       final raw = await _api.getWithToken(
//         'food/recipes/${widget.recipeId}',
//         {},
//       );

//       // Top-level fields
//       _titleCtrl.text = raw['title']?.toString() ?? '';
//       _descCtrl.text = raw['description']?.toString() ?? '';
//       _ingrCtrl.text = raw['ingredients']?.toString() ?? '';
//       _instrCtrl.text = raw['instructions']?.toString() ?? '';
//       _subCtrl.text = raw['substitution']?.toString() ?? '';
//       _isActive = raw['is_active']?.toString() == 'Yes';
//       _existingImageUrl =
//           raw['image_url']?.toString().isNotEmpty == true
//               ? raw['image_url'].toString()
//               : null;

//       final catId = raw['category_id'] as int?;
//       _selectedCategoryValue = catId;

//       // Try to resolve category label from already-loaded list
//       if (catId != null) {
//         final match = _categories.where((c) => c.value == catId);
//         _selectedCategoryLabel =
//             match.isNotEmpty ? match.first.label : 'Category $catId';
//       }

//       // Build food rows from recipe_foods[]
//       final recipeFoods = raw['recipe_foods'] as List<dynamic>? ?? [];
//       for (final f in recipeFoods) {
//         final foodId = f['food_id'] as int?;
//         final servingSizeMap = f['food_serving_size'] as Map<String, dynamic>?;
//         final servingSizeId = servingSizeMap?['id'] as int?;
//         final label = servingSizeMap?['average_serving_size']?.toString() ?? '';

//         // Resolve food title from our flat list
//         final String foodTitle;
//         if (foodId != null) {
//           final match = _allFoods.where((fd) => fd['id'] == foodId);
//           foodTitle =
//               match.isNotEmpty
//                   ? match.first['title'] as String
//                   : 'Food #$foodId';
//         } else {
//           foodTitle = '';
//         }

//         // Build a FoodServingSize from the embedded object so the macro
//         // preview works immediately without an extra API call.
//         FoodServingSize? embeddedSize;
//         if (servingSizeMap != null && servingSizeId != null) {
//           embeddedSize = FoodServingSize(
//             id: servingSizeId,
//             servingSizeUnitId: 0, // not present in this response, unused here
//             averageServingSize: label,
//             protein: (servingSizeMap['protein'] ?? 0).toDouble(),
//             carbohydrate: (servingSizeMap['carbohydrate'] ?? 0).toDouble(),
//             fat: (servingSizeMap['fat'] ?? 0).toDouble(),
//             calorie: (servingSizeMap['calorie'] ?? 0).toDouble(),
//           );
//           // Pre-populate cache so the picker opens instantly
//           if (foodId != null) {
//             _sizesCache[foodId] ??= [];
//             // Insert the embedded size if not already cached
//             if (!_sizesCache[foodId]!.any((s) => s.id == servingSizeId)) {
//               _sizesCache[foodId]!.insert(0, embeddedSize);
//             }
//           }
//         }

//         // Determine the original amount stored in the recipe food row.
//         // The API does not return amount here directly on the recipe_foods[]
//         // item (only the serving size object), so default to 1.
//         // If the backend adds an "amount" field later, read it here.
//         final double amount = (f['amount'] ?? f['food_amount'] ?? 1).toDouble();

//         final row = _FoodRow(
//           foodId: foodId,
//           foodTitle: foodTitle,
//           servingSizeId: servingSizeId,
//           servingSizeLabel: label,
//           amount:
//               amount == amount.roundToDouble()
//                   ? amount.toInt().toString()
//                   : amount.toStringAsFixed(2),
//         );
//         if (embeddedSize != null) {
//           row.availableSizes = _sizesCache[foodId] ?? [embeddedSize];
//         }
//         _rows.add(row);
//       }

//       if (_rows.isEmpty) _rows.add(_FoodRow());

//       setState(() => _isLoadingRecipe = false);
//     } catch (e) {
//       setState(() => _isLoadingRecipe = false);
//       showToast('Could not load recipe details');
//     }
//   }

//   // ─── Food picker flow ─────────────────────────────────────────────────────

//   Future<void> _openFoodSearch(int rowIndex) async {
//     if (_loadingFoods) {
//       showToast('Food list is loading, please wait');
//       return;
//     }
//     final TextEditingController searchCtrl = TextEditingController();
//     List<Map<String, dynamic>> filtered = List.from(_allFoods);

//     final selected = await showModalBottomSheet<Map<String, dynamic>>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: backgroundColor(),
//       builder:
//           (_) => StatefulBuilder(
//             builder: (ctx, setSht) {
//               void filter(String q) => setSht(() {
//                 filtered =
//                     _allFoods
//                         .where(
//                           (f) => (f['title'] as String).toLowerCase().contains(
//                             q.toLowerCase(),
//                           ),
//                         )
//                         .toList();
//               });

//               return DraggableScrollableSheet(
//                 expand: false,
//                 initialChildSize: 0.85,
//                 builder:
//                     (_, scroll) => Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                           child: CupertinoTextField(
//                             controller: searchCtrl,
//                             placeholder: 'Search foods...',
//                             onChanged: filter,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 10,
//                             ),
//                             decoration: BoxDecoration(
//                               color: backgroundColor(),
//                               border: Border.all(color: dividerColor),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child:
//                               filtered.isEmpty
//                                   ? Center(
//                                     child: Text(
//                                       'No foods found',
//                                       style: TextStyle(color: textLightest()),
//                                     ),
//                                   )
//                                   : ListView.builder(
//                                     controller: scroll,
//                                     itemCount: filtered.length,
//                                     itemBuilder:
//                                         (_, i) => ListTile(
//                                           title: Text(
//                                             filtered[i]['title'] as String,
//                                             style: TextStyle(
//                                               color: textDark(),
//                                               fontSize: 14,
//                                             ),
//                                           ),
//                                           onTap:
//                                               () => Navigator.pop(
//                                                 ctx,
//                                                 filtered[i],
//                                               ),
//                                         ),
//                                   ),
//                         ),
//                       ],
//                     ),
//               );
//             },
//           ),
//     );

//     if (selected == null) return;
//     final foodId = selected['id'] as int;
//     final foodTitle = selected['title'] as String;

//     setState(() {
//       _rows[rowIndex].foodId = foodId;
//       _rows[rowIndex].foodTitle = foodTitle;
//       _rows[rowIndex].servingSizeId = null;
//       _rows[rowIndex].servingSizeLabel = '';
//       _rows[rowIndex].availableSizes = [];
//       _rows[rowIndex].loadingSizes = true;
//     });

//     final sizes = await _getServingSizes(foodId);
//     if (!mounted) return;
//     setState(() => _rows[rowIndex].loadingSizes = false);

//     if (sizes.isEmpty) {
//       showToast('No serving sizes found for this food');
//       return;
//     }

//     await _openServingSizePicker(rowIndex, sizes);
//   }

//   Future<void> _openServingSizePicker(
//     int rowIndex,
//     List<FoodServingSize> sizes,
//   ) async {
//     setState(() => _rows[rowIndex].availableSizes = sizes);

//     await showModalBottomSheet(
//       context: context,
//       backgroundColor: backgroundColor(),
//       builder:
//           (_) => SafeArea(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                   child: Text(
//                     'Select serving size for\n${_rows[rowIndex].foodTitle}',
//                     style: TextStyle(
//                       color: textDark(),
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 const Divider(height: 1),
//                 Flexible(
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: sizes.length,
//                     itemBuilder: (_, i) {
//                       final s = sizes[i];
//                       return ListTile(
//                         title: Text(
//                           s.averageServingSize,
//                           style: TextStyle(color: textDark(), fontSize: 14),
//                         ),
//                         subtitle: Text(
//                           'P ${s.protein.toStringAsFixed(1)}g · '
//                           'C ${s.carbohydrate.toStringAsFixed(1)}g · '
//                           'F ${s.fat.toStringAsFixed(1)}g · '
//                           '${s.calorie.toStringAsFixed(1)} kcal',
//                           style: TextStyle(color: textMedium(), fontSize: 12),
//                         ),
//                         trailing:
//                             _rows[rowIndex].servingSizeId == s.id
//                                 ? const Icon(Icons.check, color: primaryColor)
//                                 : null,
//                         onTap: () {
//                           setState(() {
//                             _rows[rowIndex].servingSizeId = s.id;
//                             _rows[rowIndex].servingSizeLabel =
//                                 s.averageServingSize;
//                           });
//                           Navigator.pop(context);
//                         },
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//     );
//   }

//   // ─── Save ─────────────────────────────────────────────────────────────────

//   Future<void> _save() async {
//     if (_titleCtrl.text.trim().isEmpty) {
//       showToast('Please enter a title');
//       return;
//     }
//     if (_selectedCategoryValue == null) {
//       showToast('Please select a category');
//       return;
//     }

//     FocusManager.instance.primaryFocus?.unfocus();
//     setState(() => _isSaving = true);

//     final fields = <String, String>{
//       'title': _titleCtrl.text.trim(),
//       'category_id': _selectedCategoryValue.toString(),
//       'description': _descCtrl.text.trim(),
//       'ingredients': _ingrCtrl.text.trim(),
//       'instructions': _instrCtrl.text.trim(),
//       'substitution': _subCtrl.text.trim(),
//       'is_active': _isActive ? 'Yes' : 'No',
//     };

//     int idx = 0;
//     for (final row in _rows) {
//       if (row.foodId == null || row.servingSizeId == null) continue;
//       final amt = row.amountCtrl.text.trim();
//       fields['recipe_foods[$idx][food_id]'] = row.foodId.toString();
//       fields['recipe_foods[$idx][serving_unit_id]'] =
//           row.servingSizeId.toString();
//       fields['recipe_foods[$idx][amount]'] = amt.isEmpty ? '1' : amt;
//       idx++;
//     }

//     List<http.MultipartFile>? files;
//     if (_pickedImage != null) {
//       files = [await http.MultipartFile.fromPath('image', _pickedImage!.path)];
//     }

//     final endpoint =
//         _isEdit
//             ? 'food/custom-recipes/${widget.recipeId}'
//             : 'food/custom-recipes';

//     try {
//       await _api.postMultipart(endpoint, fields, files: files);
//       if (!mounted) return;
//       setState(() => _isSaving = false);
//       showToast(_isEdit ? 'Recipe updated' : 'Recipe created');
//       Navigator.pop(context, true);
//     } on ApiException catch (e) {
//       setState(() => _isSaving = false);
//       showToast(e.message);
//     } catch (e) {
//       setState(() => _isSaving = false);
//       showToast('Something went wrong. Please try again.');
//     }
//   }

//   // ─── UI helpers ───────────────────────────────────────────────────────────

//   Widget _label(String text) => Padding(
//     padding: const EdgeInsets.only(top: 16, bottom: 6),
//     child: SmallHeading(text),
//   );

//   Widget _foodRowWidget(int index) {
//     final row = _rows[index];
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: dividerColor),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Food selector ───────────────────────────────────────────────
//           Row(
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () => _openFoodSearch(index),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       color: backgroundColor(),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: dividerColor),
//                     ),
//                     child:
//                         row.loadingSizes
//                             ? const CupertinoActivityIndicator()
//                             : Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     // Shows title when prefilled, placeholder when empty
//                                     row.foodTitle.isNotEmpty
//                                         ? row.foodTitle
//                                         : 'Tap to select food',
//                                     style: TextStyle(
//                                       color:
//                                           row.foodTitle.isNotEmpty
//                                               ? textDark()
//                                               : textLightest(),
//                                       fontSize: 13,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.search,
//                                   color: textLightest(),
//                                   size: 16,
//                                 ),
//                               ],
//                             ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               GestureDetector(
//                 onTap: () {
//                   row.dispose();
//                   setState(() => _rows.removeAt(index));
//                 },
//                 child: const Icon(
//                   Icons.remove_circle_outline,
//                   color: Colors.red,
//                   size: 22,
//                 ),
//               ),
//             ],
//           ),

//           // ── Serving size (shown once food is set) ───────────────────────
//           if (row.foodId != null) ...[
//             const SizedBox(height: 10),
//             GestureDetector(
//               onTap: () async {
//                 List<FoodServingSize> sizes = row.availableSizes;
//                 if (sizes.isEmpty) {
//                   sizes = await _getServingSizes(row.foodId!);
//                 }
//                 if (sizes.isNotEmpty) {
//                   await _openServingSizePicker(index, sizes);
//                 } else {
//                   showToast('No serving sizes available');
//                 }
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 10,
//                 ),
//                 decoration: BoxDecoration(
//                   color: backgroundColor(),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color:
//                         row.servingSizeId == null
//                             ? Colors.orange
//                             : dividerColor,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         row.servingSizeLabel.isNotEmpty
//                             ? row.servingSizeLabel
//                             : 'Select serving size',
//                         style: TextStyle(
//                           color:
//                               row.servingSizeLabel.isNotEmpty
//                                   ? textDark()
//                                   : Colors.orange,
//                           fontSize: 13,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Icon(
//                       Icons.keyboard_arrow_down_outlined,
//                       color: textLightest(),
//                       size: 16,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Amount ───────────────────────────────────────────────────
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Text(
//                   'Amount:',
//                   style: TextStyle(color: textMedium(), fontSize: 13),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: CupertinoTextField(
//                     controller: row.amountCtrl,
//                     keyboardType: const TextInputType.numberWithOptions(
//                       decimal: true,
//                     ),
//                     placeholder: 'e.g. 1, 2.5, 30',
//                     onChanged: (v) => setState(() => row.amount = v),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: backgroundColor(),
//                       border: Border.all(color: dividerColor),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//                 if (row.servingSizeLabel.isNotEmpty) ...[
//                   const SizedBox(width: 8),
//                   Flexible(
//                     child: Text(
//                       '× ${row.servingSizeLabel}',
//                       style: TextStyle(color: textMedium(), fontSize: 11),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ],
//             ),

//             // ── Macro preview ─────────────────────────────────────────────
//             if (row.servingSizeId != null && row.availableSizes.isNotEmpty) ...[
//               Builder(
//                 builder: (_) {
//                   final match = row.availableSizes.where(
//                     (s) => s.id == row.servingSizeId,
//                   );
//                   if (match.isEmpty) return const SizedBox.shrink();
//                   final s = match.first;
//                   final qty = double.tryParse(row.amountCtrl.text) ?? 1.0;
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 6),
//                     child: Text(
//                       'Per amount → '
//                       'P ${(s.protein * qty).toStringAsFixed(1)}g · '
//                       'C ${(s.carbohydrate * qty).toStringAsFixed(1)}g · '
//                       'F ${(s.fat * qty).toStringAsFixed(1)}g · '
//                       '${(s.calorie * qty).toStringAsFixed(0)} kcal',
//                       style: TextStyle(
//                         color: primaryColor,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ],
//         ],
//       ),
//     );
//   }

//   // ─── Build ────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor(),
//       appBar: AppBar(
//         backgroundColor: backgroundColor(),
//         title: heading(
//           _isEdit ? (widget.recipeTitle ?? 'Edit recipe') : 'New custom recipe',
//         ),
//         actions: [
//           if (_isEdit)
//             IconButton(
//               icon: const Icon(Icons.delete_outline, color: Colors.red),
//               onPressed:
//                   () => showGenericDialog(
//                     context,
//                     'Delete recipe',
//                     'Are you sure you want to delete this recipe?',
//                     'Delete',
//                     () async {
//                       try {
//                         showLoadingDialog(context, 'Deleting...');
//                         await _api.deleteWithToken(
//                           'food/custom-recipes/${widget.recipeId}',
//                           {},
//                         );
//                         hideLoadingDialog(context);
//                         showToast('Recipe deleted');
//                         Navigator.pop(context, true);
//                       } catch (e) {
//                         hideLoadingDialog(context);
//                         showToast('Could not delete');
//                       }
//                     },
//                   ),
//             ),
//         ],
//       ),
//       bottomNavigationBar: SafeArea(
//         child: GestureDetector(
//           onTap: (_isSaving || _isLoadingRecipe) ? null : _save,
//           child: Container(
//             height: 52,
//             color: primaryColor,
//             alignment: Alignment.center,
//             child:
//                 (_isSaving || _isLoadingRecipe)
//                     ? const CupertinoActivityIndicator(color: white)
//                     : Text(
//                       _isEdit ? 'Save changes' : 'Create recipe',
//                       style: const TextStyle(
//                         color: white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//           ),
//         ),
//       ),
//       body:
//           _isLoadingRecipe
//               ? loader('Loading recipe...')
//               : GestureDetector(
//                 onTap: () => FocusScope.of(context).unfocus(),
//                 child: SingleChildScrollView(
//                   keyboardDismissBehavior:
//                       ScrollViewKeyboardDismissBehavior.onDrag,
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ── Image ─────────────────────────────────────────────
//                       GestureDetector(
//                         onTap: () async {
//                           final f = await _picker.pickImage(
//                             source: ImageSource.gallery,
//                             imageQuality: 60,
//                             maxWidth: 1024,
//                           );
//                           if (f != null) {
//                             setState(() => _pickedImage = File(f.path));
//                           }
//                         },
//                         child: Container(
//                           height: 150,
//                           width: double.infinity,
//                           clipBehavior: Clip.antiAlias,
//                           decoration: BoxDecoration(
//                             color: primaryColorLight,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: dividerColor),
//                           ),
//                           child:
//                               _pickedImage != null
//                                   ? Image.file(_pickedImage!, fit: BoxFit.cover)
//                                   : _existingImageUrl != null
//                                   ? Stack(
//                                     fit: StackFit.expand,
//                                     children: [
//                                       Image.network(
//                                         _existingImageUrl!,
//                                         fit: BoxFit.cover,
//                                       ),
//                                       Positioned(
//                                         bottom: 6,
//                                         right: 8,
//                                         child: Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 8,
//                                             vertical: 3,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: Colors.black54,
//                                             borderRadius: BorderRadius.circular(
//                                               6,
//                                             ),
//                                           ),
//                                           child: const Text(
//                                             'Tap to change',
//                                             style: TextStyle(
//                                               color: white,
//                                               fontSize: 11,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                   : Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Icon(
//                                         Icons.add_a_photo,
//                                         color: primaryColor,
//                                         size: 32,
//                                       ),
//                                       const SizedBox(height: 6),
//                                       Text(
//                                         'Add photo (optional)',
//                                         style: TextStyle(
//                                           color: textMedium(),
//                                           fontSize: 13,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                         ),
//                       ),

//                       // ── Title ──────────────────────────────────────────────
//                       _label('Title *'),
//                       CustomEditText(
//                         true,
//                         15,
//                         _titleCtrl,
//                         TextInputType.text,
//                         'Recipe name',
//                         width: double.infinity,
//                       ),

//                       // ── Category ───────────────────────────────────────────
//                       _label('Category *'),
//                       GestureDetector(
//                         onTap: () {
//                           if (_loadingCats || _categories.isEmpty) {
//                             showToast('Categories not loaded yet');
//                             return;
//                           }
//                           final labels =
//                               _categories.map((c) => c.label).toList();
//                           showPicker(context, (int i) {
//                             setState(() {
//                               _selectedCategoryValue = _categories[i].value;
//                               _selectedCategoryLabel = labels[i];
//                             });
//                           }, labels);
//                         },
//                         child: Container(
//                           height: 48,
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           decoration: BoxDecoration(
//                             color: white,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: dividerColor),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 _loadingCats
//                                     ? 'Loading...'
//                                     : _selectedCategoryLabel,
//                                 style: TextStyle(
//                                   color:
//                                       _selectedCategoryValue == null
//                                           ? textLightest()
//                                           : textDark(),
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.keyboard_arrow_down_outlined,
//                                 color: textLightest(),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // ── Active toggle ──────────────────────────────────────
//                       // const SizedBox(height: 16),
//                       // Row(
//                       //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       //   children: [
//                       //     Text(
//                       //       'Active',
//                       //       style: TextStyle(color: textDark(), fontSize: 15),
//                       //     ),
//                       //     CupertinoSwitch(
//                       //       value: _isActive,
//                       //       activeColor: primaryColor,
//                       //       onChanged: (v) => setState(() => _isActive = v),
//                       //     ),
//                       //   ],
//                       // ),

//                       // ── Text fields ────────────────────────────────────────
//                       _label('Description'),
//                       CustomEditText(
//                         true,
//                         14,
//                         _descCtrl,
//                         TextInputType.multiline,
//                         'Brief description',
//                         width: double.infinity,
//                       ),

//                       _label('Ingredients'),
//                       CustomEditText(
//                         true,
//                         14,
//                         _ingrCtrl,
//                         TextInputType.multiline,
//                         'List ingredients',
//                         width: double.infinity,
//                       ),

//                       _label('Instructions'),
//                       CustomEditText(
//                         true,
//                         14,
//                         _instrCtrl,
//                         TextInputType.multiline,
//                         'Step-by-step instructions',
//                         width: double.infinity,
//                       ),

//                       _label('Substitutions'),
//                       CustomEditText(
//                         true,
//                         14,
//                         _subCtrl,
//                         TextInputType.text,
//                         'Any substitutions',
//                         width: double.infinity,
//                       ),

//                       // ── Foods ──────────────────────────────────────────────
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           heading('Foods in this recipe'),
//                           TextButton.icon(
//                             onPressed:
//                                 () => setState(() => _rows.add(_FoodRow())),
//                             icon: const Icon(
//                               Icons.add,
//                               size: 16,
//                               color: primaryColor,
//                             ),
//                             label: const Text(
//                               'Add food',
//                               style: TextStyle(
//                                 color: primaryColor,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Select the food, then choose a serving size '
//                         '(e.g. "30 g" vs "1 oz"), then enter the amount.',
//                         style: TextStyle(color: textMedium(), fontSize: 12),
//                       ),
//                       const SizedBox(height: 10),
//                       if (_rows.isEmpty)
//                         GestureDetector(
//                           onTap: () => setState(() => _rows.add(_FoodRow())),
//                           child: Container(
//                             height: 48,
//                             decoration: BoxDecoration(
//                               border: Border.all(color: dividerColor),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             alignment: Alignment.center,
//                             child: Text(
//                               'Tap + Add food to start',
//                               style: TextStyle(
//                                 color: textLightest(),
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         )
//                       else
//                         Column(
//                           children: List.generate(
//                             _rows.length,
//                             (i) => _foodRowWidget(i),
//                           ),
//                         ),

//                       const SizedBox(height: 32),
//                     ],
//                   ),
//                 ),
//               ),
//     );
//   }
// }

// lib/Screens/CustomRecipes/custom_recipe_form_screen.dart

import 'dart:io';

import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/custom_recipe.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/app_popups.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// ─── Local data class for one food row in the form ────────────────────────────

class _FoodRow {
  int? foodId;
  String foodTitle = '';

  int? servingSizeId;
  // FIX: store measurement unit label (e.g. "gram", "fl oz", "cup")
  // instead of average_serving_size string
  String measurementUnitLabel = '';

  List<FoodServingSize> availableSizes = [];
  bool loadingSizes = false;

  String amount = '';
  final TextEditingController amountCtrl = TextEditingController();

  _FoodRow({
    this.foodId,
    this.foodTitle = '',
    this.servingSizeId,
    this.measurementUnitLabel = '',
    String amount = '',
  }) {
    this.amount = amount;
    amountCtrl.text = amount;
  }

  void dispose() => amountCtrl.dispose();
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class CustomRecipeFormScreen extends StatefulWidget {
  final int? recipeId;
  final String? recipeTitle;

  const CustomRecipeFormScreen({Key? key, this.recipeId, this.recipeTitle})
    : super(key: key);

  @override
  State<CustomRecipeFormScreen> createState() => _CustomRecipeFormScreenState();
}

class _CustomRecipeFormScreenState extends State<CustomRecipeFormScreen> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  bool get _isEdit => widget.recipeId != null;

  // ── Text controllers ──────────────────────────────────────────────────────
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ingrCtrl = TextEditingController();
  final _instrCtrl = TextEditingController();
  final _subCtrl = TextEditingController();

  bool _isActive = true;
  File? _pickedImage;
  String? _existingImageUrl;
  bool _isSaving = false;

  bool _isLoadingRecipe = false;

  // ── Category picker ───────────────────────────────────────────────────────
  List<ValueLabel> _categories = [];
  int? _selectedCategoryValue;
  String _selectedCategoryLabel = 'Select category';
  bool _loadingCats = false;

  // ── Food search data ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _allFoods = [];
  bool _loadingFoods = false;

  final Map<int, List<FoodServingSize>> _sizesCache = {};

  // ── Recipe food rows ──────────────────────────────────────────────────────
  final List<_FoodRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAllFoods().then((_) {
      if (_isEdit) _fetchAndPrefill();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _ingrCtrl.dispose();
    _instrCtrl.dispose();
    _subCtrl.dispose();
    for (final r in _rows) r.dispose();
    super.dispose();
  }

  // ─── Loaders ──────────────────────────────────────────────────────────────

  Future<void> _loadCategories() async {
    setState(() => _loadingCats = true);
    try {
      final raw = await _api.getWithToken(
        'food/custom-recipes/recipe-categories',
        {},
      );
      setState(() {
        _categories = ValueLabel.listFromResponse(raw);
        _loadingCats = false;
      });
    } catch (_) {
      setState(() => _loadingCats = false);
    }
  }

  Future<void> _loadAllFoods() async {
    setState(() => _loadingFoods = true);
    try {
      final dynamic raw = await _api.getWithToken(
        'food/category-with-foods',
        {},
      );
      final List<dynamic> topList = raw is List ? raw : [];
      final List<Map<String, dynamic>> flat = [];
      for (final cat in topList) {
        for (final child in (cat['child'] as List<dynamic>? ?? [])) {
          for (final variety in (child['varieties'] as List<dynamic>? ?? [])) {
            for (final food in (variety['foods'] as List<dynamic>? ?? [])) {
              flat.add({
                'id': food['id'],
                'title': food['title']?.toString() ?? '',
              });
            }
          }
        }
      }
      setState(() {
        _allFoods = flat;
        _loadingFoods = false;
      });
    } catch (_) {
      setState(() => _loadingFoods = false);
    }
  }

  Future<List<FoodServingSize>> _getServingSizes(int foodId) async {
    if (_sizesCache.containsKey(foodId)) return _sizesCache[foodId]!;
    try {
      final raw = await _api.getWithToken('food/foods/$foodId', {});
      // FIX: parse measurementUnit from serving_size_unit.unit
      final sizes = FoodServingSize.listFromFoodResponse(raw);
      _sizesCache[foodId] = sizes;
      return sizes;
    } catch (_) {
      return [];
    }
  }

  // ─── Fetch recipe detail and prefill (edit mode) ──────────────────────────

  Future<void> _fetchAndPrefill() async {
    setState(() => _isLoadingRecipe = true);
    try {
      final raw = await _api.getWithToken(
        'food/recipes/${widget.recipeId}',
        {},
      );

      _titleCtrl.text = raw['title']?.toString() ?? '';
      _descCtrl.text = raw['description']?.toString() ?? '';
      _ingrCtrl.text = raw['ingredients']?.toString() ?? '';
      _instrCtrl.text = raw['instructions']?.toString() ?? '';
      _subCtrl.text = raw['substitution']?.toString() ?? '';
      _isActive = raw['is_active']?.toString() == 'Yes';
      _existingImageUrl =
          raw['image_url']?.toString().isNotEmpty == true
              ? raw['image_url'].toString()
              : null;

      final catId = raw['category_id'] as int?;
      _selectedCategoryValue = catId;
      if (catId != null) {
        final match = _categories.where((c) => c.value == catId);
        _selectedCategoryLabel =
            match.isNotEmpty ? match.first.label : 'Category $catId';
      }

      final recipeFoods = raw['recipe_foods'] as List<dynamic>? ?? [];

      for (final f in recipeFoods) {
        final foodId = f['food_id'] as int?;
        final servingSizeId = f['food_serving_size_id'] as int?;

        // FIX: read food_amount directly from recipe_foods item
        final double amount = (f['food_amount'] ?? 1).toDouble();

        // Resolve food title
        final String foodTitle;
        if (foodId != null) {
          final match = _allFoods.where((fd) => fd['id'] == foodId);
          foodTitle =
              match.isNotEmpty
                  ? match.first['title'] as String
                  : 'Food #$foodId';
        } else {
          foodTitle = '';
        }

        final row = _FoodRow(
          foodId: foodId,
          foodTitle: foodTitle,
          servingSizeId: servingSizeId,
          amount:
              amount == amount.roundToDouble()
                  ? amount.toInt().toString()
                  : amount.toStringAsFixed(2),
        );
        _rows.add(row);
      }

      if (_rows.isEmpty) _rows.add(_FoodRow());

      setState(() => _isLoadingRecipe = false);

      // FIX: AFTER rendering rows, load full serving sizes for each food
      // This gives us:
      // 1. The correct measurementUnit label (from serving_size_unit.unit)
      // 2. The correct macros per unit for the calculation
      for (int i = 0; i < _rows.length; i++) {
        final row = _rows[i];
        if (row.foodId == null) continue;

        final sizes = await _getServingSizes(row.foodId!);
        if (!mounted) return;

        if (sizes.isNotEmpty) {
          // Find the selected size by ID
          final selectedSizes = sizes.where((s) => s.id == row.servingSizeId);

          setState(() {
            row.availableSizes = sizes;
            if (selectedSizes.isNotEmpty) {
              // FIX: set measurement unit label from the loaded size
              row.measurementUnitLabel =
                  selectedSizes.first.measurementUnit.isNotEmpty
                      ? selectedSizes.first.measurementUnit
                      : selectedSizes.first.averageServingSize;
            }
          });
        }
      }
    } catch (e) {
      setState(() => _isLoadingRecipe = false);
      showToast('Could not load recipe details');
    }
  }

  // ─── Food picker flow ─────────────────────────────────────────────────────

  Future<void> _openFoodSearch(int rowIndex) async {
    if (_loadingFoods) {
      showToast('Food list is loading, please wait');
      return;
    }
    final TextEditingController searchCtrl = TextEditingController();
    List<Map<String, dynamic>> filtered = List.from(_allFoods);

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor(),
      builder:
          (_) => StatefulBuilder(
            builder: (ctx, setSht) {
              void filter(String q) => setSht(() {
                filtered =
                    _allFoods
                        .where(
                          (f) => (f['title'] as String).toLowerCase().contains(
                            q.toLowerCase(),
                          ),
                        )
                        .toList();
              });

              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.85,
                builder:
                    (_, scroll) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: CupertinoTextField(
                            controller: searchCtrl,
                            placeholder: 'Search foods...',
                            onChanged: filter,
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
                        ),
                        Expanded(
                          child:
                              filtered.isEmpty
                                  ? Center(
                                    child: Text(
                                      'No foods found',
                                      style: TextStyle(color: textLightest()),
                                    ),
                                  )
                                  : ListView.builder(
                                    controller: scroll,
                                    itemCount: filtered.length,
                                    itemBuilder:
                                        (_, i) => ListTile(
                                          title: Text(
                                            filtered[i]['title'] as String,
                                            style: TextStyle(
                                              color: textDark(),
                                              fontSize: 14,
                                            ),
                                          ),
                                          onTap:
                                              () => Navigator.pop(
                                                ctx,
                                                filtered[i],
                                              ),
                                        ),
                                  ),
                        ),
                      ],
                    ),
              );
            },
          ),
    );

    if (selected == null) return;
    final foodId = selected['id'] as int;
    final foodTitle = selected['title'] as String;

    setState(() {
      _rows[rowIndex].foodId = foodId;
      _rows[rowIndex].foodTitle = foodTitle;
      _rows[rowIndex].servingSizeId = null;
      _rows[rowIndex].measurementUnitLabel = '';
      _rows[rowIndex].availableSizes = [];
      _rows[rowIndex].loadingSizes = true;
    });

    final sizes = await _getServingSizes(foodId);
    if (!mounted) return;
    setState(() => _rows[rowIndex].loadingSizes = false);

    if (sizes.isEmpty) {
      showToast('No serving sizes found for this food');
      return;
    }

    await _openMeasurementPicker(rowIndex, sizes);
  }

  // FIX: renamed from _openServingSizePicker → _openMeasurementPicker
  // and now shows serving_size_unit.unit as the label in the list
  Future<void> _openMeasurementPicker(
    int rowIndex,
    List<FoodServingSize> sizes,
  ) async {
    setState(() => _rows[rowIndex].availableSizes = sizes);

    await showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor(),
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    // FIX: title changed to "Select measurement"
                    'Select measurement for\n${_rows[rowIndex].foodTitle}',
                    style: TextStyle(
                      color: textDark(),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: sizes.length,
                    itemBuilder: (_, i) {
                      final s = sizes[i];
                      return ListTile(
                        title: Text(
                          // FIX: show measurementUnit (e.g. "gram", "fl oz")
                          // instead of averageServingSize
                          s.measurementUnit.isNotEmpty
                              ? s.measurementUnit
                              : s.averageServingSize,
                          style: TextStyle(color: textDark(), fontSize: 14),
                        ),
                        subtitle: Text(
                          'Avg. serving: ${s.averageServingSize}  ·  '
                          'P ${s.protein.toStringAsFixed(1)}g · '
                          'C ${s.carbohydrate.toStringAsFixed(1)}g · '
                          'F ${s.fat.toStringAsFixed(1)}g · '
                          '${s.calorie.toStringAsFixed(1)} kcal',
                          style: TextStyle(color: textMedium(), fontSize: 12),
                        ),
                        trailing:
                            _rows[rowIndex].servingSizeId == s.id
                                ? const Icon(Icons.check, color: primaryColor)
                                : null,
                        onTap: () {
                          setState(() {
                            _rows[rowIndex].servingSizeId = s.id;
                            // FIX: store measurement unit label
                            _rows[rowIndex].measurementUnitLabel =
                                s.measurementUnit.isNotEmpty
                                    ? s.measurementUnit
                                    : s.averageServingSize;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      showToast('Please enter a title');
      return;
    }
    if (_selectedCategoryValue == null) {
      showToast('Please select a category');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isSaving = true);

    final fields = <String, String>{
      'title': _titleCtrl.text.trim(),
      'category_id': _selectedCategoryValue.toString(),
      'description': _descCtrl.text.trim(),
      'ingredients': _ingrCtrl.text.trim(),
      'instructions': _instrCtrl.text.trim(),
      'substitution': _subCtrl.text.trim(),
      'is_active': _isActive ? 'Yes' : 'No',
    };

    int idx = 0;
    for (final row in _rows) {
      if (row.foodId == null || row.servingSizeId == null) continue;
      final amt = row.amountCtrl.text.trim();
      fields['recipe_foods[$idx][food_id]'] = row.foodId.toString();
      fields['recipe_foods[$idx][serving_unit_id]'] =
          row.servingSizeId.toString();
      fields['recipe_foods[$idx][amount]'] = amt.isEmpty ? '1' : amt;
      idx++;
    }

    List<http.MultipartFile>? files;
    if (_pickedImage != null) {
      files = [await http.MultipartFile.fromPath('image', _pickedImage!.path)];
    }

    final endpoint =
        _isEdit
            ? 'food/custom-recipes/${widget.recipeId}'
            : 'food/custom-recipes';

    try {
      await _api.postMultipart(endpoint, fields, files: files);
      if (!mounted) return;
      setState(() => _isSaving = false);
      showToast(_isEdit ? 'Recipe updated' : 'Recipe created');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _isSaving = false);
      showToast(e.message);
    } catch (e) {
      setState(() => _isSaving = false);
      showToast('Something went wrong. Please try again.');
    }
  }

  // ─── UI helpers ───────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: SmallHeading(text),
  );

  Widget _foodRowWidget(int index) {
    final row = _rows[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Food selector ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFoodSearch(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor(),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: dividerColor),
                    ),
                    child:
                        row.loadingSizes
                            ? const CupertinoActivityIndicator()
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    row.foodTitle.isNotEmpty
                                        ? row.foodTitle
                                        : 'Tap to select food',
                                    style: TextStyle(
                                      color:
                                          row.foodTitle.isNotEmpty
                                              ? textDark()
                                              : textLightest(),
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.search,
                                  color: textLightest(),
                                  size: 16,
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  row.dispose();
                  setState(() => _rows.removeAt(index));
                },
                child: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                  size: 22,
                ),
              ),
            ],
          ),

          // ── Measurement dropdown (shown once food is set) ───────────────
          if (row.foodId != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                List<FoodServingSize> sizes = row.availableSizes;
                if (sizes.isEmpty) {
                  sizes = await _getServingSizes(row.foodId!);
                }
                if (sizes.isNotEmpty) {
                  await _openMeasurementPicker(index, sizes);
                } else {
                  showToast('No measurements available');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor(),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    // FIX: orange border hint when not selected
                    color:
                        row.servingSizeId == null
                            ? Colors.orange
                            : dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        // FIX: show measurementUnitLabel, hint → "Select measurement"
                        row.measurementUnitLabel.isNotEmpty
                            ? row.measurementUnitLabel
                            : 'Select measurement',
                        style: TextStyle(
                          color:
                              row.measurementUnitLabel.isNotEmpty
                                  ? textDark()
                                  : Colors.orange,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: textLightest(),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            // ── FIX: Show Avg. serving after measurement is selected ────────
            if (row.servingSizeId != null && row.availableSizes.isNotEmpty)
              Builder(
                builder: (_) {
                  final match = row.availableSizes.where(
                    (s) => s.id == row.servingSizeId,
                  );
                  if (match.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Avg. serving: ${match.first.averageServingSize}',
                      style: TextStyle(color: textMedium(), fontSize: 12),
                    ),
                  );
                },
              ),

            // ── Amount ──────────────────────────────────────────────────
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Amount:',
                  style: TextStyle(color: textMedium(), fontSize: 13),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CupertinoTextField(
                    controller: row.amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    placeholder: 'e.g. 1, 2.5, 30',
                    onChanged: (v) => setState(() => row.amount = v),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor(),
                      border: Border.all(color: dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (row.measurementUnitLabel.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '× ${row.measurementUnitLabel}',
                      style: TextStyle(color: textMedium(), fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            // ── Macro preview ─────────────────────────────────────────────
            if (row.servingSizeId != null && row.availableSizes.isNotEmpty) ...[
              Builder(
                builder: (_) {
                  final match = row.availableSizes.where(
                    (s) => s.id == row.servingSizeId,
                  );
                  if (match.isEmpty) return const SizedBox.shrink();
                  final s = match.first;
                  final qty = double.tryParse(row.amountCtrl.text) ?? 1.0;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Per amount → '
                      'P ${(s.protein * qty).toStringAsFixed(1)}g · '
                      'C ${(s.carbohydrate * qty).toStringAsFixed(1)}g · '
                      'F ${(s.fat * qty).toStringAsFixed(1)}g · '
                      '${(s.calorie * qty).toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading(
          _isEdit ? (widget.recipeTitle ?? 'Edit recipe') : 'New custom recipe',
        ),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed:
                  () => showGenericDialog(
                    context,
                    'Delete recipe',
                    'Are you sure you want to delete this recipe?',
                    'Delete',
                    () async {
                      try {
                        showLoadingDialog(context, 'Deleting...');
                        await _api.deleteWithToken(
                          'food/custom-recipes/${widget.recipeId}',
                          {},
                        );
                        hideLoadingDialog(context);
                        showToast('Recipe deleted');
                        Navigator.pop(context, true);
                      } catch (e) {
                        hideLoadingDialog(context);
                        showToast('Could not delete');
                      }
                    },
                  ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: GestureDetector(
          onTap: (_isSaving || _isLoadingRecipe) ? null : _save,
          child: Container(
            height: 52,
            color: primaryColor,
            alignment: Alignment.center,
            child:
                (_isSaving || _isLoadingRecipe)
                    ? const CupertinoActivityIndicator(color: white)
                    : Text(
                      _isEdit ? 'Save changes' : 'Create recipe',
                      style: const TextStyle(
                        color: white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ),
      body:
          _isLoadingRecipe
              ? loader('Loading recipe...')
              : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Image ─────────────────────────────────────────────
                      GestureDetector(
                        onTap: () async {
                          final f = await _picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 60,
                            maxWidth: 1024,
                          );
                          if (f != null) {
                            setState(() => _pickedImage = File(f.path));
                          }
                        },
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: primaryColorLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: dividerColor),
                          ),
                          child:
                              _pickedImage != null
                                  ? Image.file(_pickedImage!, fit: BoxFit.cover)
                                  : _existingImageUrl != null
                                  ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        _existingImageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        bottom: 6,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            'Tap to change',
                                            style: TextStyle(
                                              color: white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_a_photo,
                                        color: primaryColor,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Add photo (optional)',
                                        style: TextStyle(
                                          color: textMedium(),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),

                      // ── Title ──────────────────────────────────────────────
                      _label('Title *'),
                      CustomEditText(
                        true,
                        15,
                        _titleCtrl,
                        TextInputType.text,
                        'Recipe name',
                        width: double.infinity,
                      ),

                      // ── Category ───────────────────────────────────────────
                      _label('Category *'),
                      GestureDetector(
                        onTap: () {
                          if (_loadingCats || _categories.isEmpty) {
                            showToast('Categories not loaded yet');
                            return;
                          }
                          final labels =
                              _categories.map((c) => c.label).toList();
                          showPicker(context, (int i) {
                            setState(() {
                              _selectedCategoryValue = _categories[i].value;
                              _selectedCategoryLabel = labels[i];
                            });
                          }, labels);
                        },
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: dividerColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _loadingCats
                                    ? 'Loading...'
                                    : _selectedCategoryLabel,
                                style: TextStyle(
                                  color:
                                      _selectedCategoryValue == null
                                          ? textLightest()
                                          : textDark(),
                                  fontSize: 14,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: textLightest(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Text fields ────────────────────────────────────────
                      _label('Description'),
                      CupertinoTextField(
                        controller: _descCtrl,
                        placeholder: 'Brief description',
                        keyboardType: TextInputType.multiline,
                        textInputAction:
                            TextInputAction.newline, // ← enables Return key
                        maxLines: null, // ← expands with content, no clipping
                        minLines:
                            4, // ← shows 4 lines minimum so it looks like a text area
                        padding: const EdgeInsets.all(12),
                        style: TextStyle(color: textDark(), fontSize: 14),
                        placeholderStyle: TextStyle(
                          color: textLightest(),
                          fontSize: 14,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: dividerColor),
                        ),
                      ),

                      // ── Ingredients ────────────────────────────────────────────
                      _label('Ingredients'),
                      CupertinoTextField(
                        controller: _ingrCtrl,
                        placeholder: 'List ingredients',
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        maxLines: null,
                        minLines: 4,
                        padding: const EdgeInsets.all(12),
                        style: TextStyle(color: textDark(), fontSize: 14),
                        placeholderStyle: TextStyle(
                          color: textLightest(),
                          fontSize: 14,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: dividerColor),
                        ),
                      ),

                      // ── Instructions ───────────────────────────────────────────
                      _label('Instructions'),
                      CupertinoTextField(
                        controller: _instrCtrl,
                        placeholder: 'Step-by-step instructions',
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        maxLines: null,
                        minLines: 4,
                        padding: const EdgeInsets.all(12),
                        style: TextStyle(color: textDark(), fontSize: 14),
                        placeholderStyle: TextStyle(
                          color: textLightest(),
                          fontSize: 14,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: dividerColor),
                        ),
                      ),

                      // ── Substitutions ──────────────────────────────────────────
                      _label('Substitutions'),
                      CupertinoTextField(
                        controller: _subCtrl,
                        placeholder: 'Any substitutions',
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        maxLines: null,
                        minLines: 3,
                        padding: const EdgeInsets.all(12),
                        style: TextStyle(color: textDark(), fontSize: 14),
                        placeholderStyle: TextStyle(
                          color: textLightest(),
                          fontSize: 14,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: dividerColor),
                        ),
                      ),

                      // ── FIX: "Manage foods and amounts" section ────────────
                      // Removed: "+ Add food" header button
                      // Removed: subtitle text below the heading
                      // Added: single "Tap to add food" button at the bottom
                      const SizedBox(height: 20),
                      heading('Manage foods and amounts'),
                      const SizedBox(height: 10),

                      // Existing food rows
                      if (_rows.isNotEmpty)
                        Column(
                          children: List.generate(
                            _rows.length,
                            (i) => _foodRowWidget(i),
                          ),
                        ),

                      // FIX: Single persistent "Tap to add food" button at the bottom
                      GestureDetector(
                        onTap: () => setState(() => _rows.add(_FoodRow())),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Tap to add food',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
    );
  }
}
