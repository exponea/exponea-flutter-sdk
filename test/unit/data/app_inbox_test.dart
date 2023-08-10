import 'dart:math';

import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('AppInboxCoder', () {
    const encode = AppInboxCoder.encodeMessage;
    const decode = AppInboxCoder.decodeMessage;

    final data = readMapData('app_inbox');
    test('check data', () async {
      expect(data.length, 6);
    });
    final noData = data[0];
    final minData = data[1];
    final withIsRead = data[2];
    final withcreateTime = data[3];
    final withEmptyContent = data[4];
    final fullData = data[5];

    group('encode', () {
      test('minimal', () async {
        const message = AppInboxMessage(
          id: 'mock-id',
          type: 'mock-type',
        );

        expect(encode(message), minData);
      });

      test('with isRead flag', () async {
        const message = AppInboxMessage(
          id: 'mock-id',
          type: 'mock-type',
          isRead: true,
        );

        expect(encode(message), withIsRead);
      });

      test('with createTime value', () async {
        const message = AppInboxMessage(
          id: 'mock-id',
          type: 'mock-type',
          isRead: true,
          createTime: 1,
        );

        expect(encode(message), withcreateTime);
      });

      test('with empty content', () async {
        const message = AppInboxMessage(
            id: 'mock-id',
            type: 'mock-type',
            isRead: true,
            createTime: 1,
            content: {},);

        expect(encode(message), withEmptyContent);
      });

      test('full', () async {
        const message = AppInboxMessage(
            id: 'mock-id',
            type: 'mock-type',
            isRead: true,
            createTime: 1,
            content: {'mock-content-param': 'mock-content'});

        expect(encode(message), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        expect(() => decode(noData), throwsStateError);
      });

      test('minimal', () async {
        final decoded = decode(minData);
        expect(decoded.id, 'mock-id');
        expect(decoded.type, 'mock-type');
        expect(decoded.isRead, null);
        expect(decoded.createTime, null);
        expect(decoded.content, null);
      });

      test('with isRead flag', () async {
        final decoded = decode(withIsRead);
        expect(decoded.id, 'mock-id');
        expect(decoded.type, 'mock-type');
        expect(decoded.isRead, true);
        expect(decoded.createTime, null);
        expect(decoded.content, null);
      });

      test('with createTime value', () async {
        final decoded = decode(withcreateTime);
        expect(decoded.id, 'mock-id');
        expect(decoded.type, 'mock-type');
        expect(decoded.isRead, true);
        expect(decoded.createTime, 1);
        expect(decoded.content, null);
      });

      test('with empty content', () async {
        final decoded = decode(withEmptyContent);
        expect(decoded.id, 'mock-id');
        expect(decoded.type, 'mock-type');
        expect(decoded.isRead, true);
        expect(decoded.createTime, 1);
        expect(decoded.content, {});
      });

      test('full', () async {
        final decoded = decode(fullData);
        expect(decoded.id, 'mock-id');
        expect(decoded.type, 'mock-type');
        expect(decoded.isRead, true);
        expect(decoded.createTime, 1);
        expect(decoded.content, {'mock-content-param': 'mock-content'});
      });
    });
  });
}
