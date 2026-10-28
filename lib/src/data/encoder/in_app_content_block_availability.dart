import '../model/in_app_content_block_availability.dart';
import '../model/in_app_content_block_invalidate_mode.dart';

abstract class InAppContentBlockAvailabilityEncoder {
  /// Unknown native values collapse to `loading`, as in React Native.
  static InAppContentBlockAvailability decode(Object? value) {
    switch (value) {
      case 'ready':
        return InAppContentBlockAvailability.ready;
      case 'empty':
        return InAppContentBlockAvailability.empty;
      default:
        return InAppContentBlockAvailability.loading;
    }
  }

  static Map<String, InAppContentBlockAvailability> decodePrefetch(Map data) {
    return data.map((id, value) => MapEntry(id as String, decode(value)));
  }

  /// Unknown native values collapse to timed out, as in React Native.
  static InAppContentBlockAvailabilityDecision decodeDecision(Map data) {
    if (data['status'] == 'resolved') {
      final availability = decode(data['availability']);
      if (availability != InAppContentBlockAvailability.loading) {
        return InAppContentBlockAvailabilityResolved(availability);
      }
    }
    return const InAppContentBlockAvailabilityTimedOut();
  }
}

abstract class InAppContentBlockInvalidateModeEncoder {
  static String encode(InAppContentBlockInvalidateMode mode) => mode.name;
}
