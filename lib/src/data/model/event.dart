import 'package:meta/meta.dart';

@immutable
class Event {
  final String name;
  final Map<String, dynamic> properties;
  final DateTime? timestamp;

  const Event({
    required this.name,
    this.properties = const {},
    this.timestamp,
  });
}
