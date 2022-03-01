import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('ReceivedPush', () {
    const encode = ReceivedPushEncoder.encode;
    const decode = ReceivedPushEncoder.decode;

    final data = readMapData('push_received');
    test('check data', () async {
      expect(data.length, 4);
    });
    final noData = data[0];
    final nullData = data[1];
    final emptyData = data[2];
    final fullData = data[3];

    group('encode', () {
      test('empty data', () async {
        const push = ReceivedPush(data: {});
        expect(encode(push), emptyData);
      });

      test('full data', () async {
        const push = ReceivedPush(
          data: {
            'test': true,
            'num': 1.23,
          },
        );
        expect(encode(push), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        try {
          decode(noData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(err.message, 'data is required!');
        } catch (err) {
          fail('No other errors');
        }
      });

      test('null data', () async {
        try {
          decode(nullData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(err.message, 'data is required!');
        } catch (err) {
          fail('No other errors');
        }
      });

      test('empty data', () async {
        const expected = ReceivedPush(data: {});
        final decoded = decode(emptyData);

        expect(decoded.data, expected.data);
      });

      test('full data', () async {
        const expected = ReceivedPush(
          data: {
            'test': true,
            'num': 1.23,
          },
        );
        final decoded = decode(fullData);

        expect(decoded.data, expected.data);
      });
    });
  });
}
