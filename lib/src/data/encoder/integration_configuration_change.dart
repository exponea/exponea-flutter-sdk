import '../model/configuration_change.dart';
import '../normalization/configuration_normalizer.dart';
import '../util/object.dart';
import 'integration_config.dart';

abstract class IntegrationConfigurationChangeEncoder {
  static IntegrationConfigurationChange decode(Map<String, dynamic> data) {
    return IntegrationConfigurationChange(
      integrationConfig: data
          .getOptional<Map<String, dynamic>>('integrationConfig')
          ?.let(IntegrationConfigEncoder.decode),
      integrationRouteMap: data
          .getOptional<Map<String, dynamic>>('integrationRouteMap')
          ?.let(IntegrationRouteMapEncoder.decode),
    );
  }

  static Map<String, dynamic> encode(
    IntegrationConfigurationChange change,
  ) {
    return {
      'integrationConfig':
          change.integrationConfig?.let(IntegrationConfigEncoder.encode),
      'integrationRouteMap': change.integrationRouteMap
          ?.let(IntegrationRouteMapEncoder.encode),
    }..removeWhere((key, value) => value == null);
  }
}
