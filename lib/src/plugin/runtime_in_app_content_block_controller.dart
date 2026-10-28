import 'package:flutter/services.dart';

import '../data/model/in_app_content_block_availability.dart';
import '../data/model/in_app_content_block_invalidate_mode.dart';
import '../data/model/runtime_in_app_content_block_controller.dart';
import '../platform/platform_interface.dart';

/// Holds no native reference: every call resolves the native controller at
/// call time, so a deactivated instance is rejected here before any channel
/// call.
class RuntimeInAppContentBlockControllerImpl
    implements RuntimeInAppContentBlockController {
  RuntimeInAppContentBlockControllerImpl(this._platform);

  final ExponeaPlatform _platform;
  bool _active = true;

  void deactivate() => _active = false;

  void _assertActive() {
    if (!_active) {
      throw PlatformException(
        code: 'RuntimeInAppContentBlockControllerUnavailable',
        message: 'This RuntimeInAppContentBlockController is no longer active '
            'after stopIntegration(). Obtain a new controller from '
            'ExponeaPlugin().inAppContentBlocksController after configuring '
            'the SDK.',
      );
    }
  }

  @override
  Future<Map<String, InAppContentBlockAvailability>> prefetch(
    List<String> ids, [
    int? deadlineMs,
  ]) async {
    _assertActive();
    return _platform.inAppContentBlocksControllerPrefetch(ids, deadlineMs);
  }

  @override
  Future<InAppContentBlockAvailabilityDecision> availability(
    String id,
    int deadlineMs,
  ) async {
    _assertActive();
    return _platform.inAppContentBlocksControllerAvailability(id, deadlineMs);
  }

  @override
  Future<void> invalidate(
    List<String> ids,
    String reason, [
    InAppContentBlockInvalidateMode mode = InAppContentBlockInvalidateMode.eager,
  ]) async {
    _assertActive();
    return _platform.inAppContentBlocksControllerInvalidate(ids, reason, mode);
  }
}

/// Getter state for one [ExponeaPlatform] (one per isolate in production).
///
/// A MethodChannel cannot answer synchronously, so the state is seeded once
/// with `isConfigured()` and then follows `configure()` and
/// `stopIntegration()`.
class RuntimeInAppContentBlockControllerState {
  RuntimeInAppContentBlockControllerState(this._platform);

  final ExponeaPlatform _platform;
  RuntimeInAppContentBlockControllerImpl? controller;

  // Bumped by configure()/stopIntegration() so a late seed cannot override them.
  int _generation = 0;
  bool _seedStarted = false;

  void seed() {
    if (_seedStarted) return;
    _seedStarted = true;
    final generation = _generation;
    _platform.isConfigured().then(
      (configured) {
        if (configured && generation == _generation) {
          controller ??= RuntimeInAppContentBlockControllerImpl(_platform);
        }
      },
      // E.g. no binding yet or no native plugin: retry on the next ExponeaPlugin().
      onError: (Object _) {
        if (generation == _generation) _seedStarted = false;
      },
    );
  }

  /// [started] is the result of `configure()`: `false` means the SDK was
  /// already running, so references the app holds stay valid.
  void onConfigured(bool started) {
    _generation++;
    _seedStarted = true;
    if (started) {
      controller?.deactivate();
      controller = RuntimeInAppContentBlockControllerImpl(_platform);
    } else {
      controller ??= RuntimeInAppContentBlockControllerImpl(_platform);
    }
  }

  void onStopped() {
    _generation++;
    _seedStarted = true;
    controller?.deactivate();
    controller = null;
  }
}
