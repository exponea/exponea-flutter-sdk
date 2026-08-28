import '../encoder/customer_identity.dart';
import '../encoder/configuration.dart';
import '../model/configuration.dart';
import '../model/customer.dart';

Map<String, dynamic> encodeConfigurePayload(
  ExponeaConfiguration configuration, {
  CustomerIdentifier? customerIdentifier,
}) {
  final payload = ExponeaConfigurationEncoder.encode(configuration);
  if (customerIdentifier != null) {
    payload['customerIdentity'] =
        encodeConfigureCustomerIdentity(customerIdentifier);
  }
  return payload;
}

Map<String, dynamic> encodeConfigureCustomerIdentity(
  CustomerIdentifier identifier,
) {
  return switch (identifier) {
    Customer(:final ids) => {
        'customerIds': ids,
      },
    CustomerIdentity(:final customerIds, :final sdkAuthToken) =>
      CustomerIdentityEncoder.encode(
        CustomerIdentity(
          customerIds: customerIds,
          sdkAuthToken: sdkAuthToken,
        ),
      ),
  };
}
