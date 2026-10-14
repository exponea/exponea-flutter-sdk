import 'package:exponea/exponea.dart';

/// Effective SDK configuration values displayed in the example app shell.
class SdkConfigurationSnapshot {
  const SdkConfigurationSnapshot({
    required this.tokenTrackFrequency,
    required this.applicationId,
  });

  final String tokenTrackFrequency;
  final String applicationId;

  static const defaultApplicationId = 'default-application';

  static SdkConfigurationSnapshot fromExponeaConfiguration(
    ExponeaConfiguration configuration,
  ) {
    return SdkConfigurationSnapshot(
      tokenTrackFrequency: formatTokenTrackFrequency(
        configuration.pushTokenTrackingFrequency ??
            TokenFrequency.onTokenChange,
      ),
      applicationId: resolveApplicationId(configuration.applicationId),
    );
  }

  static String resolveApplicationId(String? applicationId) {
    if (applicationId == null || applicationId.isEmpty) {
      return defaultApplicationId;
    }
    return applicationId;
  }
}

String formatTokenTrackFrequency(TokenFrequency frequency) {
  return switch (frequency) {
    TokenFrequency.onTokenChange => 'on token change',
    TokenFrequency.everyLaunch => 'every launch',
    TokenFrequency.daily => 'daily',
  };
}
