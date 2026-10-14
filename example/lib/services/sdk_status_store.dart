import 'package:flutter/foundation.dart';

/// SDK lifecycle state shown by the toolbar status indicator ("semafor").
enum SdkLifecycleState {
  /// SDK is not configured.
  notInitialized,

  /// SDK is configured but no customer is identified.
  anonymous,

  /// SDK is configured and a customer is identified.
  identified,
}

/// Reactive holder for the SDK lifecycle state, mirroring [SdkLogStore].
class SdkStatusStore extends ChangeNotifier {
  SdkLifecycleState _state = SdkLifecycleState.notInitialized;

  SdkLifecycleState get state => _state;

  void set(SdkLifecycleState next) {
    if (_state == next) {
      return;
    }
    _state = next;
    notifyListeners();
  }
}
