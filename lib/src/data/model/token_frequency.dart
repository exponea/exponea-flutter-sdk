enum TokenFrequency {
  /// Tracked on the first launch or if the token changes.
  onTokenChange,

  /// Tracked every time the app is launched.
  everyLaunch,

  /// Tracked once on days where the user opens the app.
  daily,
}
