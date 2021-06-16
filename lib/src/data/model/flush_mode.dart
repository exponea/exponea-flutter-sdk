enum FlushMode {
  /// Events are flushed to Exponea backend periodically based on flush period
  period,

  /// Events are flushed to Exponea backend when application is closed
  appClose,

  /// Events are flushed to Exponea when flushData() is manually called by the developer
  manual,

  /// Events are flushed to Exponea backend immediately when they are tracked
  immediate,
}
