/// How [RuntimeInAppContentBlockController.invalidate] refreshes content.
enum InAppContentBlockInvalidateMode {
  /// Drop the cached content and fetch it again right away.
  eager,

  /// Drop the cached content and fetch it again the next time it is needed.
  lazy,
}
