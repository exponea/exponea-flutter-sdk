enum HttpLoggingLevel {
  /// No logs.
  none,

  /// Logs request and response lines.
  basic,

  /// Logs request and response lines and their respective headers.
  headers,

  /// Logs request and response lines and their respective headers and bodies (if present).
  body,
}
