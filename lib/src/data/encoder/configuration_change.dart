import '../model/configuration_change.dart';
import '../util/object.dart';
import 'integration_configuration_change.dart';
import 'project.dart';

abstract class ExponeaConfigurationChangeEncoder {
  static ExponeaConfigurationChange decode(Map<String, dynamic> data) {
    return ExponeaConfigurationChange(
      project: data
          .getOptional<Map<String, dynamic>>('project')
          ?.let(ExponeaProjectEncoder.decode),
      mapping: data
          .getOptional<Map<String, dynamic>>('mapping')
          ?.let(ExponeaProjectMappingEncoder.decode),
    );
  }

  static Map<String, dynamic> encode(ExponeaConfigurationChange config) {
    return {
      'project': config.project?.let(ExponeaProjectEncoder.encode),
      'mapping': config.mapping?.let(ExponeaProjectMappingEncoder.encode),
    }..removeWhere((key, value) => value == null);
  }
}

abstract class ConfigurationChangeEncoder {
  static ConfigurationChange decode(Map<String, dynamic> data) {
    final hasIntegrationConfig = data.containsKey('integrationConfig');
    final hasLegacyProject = data.containsKey('project');
    final hasLegacyMapping = data.containsKey('mapping');

    if (hasIntegrationConfig &&
        (hasLegacyProject || hasLegacyMapping)) {
      throw StateError(
        'ConfigurationChange cannot contain both integrationConfig and '
        'legacy project or mapping.',
      );
    }

    if (hasIntegrationConfig) {
      return IntegrationConfigurationChangeEncoder.decode(data);
    }

    return ExponeaConfigurationChangeEncoder.decode(data);
  }

  static Map<String, dynamic> encode(ConfigurationChange change) {
    return switch (change) {
      ExponeaConfigurationChange(:final project, :final mapping) =>
        ExponeaConfigurationChangeEncoder.encode(
          ExponeaConfigurationChange(project: project, mapping: mapping),
        ),
      IntegrationConfigurationChange() =>
        IntegrationConfigurationChangeEncoder.encode(change),
    };
  }
}
