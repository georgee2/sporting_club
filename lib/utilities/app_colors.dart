import 'package:flutter/material.dart';

class AppColors {


  static const darkRed = Color(0xffc00d0d);
  static const lightGreen = Color(0xff8abb2b);
  static const green = Color(0xff43a047);
  static const extraLightGrey = Color(0xffdddddd);
  static const offWhite = Color(0xfffafafa);
  static const lightGrey = Color(0xff8b8b8b);
  static const black = Color(0xff3b3d3f);
  static const darkGreen = Color(0xff00701a);
  static const mediumGreen = Color(0xffff5c46);
  static const errorsRed = Color(0xffbb0101);
  static const darkGrey = Color(0xff03240a);
  static const mediumOrange = Color(0xffe95d00);
  static const dividerGrey = Color(0xff707070);
  static const cardBorder = Color(0xffD9D9D9);
  static const ghostWhite = Color(0xfff4f4f5);
  static const lightSilverColor = Color(0xffD8D8D8);
  static const white = Color(0xffffffff);
  static const subtitleColor = Color(0xff858585);
  static const datePickerColor = Color(0xffE4E4E4);
  static const silverColor = Color(0xffB2B2B2);
  static const meduimGrey = Color(0xff646464);
  static const mapCircle = Color(0x4DFF5C46);
  static const mapStationCircle = Color(0x76D2754D);
  static const stationCircleColor = Color(0xff76D275);
  static const skippedStationCircleColor = Color(0xffB2B2B2);
}
  extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

