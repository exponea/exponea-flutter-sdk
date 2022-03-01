import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('Customer', () {
    const encode = CustomerEncoder.encode;
    const decode = CustomerEncoder.decode;

    final data = readMapData('customer');
    test('check data', () async {
      expect(data.length, 4);
    });
    final noData = data[0];
    final emptyData = data[1];
    final emailData = data[2];
    final fullData = data[3];

    group('encode', () {
      test('empty', () async {
        const customer = Customer();
        expect(encode(customer), emptyData);
      });

      test('with email', () async {
        const customer = Customer(
          ids: {
            'registered': 'test@mail.com',
          },
        );
        expect(encode(customer), emailData);
      });

      test('full', () async {
        const customer = Customer(
          ids: {
            'registered': 'test@mail.com',
          },
          properties: {
            'str_test': 'abc-123',
            'double_test': 123.987,
            'int_test': 109,
            'bool_test': true,
          },
        );
        expect(encode(customer), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        final decoded = decode(noData);

        expect(decoded.ids.isEmpty, true);
        expect(decoded.properties.isEmpty, true);
      });

      test('empty', () async {
        final decoded = decode(emptyData);

        expect(decoded.ids.isEmpty, true);
        expect(decoded.properties.isEmpty, true);
      });

      test('with email', () async {
        final decoded = decode(emailData);

        expect(decoded.ids.length, 1);
        expect(decoded.ids['registered'], 'test@mail.com');
        expect(decoded.properties.isEmpty, true);
      });

      test('full', () async {
        final decoded = decode(fullData);

        expect(decoded.ids.length, 1);
        expect(decoded.ids['registered'], 'test@mail.com');
        expect(decoded.properties.length, 4);
        expect(decoded.properties['str_test'], 'abc-123');
        expect(decoded.properties['double_test'], 123.987);
        expect(decoded.properties['int_test'], 109);
        expect(decoded.properties['bool_test'], true);
      });
    });
  });
}
