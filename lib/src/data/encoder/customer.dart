import '../model/customer.dart';
import '../util/object.dart';
import 'customer_identity.dart';

abstract class CustomerEncoder {
  static Customer decode(Map<String, dynamic> data) {
    return Customer(
      ids: (data.getOptional<Map<String, dynamic>>('ids') ?? const {})
          .cast<String, String>(),
      properties:
          data.getOptional<Map<String, dynamic>>('properties') ?? const {},
    );
  }

  static Map<String, dynamic> encode(Customer customer) {
    return {
      'ids': customer.ids,
      'properties': customer.properties,
    };
  }
}

abstract class CustomerIdentifierEncoder {
  static CustomerIdentifier decode(Map<String, dynamic> data) {
    final hasCustomerIds = data.containsKey('customerIds');
    final hasLegacyIds = data.containsKey('ids');

    if (hasCustomerIds && hasLegacyIds) {
      throw StateError(
        'CustomerIdentifier cannot contain both customerIds and ids.',
      );
    }

    if (hasCustomerIds) {
      return CustomerIdentityEncoder.decode(data);
    }

    return CustomerEncoder.decode(data);
  }

  static Map<String, dynamic> encode(CustomerIdentifier identifier) {
    return switch (identifier) {
      Customer(:final ids, :final properties) => CustomerEncoder.encode(
          Customer(ids: ids, properties: properties),
        ),
      CustomerIdentity() => CustomerIdentityEncoder.encode(identifier),
    };
  }
}
