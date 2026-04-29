import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeRangeSelector extends StatefulWidget {
  final ValueChanged<Map<String, String>> onDateRangeSelected;
  final Color highlightColor;

  const TimeRangeSelector({
    super.key,
    required this.onDateRangeSelected,
    this.highlightColor = primaryColor,
  });

  @override
  State<TimeRangeSelector> createState() => _TimeRangeSelectorState();
}

class _TimeRangeSelectorState extends State<TimeRangeSelector> {
  String _selectedRange = '1 Month';
  final DateTime now = DateTime.now();

  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _updateDateRange(_selectedRange);
  }

  Future<void> _updateDateRange(String range) async {
    DateTime endDate = DateTime(now.year, now.month, now.day);
    DateTime startDate;

    if (range == 'Set Range') {
      final pickedRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 5),
        lastDate: DateTime(now.year + 1),
        initialDateRange:
            _customStartDate != null && _customEndDate != null
                ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
                : null,
      );

      if (pickedRange == null) return;

      setState(() {
        _selectedRange = range;
        _customStartDate = pickedRange.start;
        _customEndDate = pickedRange.end;
      });

      widget.onDateRangeSelected({
        'startDate': DateFormat('yyyy-MM-dd').format(pickedRange.start),
        'endDate': DateFormat('yyyy-MM-dd').format(pickedRange.end),
      });
      return;
    }

    setState(() {
      _selectedRange = range;
    });

    switch (range) {
      case '1 Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3 Month':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case '6 Month':
        startDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case '1 Year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = endDate;
    }

    widget.onDateRangeSelected({
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
    });
  }

  Widget _buildRangeButton(String text) {
    final bool isSelected = _selectedRange == text;

    return Expanded(
      child: InkWell(
        onTap: () => _updateDateRange(text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? widget.highlightColor : Colors.transparent,
            borderRadius:
                isSelected ? BorderRadius.circular(8) : BorderRadius.zero,
            border: Border.all(
              color: isSelected ? widget.highlightColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Text(
            text.replaceAll(" ", "\n"),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              _buildRangeButton('1 Month'),
              _buildRangeButton('3 Month'),
              _buildRangeButton('6 Month'),
              _buildRangeButton('1 Year'),
              _buildRangeButton('Set Range'),
            ],
          ),
        ),

        /// Custom date range display
        if (_selectedRange == 'Set Range' &&
            _customStartDate != null &&
            _customEndDate != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Selected: '
              '${DateFormat('dd MMM yyyy').format(_customStartDate!)}'
              ' – '
              '${DateFormat('dd MMM yyyy').format(_customEndDate!)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
      ],
    );
  }
}
