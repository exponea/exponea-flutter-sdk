import '../model/customer.dart';
import '../util/object.dart';

abstract class CustomerIdentityEncoder {
  static CustomerIdentity decode(Map<String, dynamic> data) {
    return CustomerIdentity(
      customerIds:
          (data.getOptional<Map<String, dynamic>>('customerIds') ?? const {})
              .cast<String, String>(),
      sdkAuthToken: data.getOptional('sdkAuthToken'),
    );
  }

  static Map<String, dynamic> encode(CustomerIdentity identity) {
    return {
      'customerIds': identity.customerIds,
      'sdkAuthToken': identity.sdkAuthToken,
    }..removeWhere((key, value) => value == null);
  }
}
