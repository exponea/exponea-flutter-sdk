import '../encoder/customer.dart';
import '../model/customer.dart';

Map<String, dynamic> encodeIdentifyCustomerPayload(
  CustomerIdentifier identifier, {
  Map<String, dynamic>? properties,
}) {
  return switch (identifier) {
    Customer customer => CustomerEncoder.encode(
        Customer(
          ids: customer.ids,
          properties: properties ?? customer.properties,
        ),
      ),
    CustomerIdentity(:final customerIds, :final sdkAuthToken) => {
        'customerIds': customerIds,
        'sdkAuthToken': sdkAuthToken,
        if (properties != null && properties.isNotEmpty) 'properties': properties,
      }..removeWhere((key, value) => value == null),
  };
}
