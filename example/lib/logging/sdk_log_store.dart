import 'package:exponea_example/logging/log_record.dart';
import 'package:flutter/foundation.dart';

class SdkLogStore extends ChangeNotifier {
  final List<LogRecord> _records = [];

  List<LogRecord> get records => List.unmodifiable(_records);

  void add(LogRecord record) {
    _records.add(record);
    if (_records.length > 500) {
      _records.removeAt(0);
    }
    notifyListeners();
  }

  void addAll(Iterable<LogRecord> records) {
    for (final record in records) {
      add(record);
    }
  }

  List<LogRecord> recordsFor(SdkLogFilter filter) {
    if (filter == SdkLogFilter.all) {
      return records;
    }
    return records.where((record) => filter.matches(record.level)).toList();
  }

  void clear() {
    _records.clear();
    notifyListeners();
  }
}
