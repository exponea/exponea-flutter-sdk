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

  /// If true, push notification registration and push token tracking is only done if the device is authorized to display push notifications
  final bool? requirePushAuthorization;

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

  /// If null, 'applicationId' with default value 'default-application' will be used. Otherwise 'applicationId' must be in specific format see Documentation/configuration.md for more details.
  final String? applicationId;

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
    this.requirePushAuthorization,
    this.allowDefaultCustomerProperties,
    this.advancedAuthEnabled,
    this.android,
    this.ios,
    this.inAppContentBlockPlaceholdersAutoLoad,
    this.manualSessionAutoClose,
    this.applicationId
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

  /// Defines margin-top of Image in App Inbox detail screen in dp.
  /// Default value (null) will result in ?attr/ actionBarSize defined in application theme.
  /// This is useful in case of transparent toolbar theming.
  final int? appInboxDetailImageInset;

  /// Flag that enables or disables cookies in WebViews. Cookies in WebView could be misused by malware so it is
  /// recommended to keep them disabled (default value). According to shared CookieManager in android, this flag could
  /// affect all WebView instances used by application. If your application is using WebView and page logic depends on
  /// cookies, you may allow them with true value.
  final bool? allowWebViewCookies;

  const AndroidExponeaConfiguration({
    this.automaticPushNotifications,
    this.pushIcon,
    this.pushAccentColor,
    this.pushChannelName,
    this.pushChannelDescription,
    this.pushChannelId,
    this.pushNotificationImportance,
    this.httpLoggingLevel,
    this.appInboxDetailImageInset,
    this.allowWebViewCookies,
  });
}

@immutable
class IOSExponeaConfiguration {
  /// If true, push notification registration and push token tracking is only done if the device is authorized to display push notifications
  final bool? requirePushAuthorization;

  /// App group used for communication between main app and notification extensions
  final String? appGroup;

  const IOSExponeaConfiguration({
    @Deprecated("Will be removed in a later version of the SDK, use common 'requirePushAuthorization' instead. When both are set, the common one will be used.")
    this.requirePushAuthorization,
    this.appGroup,
  });
}
