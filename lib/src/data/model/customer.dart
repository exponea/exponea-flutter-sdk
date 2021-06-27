import 'package:meta/meta.dart';

@immutable
class Customer {
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
