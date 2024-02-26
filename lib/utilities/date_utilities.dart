import 'package:intl/intl.dart';

class DateUtilities {

  static String dateTimeFormat(DateTime dateTime, {String? format, String? locale}) {
    if (dateTime == null) return "";
    String dateFormat =
    DateFormat(format ?? "dd-MM-yyy hh:mma", locale ?? "ar").format(dateTime);
    return dateFormat;
  }

  static String convertFormat(String date,String oldFormat,String newFormat) {
    try {
      DateTime oldDate = DateFormat(oldFormat).parse(date);
      String newDate = DateFormat(newFormat).format(oldDate);
      return newDate;
    }catch(e){
      return date;
    }
  }
}
extension DatesComparison on DateTime {
  bool isAtSameDay(DateTime otherDate) {
    return year == otherDate.year &&
        month == otherDate.month &&
        day == otherDate.day;
  }

  bool isAtOldDay(DateTime otherDate) {
    return year < otherDate.year ||
        month < otherDate.month ||
        day < otherDate.day;
  }
}
