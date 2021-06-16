import '../model/customer.dart';
import '../util/object.dart';

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
