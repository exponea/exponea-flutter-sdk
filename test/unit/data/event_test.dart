import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('Event', () {
    const encode = EventEncoder.encode;
    const decode = EventEncoder.decode;

    final data = readMapData('event');
    test('check data', () async {
      expect(data.length, 4);
    });
    final noData = data[0];
    final nameData = data[1];
    final emptyData = data[2];
    final fullData = data[3];

    group('encode', () {
      test('empty', () async {
        const event = Event(name: 'test_event');
        expect(encode(event), emptyData);
      });

      test('full', () async {
        final event = Event(
          name: 'test_event',
          properties: const {
            'str_test': 'abc-123',
            'double_test': 123.987,
            'int_test': 109,
            'bool_test': true,
          },
          timestamp: DateTimeEncoder.decode(1234567890.0),
        );
        expect(encode(event), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        try {
          decode(noData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(err.message, 'name is required!');
        } catch (err) {
          fail('No other errors');
        }
      });

      test('name only', () async {
        final decoded = decode(nameData);

        expect(decoded.name, 'test_event');
        expect(decoded.properties.isEmpty, true);
        expect(decoded.timestamp, null);
      });

      test('empty', () async {
        final decoded = decode(emptyData);

        expect(decoded.name, 'test_event');
        expect(decoded.properties.isEmpty, true);
        expect(decoded.timestamp, null);
      });

      test('full', () async {
        final decoded = decode(fullData);

        expect(decoded.name, 'test_event');
        expect(decoded.properties.length, 4);
        expect(decoded.properties['str_test'], 'abc-123');
        expect(decoded.properties['double_test'], 123.987);
        expect(decoded.properties['int_test'], 109);
        expect(decoded.properties['bool_test'], true);
        expect(decoded.timestamp, DateTimeEncoder.decode(1234567890.0));
      });
    });
  });
}
