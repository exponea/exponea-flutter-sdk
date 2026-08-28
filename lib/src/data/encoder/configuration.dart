import '../model/configuration.dart';
import '../normalization/configuration_normalizer.dart';
import '../util/object.dart';
import 'http_log_level.dart';
import 'integration_config.dart';
import 'notification_importance.dart';
import 'project.dart';
import 'token_frequency.dart';

abstract class ExponeaConfigurationEncoder {
  static ExponeaConfiguration decode(Map<String, dynamic> data) {
    final integrationConfigData =
        data.getOptional<Map<String, dynamic>>('integrationConfig');
    final integrationConfig = integrationConfigData
        ?.let(IntegrationConfigEncoder.decode);
    final integrationRouteMap = data
        .getOptional<Map<String, dynamic>>('integrationRouteMap')
        ?.let(IntegrationRouteMapEncoder.decode);

    return ExponeaConfiguration(
      integrationConfig: integrationConfig,
      integrationRouteMap: integrationRouteMap,
      projectToken: integrationConfig == null
          ? data.getRequired('projectToken')
          : null,
      authorizationToken: integrationConfig == null
          ? data.getRequired('authorizationToken')
          : null,
      baseUrl: integrationConfig == null
          ? data.getOptional('baseUrl')
          : null,
      projectMapping: data
          .getOptional<Map<String, dynamic>>('projectMapping')
          ?.let(ExponeaProjectMappingEncoder.decode),
      defaultProperties: data
          .getOptional<Map<String, dynamic>>('defaultProperties')
          ?.cast<String, Object>(),
      flushMaxRetries: data.getOptional<num>('flushMaxRetries')?.toInt(),
      sessionTimeout: data.getOptional('sessionTimeout'),
      automaticSessionTracking: data.getOptional('automaticSessionTracking'),
      pushTokenTrackingFrequency: data
          .getOptional<String>('pushTokenTrackingFrequency')
          ?.let(TokenFrequencyEncoder.decode),
      requirePushAuthorization: data.getOptional('requirePushAuthorization'),
      allowDefaultCustomerProperties:
          data.getOptional('allowDefaultCustomerProperties'),
      advancedAuthEnabled: data.getOptional('advancedAuthEnabled'),
      android: data
          .getOptional<Map<String, dynamic>>('android')
          ?.let(AndroidExponeaConfigurationEncoder.decode),
      ios: data
          .getOptional<Map<String, dynamic>>('ios')
          ?.let(IOSExponeaConfigurationEncoder.decode),
      inAppContentBlockPlaceholdersAutoLoad: data
          .getOptional<List>('inAppContentBlockPlaceholdersAutoLoad')
          ?.map((it) => it.toString())
          .toList(growable: false),
      manualSessionAutoClose: data.getOptional('manualSessionAutoClose'),
      regenerateDeviceIdOnAnonymize: data.getOptional('regenerateDeviceIdOnAnonymize'),
      applicationId: data.getOptional('applicationId'),
    );
  }

  static Map<String, dynamic> encode(ExponeaConfiguration config) {
    final integrationConfig = resolveIntegrationConfig(config);
    final routeMap = resolveIntegrationRouteMap(config, integrationConfig);
    final omitAdvancedAuth = shouldOmitAdvancedAuthForStream(config);

    return {
      'integrationConfig': IntegrationConfigEncoder.encode(integrationConfig),
      'integrationRouteMap': routeMap?.let(IntegrationRouteMapEncoder.encode),
      'defaultProperties': config.defaultProperties,
      'flushMaxRetries': config.flushMaxRetries?.toDouble(),
      'sessionTimeout': config.sessionTimeout,
      'automaticSessionTracking': config.automaticSessionTracking,
      'allowDefaultCustomerProperties': config.allowDefaultCustomerProperties,
      if (!omitAdvancedAuth) 'advancedAuthEnabled': config.advancedAuthEnabled,
      'pushTokenTrackingFrequency': config.pushTokenTrackingFrequency
          ?.let(TokenFrequencyEncoder.encode),
      'requirePushAuthorization': config.requirePushAuthorization,
      'android': config.android?.let(AndroidExponeaConfigurationEncoder.encode),
      'ios': config.ios?.let(IOSExponeaConfigurationEncoder.encode),
      'inAppContentBlockPlaceholdersAutoLoad':
          config.inAppContentBlockPlaceholdersAutoLoad,
      'manualSessionAutoClose': config.manualSessionAutoClose,
      'regenerateDeviceIdOnAnonymize': config.regenerateDeviceIdOnAnonymize,
      'applicationId': config.applicationId,
    }..removeWhere((key, value) => value == null);
  }
}

abstract class AndroidExponeaConfigurationEncoder {
  static AndroidExponeaConfiguration decode(Map<String, dynamic> data) {
    return AndroidExponeaConfiguration(
      automaticPushNotifications:
          data.getOptional('automaticPushNotifications'),
      pushIcon: data.getOptional<num>('pushIcon')?.toInt(),
      pushAccentColor: data.getOptional<num>('pushAccentColor')?.toInt(),
      pushChannelName: data.getOptional('pushChannelName'),
      pushChannelDescription: data.getOptional('pushChannelDescription'),
      pushChannelId: data.getOptional('pushChannelId'),
      pushNotificationImportance: data
          .getOptional<String>('pushNotificationImportance')
          ?.let(PushNotificationImportanceEncoder.decode),
      httpLoggingLevel: data
          .getOptional<String>('httpLoggingLevel')
          ?.let(HttpLoggingLevelEncoder.decode),
      appInboxDetailImageInset:
          data.getOptional<num>('appInboxDetailImageInset')?.toInt(),
      allowWebViewCookies: data.getOptional('allowWebViewCookies'),
    );
  }

  static Map<String, dynamic> encode(AndroidExponeaConfiguration config) {
    return {
      'automaticPushNotifications': config.automaticPushNotifications,
      'pushIcon': config.pushIcon?.toDouble(),
      'pushAccentColor': config.pushAccentColor?.toDouble(),
      'pushChannelName': config.pushChannelName,
      'pushChannelDescription': config.pushChannelDescription,
      'pushChannelId': config.pushChannelId,
      'pushNotificationImportance': config.pushNotificationImportance
          ?.let(PushNotificationImportanceEncoder.encode),
      'httpLoggingLevel':
          config.httpLoggingLevel?.let(HttpLoggingLevelEncoder.encode),
      'appInboxDetailImageInset': config.appInboxDetailImageInset?.toDouble(),
      'allowWebViewCookies': config.allowWebViewCookies,
    };
  }
}

abstract class IOSExponeaConfigurationEncoder {
  static IOSExponeaConfiguration decode(Map<String, dynamic> data) {
    return IOSExponeaConfiguration(
      requirePushAuthorization: data.getOptional('requirePushAuthorization'),
      appGroup: data.getOptional('appGroup'),
    );
  }

  static Map<String, dynamic> encode(IOSExponeaConfiguration config) {
    return {
      'requirePushAuthorization': config.requirePushAuthorization,
      'appGroup': config.appGroup,
    };
  }
}
