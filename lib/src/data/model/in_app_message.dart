import 'package:meta/meta.dart';

@immutable
class InAppMessage {
  final String id;
  final String name;
  final String? messageType;
  final String frequency;
  final Map<String, dynamic>? payload;
  final int variantId;
  final String variantName;
  final Map<String, dynamic>? trigger;
  final Map<String, dynamic>? dateFilter;
  final int? loadPriority;
  final int? loadDelay;
  final int? closeTimeout;
  final String? payloadHtml;
  final bool? isHtml;
  final bool? hasTrackingConsent;
  final String? consentCategoryTracking;

  const InAppMessage({
    required this.id,
    required this.name,
    this.messageType,
    required this.frequency,
    this.payload,
    required this.variantId,
    required this.variantName,
    this.trigger,
    this.dateFilter,
    this.loadPriority,
    this.loadDelay,
    this.closeTimeout,
    this.payloadHtml,
    this.isHtml,
    this.hasTrackingConsent,
    this.consentCategoryTracking,
  });

  @override
  String toString() {
    return 'InAppMessage{'
        'id: $id, '
        'name: $name, '
        'messageType: $messageType, '
        'frequency: $frequency, '
        'payload: $payload, '
        'variantId: $variantId, '
        'variantName: $variantName, '
        'trigger: $trigger, '
        'dateFilter: $dateFilter, '
        'loadPriority: $loadPriority, '
        'loadDelay: $loadDelay, '
        'closeTimeout: $closeTimeout, '
        'payloadHtml: $payloadHtml, '
        'isHtml: $isHtml, '
        'hasTrackingConsent: $hasTrackingConsent, '
        'consentCategoryTracking: $consentCategoryTracking'
        '}';
  }
}
