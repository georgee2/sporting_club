import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:fluttertoast/fluttertoast.dart';

class Validation {
  bool isValidImage(BuildContext context, File imageFile) {
    bool isValidImage = true;
    String basename = path.basename(imageFile.path);
    String extension = path.extension(basename);
    print(basename + '   ' + extension);
    if (extension.toLowerCase() == '.jpg' ||
        extension.toLowerCase() == '.png' ||
        extension.toLowerCase() == '.jpeg') {
      print(imageFile.lengthSync() / (1024 * 1024));
      if (imageFile.lengthSync() / (1024 * 1024) > 20) {
        Fluttertoast.showToast(
            msg: 'الحد الأقصى لحجم 20 ميغابايت',
            toastLength: Toast.LENGTH_LONG);
        isValidImage = false;
      }
    } else {
      Fluttertoast.showToast(
          msg: 'يرجى تحميل صورة png ، jpg ، jpeg فقط',
          toastLength: Toast.LENGTH_LONG);
      isValidImage = false;
    }
    return isValidImage;
  }

  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  bool isEmail(String email) {
    // String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    String p = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(email);
  }

  static String replaceArabicNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    final arabics = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabics[i]);
    }

    return input;
  }

  static bool isAdult(String birthDateString, int max_year) {
    String datePattern = "yyyy-mm-dd";
    DateTime birthDate = DateTime.now();

    if (birthDateString.isEmpty) {
      DateTime birthDate = DateTime.now();
    } else {
      birthDate = DateFormat(datePattern).parse(birthDateString);
    }
    DateTime today = DateTime.now();

    int yearDiff = today.year - birthDate.year;
    int monthDiff = today.month - birthDate.month;
    int dayDiff = today.day - birthDate.day;
    print("here${yearDiff}${max_year} ");

    return yearDiff >
        max_year; //za|| yearDiff == max_year && monthDiff >= 0 && dayDiff >= 0;
  }
}
