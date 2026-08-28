import 'package:meta/meta.dart';

import 'event_type.dart';
import 'http_log_level.dart';
import 'integration_config.dart';
import 'notification_importance.dart';
import 'project.dart';
import 'token_frequency.dart';

@immutable
class ExponeaConfiguration {
  /// Project or Stream integration settings for the default destination.
  final IntegrationConfig? integrationConfig;

  /// Map event types to extra project integrations.
  final Map<EventType, List<ProjectIntegrationConfig>>? integrationRouteMap;

  /// Default Exponea project token
  @Deprecated(
    'Use integrationConfig with ProjectIntegrationConfig instead.',
  )
  final String? projectToken;

  /// Default Exponea project authorization token
  @Deprecated(
    'Use integrationConfig with ProjectIntegrationConfig instead.',
  )
  final String? authorizationToken;

  /// Default Exponea project base URL
  @Deprecated(
    'Use integrationConfig with ProjectIntegrationConfig or '
    'StreamIntegrationConfig instead.',
  )
  final String? baseUrl;

  /// Map event types to extra projects. Every event is tracked into default project and all projects based on this mapping
  @Deprecated('Use integrationRouteMap instead.')
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

  /// If true, push notification registration and push token tracking is only done if the device is authorized to display push notifications.
  ///
  /// Deprecated — use [IOSExponeaConfiguration.requirePushAuthorization] instead.
  /// This top-level parameter has no effect on Android and is kept for backward compatibility
  /// as a fallback on iOS when the iOS-specific value is not set.
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

  /// If true, `anonymize()` generates a new device_id so the new anonymous customer gets a fresh device_id.
  final bool? regenerateDeviceIdOnAnonymize;

  /// If null, 'applicationId' with default value 'default-application' will be used. Otherwise 'applicationId' must be in specific format see Documentation/configuration.md for more details.
  final String? applicationId;

  const ExponeaConfiguration({
    this.integrationConfig,
    this.integrationRouteMap,
    @Deprecated('Use integrationConfig with ProjectIntegrationConfig instead.')
    this.projectToken,
    @Deprecated('Use integrationConfig with ProjectIntegrationConfig instead.')
    this.authorizationToken,
    @Deprecated(
      'Use integrationConfig with ProjectIntegrationConfig or '
      'StreamIntegrationConfig instead.',
    )
    this.baseUrl,
    @Deprecated('Use integrationRouteMap instead.') this.projectMapping,
    this.defaultProperties,
    this.flushMaxRetries,
    this.sessionTimeout,
    this.automaticSessionTracking,
    this.pushTokenTrackingFrequency,
    @Deprecated(
      "Use 'ios.requirePushAuthorization' instead. This top-level parameter has no effect on Android and is kept for backward compatibility as a fallback on iOS when the iOS-specific value is not set.",
    )
    this.requirePushAuthorization,
    this.allowDefaultCustomerProperties,
    this.advancedAuthEnabled,
    this.android,
    this.ios,
    this.inAppContentBlockPlaceholdersAutoLoad,
    this.manualSessionAutoClose,
    this.regenerateDeviceIdOnAnonymize,
    this.applicationId,
  }) : assert(
          integrationConfig != null ||
              (projectToken != null && authorizationToken != null),
          'ExponeaConfiguration requires integrationConfig or legacy '
          'projectToken and authorizationToken.',
        );

  factory ExponeaConfiguration.stream({
    required String streamId,
    String? baseUrl,
    Map<String, Object>? defaultProperties,
    int? flushMaxRetries,
    double? sessionTimeout,
    bool? automaticSessionTracking,
    TokenFrequency? pushTokenTrackingFrequency,
    bool? requirePushAuthorization,
    bool? allowDefaultCustomerProperties,
    AndroidExponeaConfiguration? android,
    IOSExponeaConfiguration? ios,
    List<String>? inAppContentBlockPlaceholdersAutoLoad,
    bool? manualSessionAutoClose,
    bool? regenerateDeviceIdOnAnonymize,
    String? applicationId,
  }) {
    return ExponeaConfiguration(
      integrationConfig: StreamIntegrationConfig(
        streamId: streamId,
        baseUrl: baseUrl,
      ),
      defaultProperties: defaultProperties,
      flushMaxRetries: flushMaxRetries,
      sessionTimeout: sessionTimeout,
      automaticSessionTracking: automaticSessionTracking,
      pushTokenTrackingFrequency: pushTokenTrackingFrequency,
      requirePushAuthorization: requirePushAuthorization,
      allowDefaultCustomerProperties: allowDefaultCustomerProperties,
      android: android,
      ios: ios,
      inAppContentBlockPlaceholdersAutoLoad: inAppContentBlockPlaceholdersAutoLoad,
      manualSessionAutoClose: manualSessionAutoClose,
      regenerateDeviceIdOnAnonymize: regenerateDeviceIdOnAnonymize,
      applicationId: applicationId,
    );
  }
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
  /// Controls whether the SDK calls `registerForRemoteNotifications()` automatically based on the
  /// OS-reported notification authorization status.
  ///
  /// When `true` (default), the SDK only calls `registerForRemoteNotifications()` once the OS
  /// reports `authorized` or `provisional` status. Use this when your app should not receive an
  /// APNs token until the user has explicitly granted notification permission.
  ///
  /// When `false`, the SDK calls `registerForRemoteNotifications()` unconditionally on every
  /// launch, allowing the app to receive silent pushes regardless of the user's visible
  /// notification permission state.
  ///
  /// This flag does not affect the `valid` field in `notification_state` events — `valid` always
  /// reflects the actual OS authorization status, regardless of how this flag is set.
  ///
  /// Your app is responsible for requesting notification permission from the user — the SDK never
  /// triggers the permission prompt itself.
  ///
  /// If the deprecated top-level [ExponeaConfiguration.requirePushAuthorization] is also set,
  /// this iOS-specific value takes precedence.
  final bool? requirePushAuthorization;

  /// App group used for communication between main app and notification extensions
  final String? appGroup;

  const IOSExponeaConfiguration({
    this.requirePushAuthorization,
    this.appGroup,
  });
}
