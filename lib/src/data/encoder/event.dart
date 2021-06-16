import '../model/event.dart';
import '../util/object.dart';
import 'datetime.dart';

abstract class EventEncoder {
  static Event decode(Map<String, dynamic> data) {
    return Event(
      name: data.getRequired('name'),
      properties:
          data.getOptional<Map<String, dynamic>>('properties') ?? const {},
      timestamp:
          data.getOptional<double>('timestamp')?.let(DateTimeEncoder.decode),
    );
  }

  static Map<String, dynamic> encode(Event event) {
    return {
      'name': event.name,
      'properties': event.properties,
      'timestamp': event.timestamp?.let(DateTimeEncoder.encode),
    }..removeWhere((key, value) => value == null);
  }
}
