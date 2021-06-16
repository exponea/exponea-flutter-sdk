abstract class DurationEncoder {
  /// from sec
  static Duration decode(int data) {
    return Duration(
      seconds: data,
    );
  }

  /// to sec
  static int encode(Duration duration) {
    return duration.inSeconds;
  }
}
