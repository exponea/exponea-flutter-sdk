import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('CustomerIdentity', () {
    const encode = CustomerIdentityEncoder.encode;
    const decode = CustomerIdentityEncoder.decode;

    final data = readMapData('customer_identity');
    test('check data', () async {
      expect(data.length, 3);
    });
    final emptyIdsData = data[0];
    final emailData = data[1];
    final withTokenData = data[2];

    group('encode', () {
      test('empty customerIds', () async {
        const identity = CustomerIdentity(customerIds: {});
        expect(encode(identity), emptyIdsData);
      });

      test('with customerIds', () async {
        const identity = CustomerIdentity(
          customerIds: {'registered': 'test@mail.com'},
        );
        expect(encode(identity), emailData);
      });

      test('with sdkAuthToken', () async {
        const identity = CustomerIdentity(
          customerIds: {'registered': 'test@mail.com'},
          sdkAuthToken: 'mock-jwt-token',
        );
        expect(encode(identity), withTokenData);
      });
    });

    group('decode', () {
      test('empty customerIds', () async {
        final decoded = decode(emptyIdsData);

        expect(decoded.customerIds.isEmpty, true);
        expect(decoded.sdkAuthToken, null);
      });

      test('with customerIds', () async {
        final decoded = decode(emailData);

        expect(decoded.customerIds.length, 1);
        expect(decoded.customerIds['registered'], 'test@mail.com');
        expect(decoded.sdkAuthToken, null);
      });

      test('with sdkAuthToken', () async {
        final decoded = decode(withTokenData);

        expect(decoded.customerIds.length, 1);
        expect(decoded.customerIds['registered'], 'test@mail.com');
        expect(decoded.sdkAuthToken, 'mock-jwt-token');
      });
    });
  });

  group('CustomerIdentifier', () {
    const encode = CustomerIdentifierEncoder.encode;
    const decode = CustomerIdentifierEncoder.decode;

    test('Customer is a CustomerIdentifier subtype', () {
      const customer = Customer(
        ids: {'registered': 'test@mail.com'},
      );
      expect(customer, isA<CustomerIdentifier>());
    });

    test('CustomerIdentity is a CustomerIdentifier subtype', () {
      const identity = CustomerIdentity(
        customerIds: {'registered': 'test@mail.com'},
      );
      expect(identity, isA<CustomerIdentifier>());
    });

    test('encode legacy Customer unchanged', () {
      const customer = Customer(
        ids: {'registered': 'test@mail.com'},
        properties: {'str_test': 'abc-123'},
      );

      expect(
        encode(customer),
        CustomerEncoder.encode(customer),
      );
    });

    test('encode CustomerIdentity produces customerIds map', () {
      const identity = CustomerIdentity(
        customerIds: {'registered': 'test@mail.com'},
        sdkAuthToken: 'mock-jwt-token',
      );

      expect(
        encode(identity),
        CustomerIdentityEncoder.encode(identity),
      );
    });

    test('decode CustomerIdentity wire shape', () {
      final decoded = decode({
        'customerIds': {'registered': 'test@mail.com'},
        'sdkAuthToken': 'mock-jwt-token',
      });

      expect(decoded, isA<CustomerIdentity>());
      final identity = decoded as CustomerIdentity;
      expect(identity.customerIds['registered'], 'test@mail.com');
      expect(identity.sdkAuthToken, 'mock-jwt-token');
    });

    test('decode legacy Customer wire shape', () {
      final decoded = decode({
        'ids': {'registered': 'test@mail.com'},
        'properties': {'str_test': 'abc-123'},
      });

      expect(decoded, isA<Customer>());
      final customer = decoded as Customer;
      expect(customer.ids['registered'], 'test@mail.com');
      expect(customer.properties['str_test'], 'abc-123');
    });

    test('rejects both ids and customerIds', () {
      expect(
        () => decode({
          'ids': {'registered': 'test@mail.com'},
          'customerIds': {'registered': 'test@mail.com'},
        }),
        throwsA(isA<StateError>()),
      );
    });
  });
}
