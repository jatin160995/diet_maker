import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/utils/design_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

selectDate(
  BuildContext context,
  Function onChange, {
  String? initialDateString,
}) async {
  final DateTime today = DateTime.now();

  // 1. Define bounds
  final DateTime minAllowedDate = DateTime(today.year - 100);
  final DateTime maxAllowedDate = DateTime(
    today.year - 18,
    today.month,
    today.day,
  );

  // 2. Determine initial date
  DateTime initialDate;
  if (initialDateString != null && initialDateString.isNotEmpty) {
    try {
      // Parse "2002-11-03" -> DateTime
      initialDate = DateTime.parse(initialDateString);

      // Safety check: ensure the parsed date is within the valid range
      if (initialDate.isAfter(maxAllowedDate)) {
        initialDate = maxAllowedDate;
      } else if (initialDate.isBefore(minAllowedDate)) {
        initialDate = minAllowedDate;
      }
    } catch (e) {
      // Fallback if parsing fails
      initialDate = maxAllowedDate;
    }
  } else {
    // Default to 18 years ago if no date string provided
    initialDate = maxAllowedDate;
  }

  showCupertinoModalPopup(
    context: context,
    builder:
        (BuildContext context) => Container(
          width: double.infinity,
          color: Colors.white,
          child: SizedBox(
            height: 250,
            width: double.infinity,
            child: CupertinoDatePicker(
              backgroundColor: Colors.white,
              initialDateTime: initialDate, // Use the determined date
              minimumDate: minAllowedDate,
              maximumDate: maxAllowedDate,
              onDateTimeChanged: (DateTime newTime) {
                onChange(newTime);
              },
              use24hFormat: true,
              mode: CupertinoDatePickerMode.date,
            ),
          ),
        ),
  );
}

void showPicker(BuildContext context, Function onChange, List<String> data) {
  int selectedIndex = 0;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return SizedBox(
        height: 250,
        child: Column(
          children: [
            // Done button bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onChange(selectedIndex);
                },
                child: Text("Done", style: TextStyle(fontSize: 16)),
              ),
            ),
            // Picker
            Expanded(
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                magnification: 1,
                itemExtent: 32.0,
                scrollController: FixedExtentScrollController(initialItem: 0),
                onSelectedItemChanged: (value) {
                  onChange(value);
                  selectedIndex = value;
                },
                children:
                    data
                        .map(
                          (item) => Text(
                            item,
                            style: TextStyle(
                              fontSize: 17,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showDecimalPicker(
  BuildContext context,
  Function(String) onSelected,
  int mainInitial,
  int mainEnd,
  int decimalEnd,
) {
  int selectedInt = mainInitial; // default value
  int selectedDecimal = 0;

  List<String> intPart = List.generate(
    mainEnd,
    (i) => (mainInitial + i).toString(),
  ); // 100 - 220
  List<String> decimalPart = List.generate(
    decimalEnd,
    (i) => i.toString(),
  ); // 0 - 9

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return SizedBox(
        height: 250,
        child: Column(
          children: [
            // Done Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  String height = "$selectedInt.$selectedDecimal";
                  onSelected(height);
                },
                child: Text("Done", style: TextStyle(fontSize: 16)),
              ),
            ),
            // Two pickers side by side
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Integer Part Picker
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedInt - 100,
                      ),
                      itemExtent: 32.0,
                      onSelectedItemChanged: (index) {
                        selectedInt = int.parse(intPart[index]);
                      },
                      children:
                          intPart.map((e) => Center(child: Text(e))).toList(),
                    ),
                  ),
                  // Dot Separator
                  Container(
                    alignment: Alignment.center,
                    child: Text('.', style: TextStyle(fontSize: 24)),
                  ),
                  // Decimal Part Picker
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedDecimal,
                      ),
                      itemExtent: 32.0,
                      onSelectedItemChanged: (index) {
                        selectedDecimal = int.parse(decimalPart[index]);
                      },
                      children:
                          decimalPart
                              .map((e) => Center(child: Text(e)))
                              .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showLoadingDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 16.0),
            Text(
              message,
              style: TextStyle(
                color: textDark(),
                fontSize: 16,
                fontFamily: "medium",
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showWarningDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info, color: Colors.amber, size: 50),
            Text(
              message,
              style: TextStyle(
                color: textDark(),
                fontSize: 18,
                fontFamily: "medium",
              ),
            ),
          ],
        ),
      );
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context).pop();
}

Future<void> showGenericDialog(
  BuildContext context,
  String title,
  String text,
  String buttonText,
  VoidCallback onConfirm,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Wrap(children: [Text(text)]),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),

        actions: <Widget>[
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: darkText)),
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
          ),
          ElevatedButton(
            child: Text(buttonText, style: TextStyle(color: white)),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog first
              onConfirm(); // Call the logout logic
            },
          ),
        ],
      );
    },
  );
}

Future<void> infoDialog(
  BuildContext context,
  String title,
  Widget design,
  //VoidCallback onConfirm,
) async {
  return showDialog<void>(
    context: context,

    //barrierDismissible: false, // User must tap a button
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Container(
          //color: primaryColor,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Wrap(children: [design]),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),

        actions: <Widget>[
          TextButton(
            child: const Text('Okay', style: TextStyle(color: darkText)),
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
          ),
          // ElevatedButton(
          //   child: Text(buttonText, style: TextStyle(color: white)),
          //   style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          //   onPressed: () {
          //     Navigator.of(context).pop(); // Close dialog first
          //     onConfirm(); // Call the logout logic
          //   },
          // ),
        ],
      );
    },
  );
}
