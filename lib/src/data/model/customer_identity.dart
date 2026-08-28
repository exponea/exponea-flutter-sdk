part of 'customer.dart';

@immutable
final class CustomerIdentity extends CustomerIdentifier {
  final Map<String, String> customerIds;
  final String? sdkAuthToken;

  const CustomerIdentity({
    required this.customerIds,
    this.sdkAuthToken,
  });

  @override
  String toString() {
    return 'CustomerIdentity{'
        'customerIds: $customerIds, '
        'sdkAuthToken: $sdkAuthToken'
        '}';
  }
}
