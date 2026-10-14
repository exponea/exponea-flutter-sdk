/// Predefined in-app message test campaigns for the Track Custom Event dialog.
///
/// Each preset fills [eventName] and [properties] in the dialog so testers can
/// trigger any QA-defined campaign with a single dropdown selection.
///
/// Convention (matches the QA campaigns configured in Bloomreach Engagement):
///   event name = `event_name`, property key = `property`,
///   property value = `test_msg_<type>`.
///
/// Excluded triggers (different SDK APIs — NOT custom events):
///   - Payment: `trackPaymentEvent(PurchasedItem)` → `btn_track_payment`
///   - Session Start: fires on app launch (`session_start`), not via this dialog.
class InAppMessagePreset {
  const InAppMessagePreset({
    required this.label,
    required this.category,
    required this.eventName,
    required this.properties,
  });

  final String label;
  final String category;
  final String eventName;
  final Map<String, dynamic> properties;
}

const _testEvent = 'event_name';
const _propertyKey = 'property';

const List<InAppMessagePreset> inAppMessagePresets = [
  // Core rendering
  InAppMessagePreset(
    label: 'Control Group',
    category: 'Core rendering',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_control_group'},
  ),
  InAppMessagePreset(
    label: 'Alert Rich',
    category: 'Core rendering',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_alert_rich'},
  ),
  InAppMessagePreset(
    label: 'Alert Legacy',
    category: 'Core rendering',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_alert_legacy'},
  ),
  InAppMessagePreset(
    label: 'Slide-in',
    category: 'Core rendering',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_slidein'},
  ),
  InAppMessagePreset(
    label: 'Modal',
    category: 'Core rendering',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_modal'},
  ),
  InAppMessagePreset(
    label: 'Fullscreen',
    category: 'Core rendering',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_fullscreen'},
  ),
  InAppMessagePreset(
    label: 'HTML',
    category: 'Core rendering',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_html'},
  ),
  InAppMessagePreset(
    label: 'HTML No Close',
    category: 'Core rendering',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_html_noclose'},
  ),
  InAppMessagePreset(
    label: 'Data Link External',
    category: 'Core rendering',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_datalink'},
  ),
  InAppMessagePreset(
    label: 'UL Data Link + HTML Attr',
    category: 'Core rendering',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_datalink_html_attr'},
  ),
  // Behaviour / trigger
  InAppMessagePreset(
    label: 'Auto Close 5s',
    category: 'Behaviour',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_autoclose'},
  ),
  InAppMessagePreset(
    label: 'Stop SDK',
    category: 'Behaviour',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_stop_sdk'},
  ),
  InAppMessagePreset(
    label: 'Stop And Restart',
    category: 'Behaviour',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_stop_restart'},
  ),
  // GDPR / consents
  InAppMessagePreset(
    label: 'GDPR Dialog',
    category: 'GDPR',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_gdpr'},
  ),
  InAppMessagePreset(
    label: 'GDPR No Consents Customer',
    category: 'GDPR',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_gdpr_no_consents'},
  ),
  // A/B testing
  InAppMessagePreset(
    label: 'AB Variant A',
    category: 'A/B testing',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_ab_variant_a'},
  ),
  InAppMessagePreset(
    label: 'AB Variant B',
    category: 'A/B testing',
    eventName: _testEvent,
    properties: {_propertyKey: 'test_msg_ab_variant_b'},
  ),
];

/// Returns unique category names in the order they first appear in [inAppMessagePresets].
List<String> get inAppMessagePresetCategories {
  final seen = <String>{};
  return inAppMessagePresets
      .map((p) => p.category)
      .where(seen.add)
      .toList();
}
