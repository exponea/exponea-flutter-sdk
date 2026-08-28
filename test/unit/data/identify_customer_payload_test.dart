import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:exponea/src/data/normalization/identify_customer_payload.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('encodeIdentifyCustomerPayload', () {
    final data = readMapData('identify_customer_payload');

    test('check data', () {
      expect(data.length, 5);
    });

    test('legacy customer with ids only', () {
      const identifier = Customer(
        ids: {'registered': 'test@mail.com'},
      );

      expect(encodeIdentifyCustomerPayload(identifier), data[0]);
    });

    test('legacy customer with ids and properties', () {
      const identifier = Customer(
        ids: {'registered': 'test@mail.com'},
        properties: {
          'str_test': 'abc-123',
          'double_test': 123.987,
          'int_test': 109,
          'bool_test': true,
        },
      );

      expect(encodeIdentifyCustomerPayload(identifier), data[1]);
    });

    test('customer identity without token', () {
      const identifier = CustomerIdentity(
        customerIds: {'registered': 'test@mail.com'},
      );

      expect(encodeIdentifyCustomerPayload(identifier), data[2]);
    });

    test('customer identity with token', () {
      const identifier = CustomerIdentity(
        customerIds: {'registered': 'test@mail.com'},
        sdkAuthToken: 'mock-jwt-token',
      );

      expect(encodeIdentifyCustomerPayload(identifier), data[3]);
    });

    test('customer identity with token and separate properties', () {
      const identifier = CustomerIdentity(
        customerIds: {'registered': 'test@mail.com'},
        sdkAuthToken: 'mock-jwt-token',
      );

      expect(
        encodeIdentifyCustomerPayload(
          identifier,
          properties: const {
            'first_name': 'Alice',
            'plan': 'premium',
          },
        ),
        data[4],
      );
    });

    test('legacy customer payload unchanged vs CustomerEncoder', () {
      const customer = Customer(
        ids: {'registered': 'test@mail.com'},
        properties: {'str_test': 'abc-123'},
      );

      expect(
        encodeIdentifyCustomerPayload(customer),
        CustomerEncoder.encode(customer),
      );
    });
  });
}
