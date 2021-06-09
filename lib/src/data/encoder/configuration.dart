import 'package:exponea/src/data/encoder/main.dart';

import '../model/configuration.dart';
import '../util/object.dart';
import 'http_log_level.dart';
import 'notification_importance.dart';

abstract class ExponeaConfigurationEncoder {
  static ExponeaConfiguration decode(Map<String, dynamic> data) {
    return ExponeaConfiguration(
      projectToken: data['projectToken'],
      authorizationToken: data['authorizationToken'],
      baseUrl: data['baseUrl'],
      projectMapping:
          data['projectMapping']?.let(ExponeaProjectMappingEncoder.decode),
      defaultProperties: data['defaultProperties'],
      flushMaxRetries: data['flushMaxRetries'],
      sessionTimeout: data['sessionTimeout'],
      automaticSessionTracking: data['automaticSessionTracking'],
      pushTokenTrackingFrequency:
          data['pushTokenTrackingFrequency']?.let(TokenFrequencyEncoder.decode),
      android: data['android']?.let(AndroidExponeaConfigurationEncoder.decode),
      ios: data['ios']?.let(IOSExponeaConfigurationEncoder.decode),
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
      'flushMaxRetries': config.flushMaxRetries,
      'sessionTimeout': config.sessionTimeout,
      'automaticSessionTracking': config.automaticSessionTracking,
      'pushTokenTrackingFrequency':
          config.pushTokenTrackingFrequency?.let(TokenFrequencyEncoder.encode),
      'android': config.android?.let(AndroidExponeaConfigurationEncoder.encode),
      'ios': config.ios?.let(IOSExponeaConfigurationEncoder.encode),
    };
  }
}

abstract class AndroidExponeaConfigurationEncoder {
  static AndroidExponeaConfiguration decode(Map<String, dynamic> data) {
    return AndroidExponeaConfiguration(
      automaticPushNotifications: data['automaticPushNotifications'],
      pushIcon: data['pushIcon'],
      pushAccentColor: data['pushAccentColor'],
      pushChannelName: data['pushChannelName'],
      pushChannelDescription: data['pushChannelDescription'],
      pushChannelId: data['pushChannelId'],
      pushNotificationImportance: data['pushNotificationImportance']
          ?.let(PushNotificationImportanceEncoder.decode),
      httpLoggingLevel:
          data['httpLoggingLevel']?.let(HttpLoggingLevelEncoder.decode),
    );
  }

  static Map<String, dynamic> encode(AndroidExponeaConfiguration config) {
    return {
      'automaticPushNotifications': config.automaticPushNotifications,
      'pushIcon': config.pushIcon,
      'pushAccentColor': config.pushAccentColor,
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
      requirePushAuthorization: data['requirePushAuthorization'],
      appGroup: data['appGroup'],
    );
  }

  static Map<String, dynamic> encode(IOSExponeaConfiguration config) {
    return {
      'requirePushAuthorization': config.requirePushAuthorization,
      'appGroup': config.appGroup,
    };
  }
}
