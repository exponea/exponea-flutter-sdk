enum EventType {
  /// Install event is fired only once when the app is first installed
  install,

  /// Session start event used to mark the start of a session, typically when an app comes to foreground
  sessionStart,

  /// Session end event used to mark the end of a session, typically when an app goes to background
  sessionEnd,

  /// Custom event tracking, used to report any of your custom events
  trackEvent,

  /// Tracking of customers is used to identify a current customer with some identifier
  trackCustomer,

  /// Virtual and hard payments
  payment,

  /// Event used for registering the push notifications token of the device with Exponea
  pushToken,

  /// For tracking that push notification has been delivered
  pushDelivered,

  /// For tracking that a push notification has been opened
  pushOpened,

  /// For tracking user interaction with links containing campaign data(deeplinks)
  campaignClick,

  /// For tracking in-app message related events
  banner,
}
