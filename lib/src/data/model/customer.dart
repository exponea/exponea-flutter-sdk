import 'package:meta/meta.dart';

part 'customer_identity.dart';

sealed class CustomerIdentifier {
  const CustomerIdentifier();
}

@immutable
class Customer extends CustomerIdentifier {
  final Map<String, String> ids;
  final Map<String, dynamic> properties;

  const Customer({
    this.ids = const {},
    this.properties = const {},
  });

  @override
  String toString() {
    return 'Customer{'
        'ids: $ids, '
        'properties: $properties'
        '}';
  }
}
