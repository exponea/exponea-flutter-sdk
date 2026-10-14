import 'package:exponea_example/logging/log_record.dart';
import 'package:exponea_example/logging/sdk_log_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SdkLogLevel', () {
    test('parses native level strings', () {
      expect(SdkLogLevel.parse('verbose'), SdkLogLevel.verbose);
      expect(SdkLogLevel.parse('V'), SdkLogLevel.verbose);
      expect(SdkLogLevel.parse('debug'), SdkLogLevel.debug);
      expect(SdkLogLevel.parse('info'), SdkLogLevel.info);
      expect(SdkLogLevel.parse('warn'), SdkLogLevel.warn);
      expect(SdkLogLevel.parse('warning'), SdkLogLevel.warn);
      expect(SdkLogLevel.parse('error'), SdkLogLevel.error);
    });
  });

  group('LogRecord', () {
    test('fromMap decodes event channel payload', () {
      final record = LogRecord.fromMap({
        'timestamp': 1700000000000,
        'level': 'DEBUG',
        'tag': 'ExponeaSDK',
        'message': 'Configured',
      });

      expect(record.level, SdkLogLevel.debug);
      expect(record.tag, 'ExponeaSDK');
      expect(record.message, 'Configured');
      expect(record.time.millisecondsSinceEpoch, 1700000000000);
    });
  });

  group('mergeLogEntries', () {
    test('sorts newest entries first', () {
      final merged = mergeLogEntries(
        sdkRecords: [
          LogRecord(
            time: DateTime.fromMillisecondsSinceEpoch(1000),
            level: SdkLogLevel.info,
            tag: 'SDK',
            message: 'older',
          ),
          LogRecord(
            time: DateTime.fromMillisecondsSinceEpoch(2000),
            level: SdkLogLevel.debug,
            tag: 'SDK',
            message: 'newer',
          ),
        ],
        appLogs: const [],
      );

      expect(merged.first.message, 'newer');
      expect(merged.last.message, 'older');
    });
  });

  group('SdkLogStore', () {
    late SdkLogStore store;

    setUp(() {
      store = SdkLogStore();
    });

    test('filters by level', () {
      store.addAll([
        LogRecord(
          time: DateTime.fromMillisecondsSinceEpoch(1),
          level: SdkLogLevel.verbose,
          tag: 'SDK',
          message: 'v',
        ),
        LogRecord(
          time: DateTime.fromMillisecondsSinceEpoch(2),
          level: SdkLogLevel.debug,
          tag: 'SDK',
          message: 'd',
        ),
        LogRecord(
          time: DateTime.fromMillisecondsSinceEpoch(3),
          level: SdkLogLevel.info,
          tag: 'App',
          message: 'i',
        ),
      ]);

      expect(store.recordsFor(SdkLogFilter.debug), hasLength(1));
      expect(store.recordsFor(SdkLogFilter.debug).single.message, 'd');
      expect(store.recordsFor(SdkLogFilter.all), hasLength(3));
    });

    test('clear removes all records', () {
      store.add(
        LogRecord(
          time: DateTime.now(),
          level: SdkLogLevel.info,
          tag: 'SDK',
          message: 'hello',
        ),
      );
      store.clear();
      expect(store.records, isEmpty);
    });
  });
}
