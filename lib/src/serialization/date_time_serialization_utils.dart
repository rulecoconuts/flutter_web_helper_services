import 'package:intl/intl.dart';

class DateTimeSerializationUtils {
  static DateTime? removeZFromTimeString(String? json) {
    if (json == null) return null;
    return DateTime.parse(json!.replaceAll("Z", ""));
  }

  static String? convertTimeToZonedDateTimeString(DateTime? dateTime) {
    if (dateTime == null) return null;

    return dateTime.toUtc().toIso8601String().replaceAll("+0000", "") + "+0000";
  }

  /// Remove zoneid and return a [DateTime] in Local timezone
  static DateTime? dateStringToLocal(String? json) {
    if (json == null) return null;
    int indexOfPlus = json.indexOf("+");
    if (indexOfPlus == -1) return DateTime.parse(json).toLocal();
    return DateTime.parse(json.substring(0, indexOfPlus)).toLocal();
  }

  /// Convert [DateTime] to UTC datetime string
  static String? toUTCString(DateTime? dateTime) {
    if (dateTime == null) return null;
    String dateString =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(dateTime.toUtc());
    if (dateString.contains("+")) return dateString;
    return "$dateString+0000";
  }
}
