import 'dart:ui';
import 'package:diet_maker/utils/globals.dart';

const primaryColor = Color(0xFFFC7544);
const primaryColorLight = Color(0xFFFFE2D8);
const primaryColorPlaceholder = Color(0x90D92768);
const primaryColorTransparent = Color(0x20D92768);
//const primaryAccentTransparent = Color(0x80A2AFCF);

const secondryColor = Color.fromARGB(255, 243, 143, 112);
const backgroundDark = Color(0xFF181818);
const backgroundDark2 = Color(0xFF232323);
const backgroundLight = Color(0xFFF0E9E6);
const formBackground = Color(0xFFD7DAE1);

//
const highlightColor = Color(0x50DB372B);

//
const primaryAccent = Color.fromARGB(255, 250, 212, 219);

const appBarDark = primaryColor;
const white = Color(0xffffffff);
const background = Color(0xFFf8f8f8);
const errorColor = Color(0xffE23744);
//const darkBackground = Color(0xFFeeeeee);

const darkText = Color(0xFF232323);
const lightText = Color(0xFF545454);
const lightestText = Color(0xFF808080);
const darkLightText = Color(0xffc8c8c8);
const darkLightestText = Color(0xffaaaaaa);
const transparent = Color(0x00000000);
const transparentWhite = Color(0x30ffffff);
const transparentBlack = Color(0xa0000000);
const transparentBlack2 = Color(0x40000000);
const transparentBlackDark = Color(0xef000000);
const dividerColor = Color(0xffd8d8d8);

const darkAppBar = Color.fromARGB(255, 18, 18, 18);
const darkBackground = Color(0xFF151515);
const darkBackgroundTransparent = Color.fromARGB(174, 33, 33, 33);
const playerBackground = Color.fromARGB(255, 33, 69, 141);
const smallPlayerSecondry = Color.fromARGB(255, 123, 146, 136);
const lightBlue = Color.fromARGB(255, 185, 221, 248);
const smallPlayerSecondryTransparent = Color.fromARGB(64, 162, 142, 117);
const darkHeading = Color(0xFFACB6C7);

//Rating Colors
const one = Color(0xffE23744);
const two = Color(0xffFF7800);
const three = Color(0xffCDD614);
const four = Color(0xff91CB60);
const five = Color(0xff39B549);
const darkBlue = Color(0xff141B36);

//nutrients
const protien = Color(0xffAFF49B);
const carbs = Color(0xff2ADCAA);
const fats = Color(0xff00B3B6);
const calories = Color(0xff0088AF);

dynamic ratingColor(double rating) {
  dynamic ratingColor;
  double ratingDouble = rating;
  if (ratingDouble == 5)
    ratingColor = five;
  else if (ratingDouble >= 4)
    ratingColor = four;
  else if (ratingDouble >= 3)
    ratingColor = three;
  else if (ratingDouble >= 2)
    ratingColor = two;
  else
    ratingColor = one;

  return ratingColor;
}

Color backgroundColor() {
  return isDarkTheme ? darkBackground : backgroundLight;
}

Color lightBackgroundColor() {
  return isDarkTheme ? Color(0xFF252525) : Color(0xFFf8f8f8);
}

Color darkBackgroundColor() {
  return Color(0xff110436);
}

Color textLightest() {
  return isDarkTheme ? darkLightestText : lightestText;
}

Color textMedium() {
  return isDarkTheme ? darkLightText : lightText;
}

Color textDark() {
  return isDarkTheme ? white : darkText;
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
