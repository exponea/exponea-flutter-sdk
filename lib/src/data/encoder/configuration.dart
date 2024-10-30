import '../model/configuration.dart';
import '../util/object.dart';
import 'http_log_level.dart';
import 'notification_importance.dart';
import 'project.dart';
import 'token_frequency.dart';

abstract class ExponeaConfigurationEncoder {
  static ExponeaConfiguration decode(Map<String, dynamic> data) {
    return ExponeaConfiguration(
      projectToken: data.getRequired('projectToken'),
      authorizationToken: data.getRequired('authorizationToken'),
      baseUrl: data.getOptional('baseUrl'),
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
      allowDefaultCustomerProperties: data.getOptional('allowDefaultCustomerProperties'),
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
    );
  }

  static Map<String, dynamic> encode(ExponeaConfiguration config) {
    return {
      'projectToken': config.projectToken,
      'authorizationToken': config.authorizationToken,
      'baseUrl': config.baseUrl,
      'projectMapping':
          config.projectMapping?.let(ExponeaProjectMappingEncoder.encode),
      'defaultProperties': config.defaultProperties,
      'flushMaxRetries': config.flushMaxRetries?.toDouble(),
      'sessionTimeout': config.sessionTimeout,
      'automaticSessionTracking': config.automaticSessionTracking,
      'allowDefaultCustomerProperties': config.allowDefaultCustomerProperties,
      'advancedAuthEnabled': config.advancedAuthEnabled,
      'pushTokenTrackingFrequency':
          config.pushTokenTrackingFrequency?.let(TokenFrequencyEncoder.encode),
      'android': config.android?.let(AndroidExponeaConfigurationEncoder.encode),
      'ios': config.ios?.let(IOSExponeaConfigurationEncoder.encode),
      'inAppContentBlockPlaceholdersAutoLoad': config.inAppContentBlockPlaceholdersAutoLoad,
      'manualSessionAutoClose' : config.manualSessionAutoClose,
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
