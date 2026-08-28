import '../model/sdk_auth_error.dart';
import '../util/object.dart';

abstract class SdkAuthErrorCodeEncoder {
  static String encode(SdkAuthErrorCode code) {
    switch (code) {
      case SdkAuthErrorCode.tokenAboutToExpire:
        return 'TOKEN_ABOUT_TO_EXPIRE';
      case SdkAuthErrorCode.tokenExpired:
        return 'TOKEN_EXPIRED';
      case SdkAuthErrorCode.tokenRejected:
        return 'TOKEN_REJECTED';
      case SdkAuthErrorCode.tokenNotProvided:
        return 'TOKEN_NOT_PROVIDED';
      case SdkAuthErrorCode.tokenInsufficient:
        return 'TOKEN_INSUFFICIENT';
    }
  }

  static SdkAuthErrorCode decode(String value) {
    switch (value) {
      case 'TOKEN_ABOUT_TO_EXPIRE':
        return SdkAuthErrorCode.tokenAboutToExpire;
      case 'TOKEN_EXPIRED':
        return SdkAuthErrorCode.tokenExpired;
      case 'TOKEN_REJECTED':
        return SdkAuthErrorCode.tokenRejected;
      case 'TOKEN_NOT_PROVIDED':
        return SdkAuthErrorCode.tokenNotProvided;
      case 'TOKEN_INSUFFICIENT':
        return SdkAuthErrorCode.tokenInsufficient;
      default:
        throw UnsupportedError('`$value` is not a SdkAuthErrorCode!');
    }
  }
}

abstract class SdkAuthErrorEncoder {
  static SdkAuthError decode(Map<dynamic, dynamic> data) {
    final customerIdsRaw = data.getOptional<Map>('customerIds') ?? {};
    final customerIds = <String, String>{};
    customerIdsRaw.forEach((key, value) {
      if (key != null && value != null) {
        customerIds[key.toString()] = value.toString();
      }
    });
    return SdkAuthError(
      errorCode: SdkAuthErrorCodeEncoder.decode(
        data.getRequired<String>('errorCode'),
      ),
      customerIds: customerIds,
    );
  }

  static Map<String, dynamic> encode(SdkAuthError error) {
    return {
      'errorCode': SdkAuthErrorCodeEncoder.encode(error.errorCode),
      'customerIds': error.customerIds,
    };
  }
}
