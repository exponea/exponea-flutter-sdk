/// JWT auth error codes delivered on [sdkAuthErrorStream].
enum SdkAuthErrorCode {
  tokenAboutToExpire,
  tokenExpired,
  tokenRejected,
  tokenNotProvided,

  /// Emitted by iOS only; included for forward compatibility.
  tokenInsufficient,
}

/// JWT authentication error from the native SDK (Stream / Data Hub).
class SdkAuthError {
  final SdkAuthErrorCode errorCode;
  final Map<String, String> customerIds;

  const SdkAuthError({
    required this.errorCode,
    this.customerIds = const {},
  });

  @override
  String toString() =>
      'SdkAuthError(errorCode: $errorCode, customerIds: $customerIds)';
}
