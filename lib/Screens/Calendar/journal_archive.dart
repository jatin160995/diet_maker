import 'package:diet_maker/Screens/MyProgress/ChartWidgets/time_range_selector.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:diet_maker/widgets/full_size_image.dart';
import 'package:diet_maker/widgets/loading_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/color_utils.dart';

class JournalArchiveScreen extends StatefulWidget {
  const JournalArchiveScreen({super.key});

  @override
  State<JournalArchiveScreen> createState() => _JournalArchiveScreenState();
}

class _JournalArchiveScreenState extends State<JournalArchiveScreen> {
  bool isLoading = false;
  Map<String, dynamic>? archiveData;

  DateTime? startDate;
  DateTime? endDate;

  String startDateString = '';
  String endDateString = '';

  int selectedDietaryPrefId = 0;
  final DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    startDateString = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(now.year, now.month, now.day));
    endDateString = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(now.year, now.month - 1, now.day));
    _loadDietaryPref();
  }

  Future<void> _loadDietaryPref() async {
    final login = await StorageService.getLoginData();
    selectedDietaryPrefId = login!.dietaryPreference.id;
    _getJournalArchive();
  }

  Future<void> _getJournalArchive() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ApiService apiService = ApiService();

    try {
      setState(() => isLoading = true);

      String params =
          "?dietary_preference_id=$selectedDietaryPrefId"
          "&period=custom"
          "&start_date=$startDateString"
          "&end_date=$endDateString";

      final data = await apiService.getWithToken(getAdherenceLogs + params, {});

      setState(() {
        archiveData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showToast("Failed to load journal archive");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor(),
        title: heading("Journal Archive"),
      ),
      //appBar: AppBar(title: const Text("Journal Archive")),
      body: Column(
        children: [
          /// DATE RANGE SELECTOR
          TimeRangeSelector(
            onDateRangeSelected: (range) {
              startDateString = range['startDate']!;
              endDateString = range['endDate']!;
              _getJournalArchive();
            },
          ),

          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildArchiveList(),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveList() {
    if (archiveData == null || archiveData!['list'].isEmpty) {
      return const Center(child: Text("No journal entries found"));
    }

    final List list = archiveData!['list'];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final log = item['log'];
        final journal = log['log_journal'];
        final photos = log['log_photos'] as List;

        final bool hasJournal = journal != null && journal.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasJournal ? primaryColor.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasJournal ? primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// DATE HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    log['log_date_formatted'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasJournal ? primaryColor : textDark(),
                    ),
                  ),
                  if (hasJournal)
                    const Icon(Icons.bookmark, color: primaryColor),
                ],
              ),

              const SizedBox(height: 10),

              /// JOURNAL NOTE
              if (hasJournal)
                Text(
                  journal['note'],
                  style: TextStyle(fontSize: 14, color: textDark()),
                ),

              /// PHOTOS
              if (photos.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => FullImageView(
                                    imageUrl: photos[i]['photo_url'],
                                  ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LoadingImage(photos[i]['photo_url']),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
