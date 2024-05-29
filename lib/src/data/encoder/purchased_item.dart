import 'package:meta/meta.dart';

import '../model/purchased_item.dart';

@immutable
class PurchasedItemEncoder {
  static Map<String, dynamic> encode(PurchasedItem purchasedItem) {
    return {
      'value': purchasedItem.value,
      'currency': purchasedItem.currency,
      'paymentSystem': purchasedItem.paymentSystem,
      'productId': purchasedItem.productId,
      'productTitle': purchasedItem.productTitle,
      'receipt': purchasedItem.receipt,
    }..removeWhere((key, value) => value == null);
  }
}
