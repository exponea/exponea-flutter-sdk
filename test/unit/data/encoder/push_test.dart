import 'dart:convert';

import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpenedPushEncoder', () {
    final encode = OpenedPushEncoder.encode;
    final decode = OpenedPushEncoder.decode;

    group('encode', () {
      test('simple', () async {
        final push = OpenedPush(action: PushActionType.app);
        expect(
          json.encode(encode(push)),
          '{"action":"app","url":null,"additionalData":null}',
        );
      });

      test('with url', () async {
        final push = OpenedPush(
          action: PushActionType.web,
          url: 'https://a.b.c',
        );
        expect(
          json.encode(encode(push)),
          '{"action":"web","url":"https://a.b.c","additionalData":null}',
        );
      });

      test('with additional data', () async {
        final push = OpenedPush(
          action: PushActionType.deeplink,
          additionalData: {
            'test': true,
            'num': 1.23,
          },
        );
        expect(
          json.encode(encode(push)),
          '{"action":"deeplink","url":null,"additionalData":{"test":true,"num":1.23}}',
        );
      });
    });

    group('decode', () {
      test('simple', () async {
        final expected = OpenedPush(action: PushActionType.app);
        final decoded = decode(json.decode('{"action":"app"}'));

        expect(decoded.action, expected.action);
        expect(decoded.url, expected.url);
        expect(decoded.additionalData, expected.additionalData);
      });

      test('with url', () async {
        final expected = OpenedPush(
          action: PushActionType.web,
          url: 'https://a.b.c',
        );
        final decoded = decode(json.decode(
          '{"action":"web","url":"https://a.b.c","additionalData":null}',
        ));

        expect(decoded.action, expected.action);
        expect(decoded.url, expected.url);
        expect(decoded.additionalData, expected.additionalData);
      });

      test('with additional data', () async {
        final expected = OpenedPush(
          action: PushActionType.deeplink,
          additionalData: {
            'test': true,
            'num': 1.23,
          },
        );
        final decoded = decode(json.decode(
          '{"action":"deeplink","url":null,"additionalData":{"test":true,"num":1.23}}',
        ));

        expect(decoded.action, expected.action);
        expect(decoded.url, expected.url);
        expect(decoded.additionalData, expected.additionalData);
      });
    });
  });
}
