import 'package:diet_maker/Models/login_response.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: darkText,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

void showToastLong(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 5,
    backgroundColor: darkText,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

String stringToDouble(String value) {
  return double.parse(value).toStringAsFixed(2);
}

DateTime utcToLocalTime(dynamic dateStr) {
  print(dateStr + '-- utcToLocalTime');
  try {
    var dateTime = DateFormat("yyyy-MM-dd HH:mm:ssZ").parse(dateStr, true);
    //return DateTime.parse(dateStr).toLocal();
    return dateTime.toLocal();
  } catch (e) {
    var dateTime = DateFormat("yyyy-MM-dd HH:mm").parse(dateStr, true);
    //return DateTime.parse(dateStr).toLocal();
    return dateTime.toLocal();
  }
}

String utcToLocalReadableTime(dynamic dateStr) {
  print(dateStr + '-- utcToLocalReadableTime');
  final DateFormat formatter = DateFormat('hh:MM a');
  final String formatted = formatter.format(utcToLocalTime(dateStr));
  return formatted;
}

String readableDate(dynamic dateStr) {
  //print(dateStr + '-- utcToLocalReadableDate');
  return DateFormat(
    "yyyy-MM-dd",
  ).format(DateFormat("yyyy-MM-dd hh:mm:ss").parse(dateStr.toString()));
}

String readableTime(dynamic dateStr) {
  return DateFormat(
    "hh:mm:ss a",
  ).format(DateFormat("yyyy-MM-dd hh:mm:ss").parse(dateStr));
  ;
}

String timeAgo(String dateStr) {
  DateTime todayDate = new DateTime.now();
  int milisecondsAgo =
      todayDate.toLocal().millisecondsSinceEpoch -
      utcToLocalTime(dateStr).toLocal().millisecondsSinceEpoch;
  int secondsAgo = (milisecondsAgo / 1000).round();
  int minute = 60;
  int hour = 60 * minute;
  int day = 24 * hour;
  int week = 7 * day;

  if (secondsAgo < minute) // seconds
  {
    return "just now";
  } else if (secondsAgo < hour) // minutes
  {
    if (secondsAgo / minute == 1) {
      return (secondsAgo / minute).toStringAsFixed(0) + "m ago";
    } else {
      return (secondsAgo / minute).toStringAsFixed(0) + "m ago";
    }
  } else if (secondsAgo < day) // hours
  {
    if (secondsAgo / hour == 1) {
      return (secondsAgo / hour).toStringAsFixed(0) + "h ago";
    } else {
      return (secondsAgo / hour).toStringAsFixed(0) + "h ago";
    }
  } else if (secondsAgo < week) // days
  {
    if (secondsAgo / day == 1) {
      return (secondsAgo / day).toStringAsFixed(0) + "d ago";
    } else {
      return (secondsAgo / day).toStringAsFixed(0) + "d ago";
    }
  }
  if (secondsAgo / week == 1) {
    return (secondsAgo / week).toStringAsFixed(0) + "w ago";
  } else {
    return (secondsAgo / week).toStringAsFixed(0) + "w ago";
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

formatedTime(int timeInSecond) {
  int sec = timeInSecond % 60;
  int min = (timeInSecond / 60).floor();
  String minute = min.toString().length <= 1 ? "0$min" : "$min";
  String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
  return "$minute : $second";
}

isEmail(String email) {
  return RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(email);
}

int calculateAge(DateTime birthDate) {
  DateTime today = DateTime.now();
  int age = today.year - birthDate.year;
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }

  return age;
}

dismissKeyboard(dynamic context) {
  FocusScope.of(context).unfocus();
}

bool isTabletView(dynamic context) {
  //var shortestSide = MediaQuery.of(context).size.shortestSide;
  var width = MediaQuery.of(context).size.width;

  return width > 600;
}

void showSnackBar(BuildContext context, String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: darkText,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

//

Future<String> getUserWeight(String measurementUnit) async {
  LoginResponse userDetail = (await StorageService.getLoginData())!;
  return measurementUnit.toLowerCase() == "imperial"
      ? userDetail.dietaryPreference.weightLbs.toString()
      : userDetail.dietaryPreference.weightKg.toString();
}

Future<String> getUserHeight(String measurementUnit) async {
  LoginResponse userDetail = (await StorageService.getLoginData())!;
  return measurementUnit.toLowerCase() == "imperial"
      ? userDetail.dietaryPreference.heightFeet.toString()
      : userDetail.dietaryPreference.heightCm.toString();
}

bool isFutureDate(String dateString) {
  // Parse the date string into a DateTime object.
  // The format 'yyyy-MM-dd' is required for the parser.
  DateTime selectedDate = DateFormat('yyyy-MM-dd').parse(dateString);

  // Get today's date and normalize it to midnight to ignore the time component.
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);

  // Return true if the selected date is after today.
  return selectedDate.isAfter(today);
}
