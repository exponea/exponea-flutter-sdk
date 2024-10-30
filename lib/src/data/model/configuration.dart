import 'dart:ffi';

import 'package:meta/meta.dart';

import 'event_type.dart';
import 'http_log_level.dart';
import 'notification_importance.dart';
import 'project.dart';
import 'token_frequency.dart';

@immutable
class ExponeaConfiguration {
  /// Default Exponea project token
  final String projectToken;

  /// Default Exponea project authorization token
  final String authorizationToken;

  /// Default Exponea project base URL
  final String? baseUrl;

  /// Map event types to extra projects. Every event is tracked into default project and all projects based on this mapping
  final Map<EventType, List<ExponeaProject>>? projectMapping;

  /// Default properties added to every event tracked to Exponea
  final Map<String, Object>? defaultProperties;

  /// Number of retries for event flushing in case of a failure
  final int? flushMaxRetries;

  /// Time in seconds that user has to have the app closed for session to be ended
  final double? sessionTimeout;

  /// Flag controlling automatic session tracking
  final bool? automaticSessionTracking;

  /// Defines how often should the SDK track push notification token to Exponea
  final TokenFrequency? pushTokenTrackingFrequency;

  /// If true, default properties are applied also for 'identifyCustomer' event.
  final bool? allowDefaultCustomerProperties;

  /// If true, Customer Token authentication is used
  final bool? advancedAuthEnabled;

  /// Platform specific settings for Android
  final AndroidExponeaConfiguration? android;

  /// Platform specific settings for iOS
  final IOSExponeaConfiguration? ios;

  /// Automatically load content of In-app content blocks assigned to these Placeholder IDs
  final List<String>? inAppContentBlockPlaceholdersAutoLoad;

  /// If true, `session_end` is automatically tracked for current open session when next `trackSessionStart()` is called
  final bool? manualSessionAutoClose;

  const ExponeaConfiguration({
    required this.projectToken,
    required this.authorizationToken,
    this.baseUrl,
    this.projectMapping,
    this.defaultProperties,
    this.flushMaxRetries,
    this.sessionTimeout,
    this.automaticSessionTracking,
    this.pushTokenTrackingFrequency,
    this.allowDefaultCustomerProperties,
    this.advancedAuthEnabled,
    this.android,
    this.ios,
    this.inAppContentBlockPlaceholdersAutoLoad,
    this.manualSessionAutoClose,
  });
}

@immutable
class AndroidExponeaConfiguration {
  /// Flag to control if the App will handle push notifications automatically.
  final bool? automaticPushNotifications;

  /// Android resource id of the icon to be used for push notifications
  final int? pushIcon;

  /// Accent color of push notification icon and buttons
  final int? pushAccentColor;

  /// Channel name for push notifications.
  /// Only for API level 26+
  final String? pushChannelName;

  /// Channel description for push notifications.
  /// Only for API level 26+
  final String? pushChannelDescription;

  /// Channel ID for push notifications.
  /// Only for API level 26+
  final String? pushChannelId;

  /// Notification importance for the notification channel.
  /// Only for API level 26+
  final PushNotificationImportance? pushNotificationImportance;

  /// Level of HTTP logging
  final HttpLoggingLevel? httpLoggingLevel;

  const AndroidExponeaConfiguration({
    this.automaticPushNotifications,
    this.pushIcon,
    this.pushAccentColor,
    this.pushChannelName,
    this.pushChannelDescription,
    this.pushChannelId,
    this.pushNotificationImportance,
    this.httpLoggingLevel,
  });
}

@immutable
class IOSExponeaConfiguration {
  /// If true, push notification registration and push token tracking is only done if the device is authorized to display push notifications
  final bool? requirePushAuthorization;

  /// App group used for communication between main app and notification extensions
  final String? appGroup;

  const IOSExponeaConfiguration({
    this.requirePushAuthorization,
    this.appGroup,
  });
}
