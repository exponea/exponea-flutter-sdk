import 'package:meta/meta.dart';

import 'event_type.dart';
import 'project.dart';

@immutable
class ExponeaConfigurationChange {
  final ExponeaProject? project;
  final Map<EventType, List<ExponeaProject>>? mapping;

  const ExponeaConfigurationChange({
    this.project,
    this.mapping,
  });
}
