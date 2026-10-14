enum SdkLogLevel {
  verbose,
  debug,
  info,
  warn,
  error;

  static SdkLogLevel parse(String value) {
    switch (value.trim().toLowerCase()) {
      case 'v':
      case 'verbose':
        return SdkLogLevel.verbose;
      case 'd':
      case 'debug':
        return SdkLogLevel.debug;
      case 'i':
      case 'info':
        return SdkLogLevel.info;
      case 'w':
      case 'warn':
      case 'warning':
        return SdkLogLevel.warn;
      case 'e':
      case 'error':
        return SdkLogLevel.error;
      default:
        return SdkLogLevel.info;
    }
  }

  String get shortLabel => switch (this) {
        SdkLogLevel.verbose => 'V',
        SdkLogLevel.debug => 'D',
        SdkLogLevel.info => 'I',
        SdkLogLevel.warn => 'W',
        SdkLogLevel.error => 'E',
      };
}

enum SdkLogFilter {
  all,
  verbose,
  debug,
  info,
  warn,
  error;

  bool matches(SdkLogLevel level) {
    return switch (this) {
      SdkLogFilter.all => true,
      SdkLogFilter.verbose => level == SdkLogLevel.verbose,
      SdkLogFilter.debug => level == SdkLogLevel.debug,
      SdkLogFilter.info => level == SdkLogLevel.info,
      SdkLogFilter.warn => level == SdkLogLevel.warn,
      SdkLogFilter.error => level == SdkLogLevel.error,
    };
  }
}

class LogRecord {
  const LogRecord({
    required this.time,
    required this.level,
    required this.tag,
    required this.message,
  });

  final DateTime time;
  final SdkLogLevel level;
  final String tag;
  final String message;

  factory LogRecord.fromMap(Map<dynamic, dynamic> map) {
    return LogRecord(
      time: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      level: SdkLogLevel.parse(map['level']?.toString() ?? 'info'),
      tag: map['tag']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
    );
  }
}

class DisplayLogEntry {
  const DisplayLogEntry({
    required this.time,
    required this.level,
    required this.tag,
    required this.message,
  });

  final DateTime time;
  final SdkLogLevel level;
  final String tag;
  final String message;
}

List<DisplayLogEntry> mergeLogEntries({
  required List<LogRecord> sdkRecords,
  required List<String> appLogs,
}) {
  final baseTime = DateTime.now();
  final appEntries = appLogs.asMap().entries.map(
        (entry) => DisplayLogEntry(
          time: baseTime.subtract(
            Duration(milliseconds: appLogs.length - entry.key),
          ),
          level: SdkLogLevel.info,
          tag: 'App',
          message: entry.value,
        ),
      );

  final merged = [
    ...sdkRecords.map(
      (record) => DisplayLogEntry(
        time: record.time,
        level: record.level,
        tag: record.tag,
        message: record.message,
      ),
    ),
    ...appEntries,
  ]..sort((a, b) => b.time.compareTo(a.time));

  return merged;
}

List<DisplayLogEntry> filterDisplayLogs(
  List<DisplayLogEntry> entries,
  SdkLogFilter filter,
) {
  if (filter == SdkLogFilter.all) {
    return entries;
  }
  return entries.where((entry) => filter.matches(entry.level)).toList();
}
