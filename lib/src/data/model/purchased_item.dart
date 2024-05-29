import 'package:meta/meta.dart';

@immutable
class PurchasedItem {
  final double value;
  final String currency;
  final String paymentSystem;
  final String productId;
  final String productTitle;
  final String? receipt;

  const PurchasedItem({
    required this.value,
    required this.currency,
    required this.paymentSystem,
    required this.productId,
    required this.productTitle,
    this.receipt,
  });

  @override
  String toString() {
    return 'PurchasedItem{'
        'value: $value, '
        'currency: $currency, '
        'paymentSystem: $paymentSystem, '
        'productId: $productId, '
        'productTitle: $productTitle, '
        'receipt: $receipt'
        '}';
  }
}
