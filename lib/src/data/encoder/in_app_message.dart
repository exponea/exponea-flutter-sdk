import 'dart:convert';

import 'package:meta/meta.dart';

import '../model/in_app_message.dart';
import '../util/object.dart';

@immutable
class InAppMessageEncoder {
  static InAppMessage decode(Map<dynamic, dynamic> data) {
    return InAppMessage(
      id: data.getRequired('id'),
      name: data.getRequired('name'),
      messageType: data.getOptional('messageType'),
      frequency: data.getRequired('frequency'),
      payload: data.getOptional("payload") != null ? jsonDecode(data.getOptional("payload")) as Map<String, dynamic> : null,
      variantId: data.getRequired('variantId'),
      variantName: data.getRequired('variantName'),
      trigger: data.getOptional("trigger") != null ? jsonDecode(data.getOptional("trigger")) as Map<String, dynamic> : null,
      dateFilter: data.getOptional("dateFilter")!= null ? jsonDecode(data.getOptional("dateFilter")) as Map<String, dynamic> : null,
      loadPriority: data.getOptional('loadPriority'),
      loadDelay: data.getOptional('loadDelay'),
      closeTimeout: data.getOptional('closeTimeout'),
      payloadHtml: data.getOptional('payloadHtml'),
      isHtml: data.getOptional('isHtml'),
      hasTrackingConsent: data.getOptional('hasTrackingConsent'),
      consentCategoryTracking: data.getOptional('consentCategoryTracking'),
    );
  }

  static Map<String, dynamic> encode(InAppMessage message) {
    return {
      'id': message.id,
      'name': message.name,
      'messageType': message.messageType,
      'frequency': message.frequency,
      'payload': message.payload?.let(jsonEncode),
      'variantId': message.variantId,
      'variantName': message.variantName,
      'trigger': message.trigger?.let(jsonEncode),
      'dateFilter': message.dateFilter?.let(jsonEncode),
      'loadPriority': message.loadPriority,
      'loadDelay': message.loadDelay,
      'closeTimeout': message.closeTimeout,
      'payloadHtml': message.payloadHtml,
      'isHtml': message.isHtml,
      'hasTrackingConsent': message.hasTrackingConsent,
      'consentCategoryTracking': message.consentCategoryTracking,
    }..removeWhere((key, value) => value == null);
  }
}
