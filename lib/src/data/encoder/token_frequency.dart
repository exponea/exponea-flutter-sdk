import '../model/token_frequency.dart';

abstract class TokenFrequencyEncoder {
  static String encode(TokenFrequency frequency) {
    switch (frequency) {
      case TokenFrequency.onTokenChange:
        return 'ON_TOKEN_CHANGE';
      case TokenFrequency.everyLaunch:
        return 'EVERY_LAUNCH';
      case TokenFrequency.daily:
        return 'DAILY';
    }
  }

  static TokenFrequency decode(String value) {
    switch (value) {
      case 'ON_TOKEN_CHANGE':
        return TokenFrequency.onTokenChange;
      case 'EVERY_LAUNCH':
        return TokenFrequency.everyLaunch;
      case 'DAILY':
        return TokenFrequency.daily;
      default:
        throw UnsupportedError('`$value` is not a TokenFrequency!');
    }
  }
}
