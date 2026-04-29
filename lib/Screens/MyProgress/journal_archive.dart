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

class JournalArchive extends StatefulWidget {
  const JournalArchive({super.key});

  @override
  State<JournalArchive> createState() => _JournalArchiveState();
}

class _JournalArchiveState extends State<JournalArchive> {
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
        if (journal.isEmpty) {
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

            if (journalNote != null) ...[
              const SizedBox(height: 8),
              heading("Journal:"),
              Text(journalNote),
            ],

            // if (photos.isNotEmpty) ...[
            //   const SizedBox(height: 12),
            //   GridView.builder(
            //     shrinkWrap: true,
            //     physics: const NeverScrollableScrollPhysics(),
            //     itemCount: photos.length,
            //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //       crossAxisCount: 2,
            //       crossAxisSpacing: 8,
            //       mainAxisSpacing: 8,
            //     ),
            //     itemBuilder: (context, index) {
            //       final photo = photos[index];
            //       return ClipRRect(
            //         borderRadius: BorderRadius.circular(8),
            //         child: Image.network(photo['photo_url'], fit: BoxFit.cover),
            //       );
            //     },
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}
