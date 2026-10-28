import 'package:meta/meta.dart';

/// Content state of an in-app content block placeholder.
enum InAppContentBlockAvailability {
  /// Content is loaded and can be rendered.
  ready,

  /// Content is still loading.
  loading,

  /// There is no content to show for the current customer.
  empty,
}

/// Result of [RuntimeInAppContentBlockController.availability].
@immutable
sealed class InAppContentBlockAvailabilityDecision {
  const InAppContentBlockAvailabilityDecision();
}

/// The placeholder reached a final state before the deadline.
final class InAppContentBlockAvailabilityResolved
    extends InAppContentBlockAvailabilityDecision {
  /// Either [InAppContentBlockAvailability.ready] or
  /// [InAppContentBlockAvailability.empty], never `loading`.
  final InAppContentBlockAvailability availability;

  const InAppContentBlockAvailabilityResolved(this.availability);

  @override
  bool operator ==(Object other) =>
      other is InAppContentBlockAvailabilityResolved &&
      other.availability == availability;

  @override
  int get hashCode => availability.hashCode;

  @override
  String toString() => 'InAppContentBlockAvailabilityResolved($availability)';
}

/// The deadline passed before the placeholder reached a final state.
final class InAppContentBlockAvailabilityTimedOut
    extends InAppContentBlockAvailabilityDecision {
  const InAppContentBlockAvailabilityTimedOut();

  @override
  bool operator ==(Object other) => other is InAppContentBlockAvailabilityTimedOut;

  @override
  int get hashCode => (InAppContentBlockAvailabilityTimedOut).hashCode;

  @override
  String toString() => 'InAppContentBlockAvailabilityTimedOut()';
}
