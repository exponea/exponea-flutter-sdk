import '../model/configuration_change.dart';
import '../util/object.dart';
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
