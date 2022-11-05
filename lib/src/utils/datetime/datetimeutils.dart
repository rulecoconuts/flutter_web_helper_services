class DateTimeUtils {
  static DateTime? removeZFromTimeString(String? json) {
    if (json == null) return null;
    return DateTime.parse(json!.replaceAll("Z", ""));
  }
}
