abstract class DateTimeEncoder {
  /// to seconds
  static double encode(DateTime datetime) {
    return datetime.millisecondsSinceEpoch / 1000.0;
  }

  /// from seconds
  static DateTime decode(double value) {
    return DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt());
  }
}
