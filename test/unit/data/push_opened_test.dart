import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('OpenedPush', () {
    final encode = OpenedPushEncoder.encode;
    final decode = OpenedPushEncoder.decode;

    final data = readMapData('push_opened');
    test('check data', () async {
      expect(data.length, 4);
    });
    final noData = data[0];
    final appData = data[1];
    final deeplinkData = data[2];
    final webData = data[3];

    group('encode', () {
      test('app', () async {
        final push = OpenedPush(action: PushActionType.app);
        expect(encode(push), appData);
      });

      test('deeplink', () async {
        final push = OpenedPush(
          action: PushActionType.deeplink,
          data: {
            'test': true,
            'num': 1.23,
          },
        );
        expect(encode(push), deeplinkData);
      });

      test('web', () async {
        final push = OpenedPush(
          action: PushActionType.web,
          url: 'https://a.b.c',
        );
        expect(encode(push), webData);
      });
    });

    group('decode', () {
      test('no data', () async {
        try {
          decode(noData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(err.message, 'action is required!');
        } catch (err) {
          fail('No other errors');
        }
      });

      test('app', () async {
        final expected = OpenedPush(action: PushActionType.app);
        final decoded = decode(appData);

        expect(decoded.action, expected.action);
        expect(decoded.url, expected.url);
        expect(decoded.data, expected.data);
      });

      test('deeplink', () async {
        final expected = OpenedPush(
          action: PushActionType.deeplink,
          data: {
            'test': true,
            'num': 1.23,
          },
        );
        final decoded = decode(deeplinkData);

        expect(decoded.action, expected.action);
        expect(decoded.url, expected.url);
        expect(decoded.data, expected.data);
      });

      test('web', () async {
        final expected = OpenedPush(
          action: PushActionType.web,
          url: 'https://a.b.c',
        );
        final decoded = decode(webData);

        expect(decoded.action, expected.action);
        expect(decoded.url, expected.url);
        expect(decoded.data, expected.data);
      });
    });
  });
}
