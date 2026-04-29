// import 'package:diet_maker/Exception/api_exception.dart';
// import 'package:diet_maker/Models/login_response.dart';
// import 'package:diet_maker/services/api_service.dart';
// import 'package:diet_maker/services/storage_service.dart';
// import 'package:diet_maker/utils/api_endpoints.dart';
// import 'package:diet_maker/utils/app_helpers.dart';
// import 'package:diet_maker/widgets/full_size_image.dart';
// import 'package:diet_maker/widgets/loading_image.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ComparePhotosScreen extends StatefulWidget {
//   const ComparePhotosScreen({Key? key}) : super(key: key);

//   @override
//   State<ComparePhotosScreen> createState() => _ComparePhotosScreenState();
// }

// class _ComparePhotosScreenState extends State<ComparePhotosScreen> {
//   DateTime? startDate;
//   DateTime? endDate;

//   bool isLoading = false;
//   List<dynamic> compareData = [];

//   Future<void> pickStartDate() async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().subtract(Duration(days: 7)),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );

//     if (picked != null) {
//       setState(() => startDate = picked);
//       if (endDate != null) fetchComparePhotos();
//     }
//   }

//   Future<void> pickEndDate() async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );

//     if (picked != null) {
//       setState(() => endDate = picked);
//       if (startDate != null) fetchComparePhotos();
//     }
//   }

//   Future<void> fetchComparePhotos() async {
//     setState(() => isLoading = true);

//     // Get dietary prefs from saved login data
//     LoginResponse userDetail = (await StorageService.getLoginData())!;
//     int dietaryPrefs = userDetail.dietaryPreference.id;

//     final start = DateFormat("yyyy-MM-dd").format(startDate!);
//     final end = DateFormat("yyyy-MM-dd").format(endDate!);

//     FocusManager.instance.primaryFocus?.unfocus();
//     final ApiService apiService = ApiService();

//     String parameters =
//         "?dietary_preference_id=$dietaryPrefs&period=custom" +
//         "&start_date=" +
//         start +
//         "&end_date=" +
//         end;

//     try {
//       setState(() => isLoading = true);
//       compareData = await apiService.getWithToken(
//         getComparePhotos + parameters,
//         {},
//       );

//       setState(() => isLoading = false);
//     } catch (e) {
//       if (e is ApiException) {
//         showToast(e.message.toString());
//         print(
//           "API Error: ${e.message}, status: ${e.code}, Details: ${e.errorBody}",
//         );
//       } else {
//         print("Unexpected error: $e");
//       }
//       setState(() => isLoading = false);
//     }
//   }

//   Widget buildPhotoItem(String type, String url) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => FullImageView(imageUrl: url)),
//         );
//       },
//       child: Column(
//         children: [
//           Text(type, style: TextStyle(fontSize: 12)),
//           SizedBox(height: 5),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Container(width: 85, height: 110, child: LoadingImage(url)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           // 🔹  Date Pickers Row
//           Container(
//             padding: EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: pickStartDate,
//                     child: Container(
//                       padding: EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: Text(
//                         startDate != null
//                             ? "From: ${DateFormat('dd MMM yyyy').format(startDate!)}"
//                             : "Select Start Date",
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: pickEndDate,
//                     child: Container(
//                       padding: EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: Text(
//                         endDate != null
//                             ? "To: ${DateFormat('dd MMM yyyy').format(endDate!)}"
//                             : "Select End Date",
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // 🔹 Loading
//           if (isLoading)
//             Expanded(child: Center(child: CircularProgressIndicator()))
//           // 🔹 Data
//           else if (compareData.isNotEmpty)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: compareData.length,
//                 itemBuilder: (context, index) {
//                   var day = compareData[index];
//                   var photos = day["photos"] as List;

//                   return Card(
//                     margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     child: Padding(
//                       padding: EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             day["date"],
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           SizedBox(height: 10),

//                           // If no photos
//                           if (photos.isEmpty)
//                             Text(
//                               "No photos uploaded",
//                               style: TextStyle(color: Colors.grey),
//                             )
//                           else
//                             Wrap(
//                               spacing: 15,
//                               runSpacing: 15,
//                               children:
//                                   photos
//                                       .map(
//                                         (p) => buildPhotoItem(
//                                           p["type"],
//                                           p["photo_url"],
//                                         ),
//                                       )
//                                       .toList(),
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             )
//           else
//             Expanded(
//               child: Center(child: Text("Pick date range to view photos.")),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComparePhotosScreen extends StatefulWidget {
  const ComparePhotosScreen({super.key});

  @override
  State<ComparePhotosScreen> createState() => _ComparePhotosScreenState();
}

class _ComparePhotosScreenState extends State<ComparePhotosScreen> {
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;

  Map<String, dynamic>? compareData;

  /// ---------------- DATE PICKERS ----------------

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  /// ---------------- API CALL (YOUR EXACT LOGIC) ----------------

  Future<void> fetchComparePhotos() async {
    if (startDate == null || endDate == null) return;

    setState(() => isLoading = true);

    LoginResponse userDetail = (await StorageService.getLoginData())!;
    int dietaryPrefs = userDetail.dietaryPreference.id;

    final start = DateFormat("yyyy-MM-dd").format(startDate!);
    final end = DateFormat("yyyy-MM-dd").format(endDate!);

    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    String parameters =
        "?dietary_preference_id=$dietaryPrefs&period=custom"
        "&start_date=$start"
        "&end_date=$end";

    try {
      compareData = await apiService.getWithToken(
        getAdherenceLogs + parameters,
        {},
      );
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
      }
    }

    setState(() => isLoading = false);
  }

  /// ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("Compare Photos")),
      body: Column(
        children: [
          _datePickerSection(),
          const Divider(),
          Expanded(child: _contentSection()),
        ],
      ),
    );
  }

  /// ---------------- DATE PICKER UI ----------------

  Widget _datePickerSection() {
    return Container(
      color: lightBackgroundColor(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: _dateButton(
                  label: "Start Date",
                  date: startDate,
                  onTap: _pickStartDate,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _dateButton(
                  label: "End Date",
                  date: endDate,
                  onTap: _pickEndDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: fetchComparePhotos,
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  Widget _dateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11)),
            //const SizedBox(width: 15),
            Text(
              date == null ? "Select" : DateFormat("MMM dd, yyyy").format(date),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- DATA RENDERING ----------------

  Widget _contentSection() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (compareData == null ||
        compareData!['list'] == null ||
        compareData!['list'].isEmpty) {
      return const Center(child: Text("No data found"));
    }

    final List list = compareData!['list'];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final log = item['log'];
        final journal = log['log_journal'];
        final photos = log['log_photos'] as List;
        if (photos.isEmpty) {
          return Container();
        }
        return _dateCard(
          date: log['log_date_formatted'],
          journalNote:
              journal is Map && journal.isNotEmpty ? journal['note'] : null,
          photos: photos,
        );
      },
    );
  }

  /// ---------------- DATE CARD ----------------

  Widget _dateCard({
    required String date,
    String? journalNote,
    required List photos,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            // if (journalNote != null) ...[
            //   const SizedBox(height: 8),
            //   heading("Journal:"),
            //   Text(journalNote),
            // ],
            if (photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: photos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(photo['photo_url'], fit: BoxFit.cover),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
