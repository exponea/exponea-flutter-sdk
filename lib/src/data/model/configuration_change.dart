import 'package:meta/meta.dart';

import 'event_type.dart';
import 'integration_config.dart';
import 'project.dart';

part 'integration_configuration_change.dart';

sealed class ConfigurationChange {
  const ConfigurationChange();
}

@immutable
class ExponeaConfigurationChange extends ConfigurationChange {
  final ExponeaProject? project;
  final Map<EventType, List<ExponeaProject>>? mapping;

  const ExponeaConfigurationChange({
    this.project,
    this.mapping,
  });
}
