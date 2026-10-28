import 'in_app_content_block_availability.dart';
import 'in_app_content_block_invalidate_mode.dart';

/// Controls in-app content block caching at runtime.
///
/// Obtain it from `ExponeaPlugin().inAppContentBlocksController`. The
/// controller renders nothing and tracks nothing; placeholder widgets still
/// render the content.
///
/// Failures are reported as `PlatformException` with one of these codes:
/// `RuntimeInAppContentBlockControllerUnavailable` (the SDK is not configured,
/// was stopped, or this instance is no longer active),
/// `RuntimeInAppContentBlockControllerInvalidMode`, and
/// `RuntimeInAppContentBlockControllerError` for unexpected native failures.
abstract interface class RuntimeInAppContentBlockController {
  /// Starts loading content for [ids] before they are displayed.
  ///
  /// Resolves with the state of each ID once all are final or [deadlineMs]
  /// passes. Without a deadline, it waits until all IDs are final. On a
  /// deadline, IDs that are still unresolved are reported as `empty` on
  /// Android and `loading` on iOS; use [availability] for UI decisions.
  Future<Map<String, InAppContentBlockAvailability>> prefetch(
    List<String> ids, [
    int? deadlineMs,
  ]);

  /// Waits up to [deadlineMs] for [id] to become `ready` or `empty`.
  Future<InAppContentBlockAvailabilityDecision> availability(
    String id,
    int deadlineMs,
  );

  /// Drops cached content for [ids] so it is fetched again.
  ///
  /// Completes once the request is accepted, not when the new content is
  /// loaded.
  Future<void> invalidate(
    List<String> ids,
    String reason, [
    InAppContentBlockInvalidateMode mode = InAppContentBlockInvalidateMode.eager,
  ]);
}
