/// Resolves campaign / example-app deeplink URIs to in-app actions.
///
/// Mirrors Android `DeeplinkResolver` path/host matching for `exponea://` and
/// `https://mobile-sdk-example-apps.web.app/exponea/...` URLs.
enum DeeplinkAction {
  fetch,
  track,
  flush,
  anonymize,
  inAppCb,
  stopAndContinue,
  stopAndRestart,
}

abstract final class DeeplinkResolver {
  static DeeplinkAction? resolve(Uri? uri) {
    if (uri == null) {
      return null;
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'exponea' && scheme != 'http' && scheme != 'https') {
      return null;
    }
    // Hosts are lowercased by Uri; match case-insensitively like Android contains().
    final haystack = '${uri.host}${uri.path}'.toLowerCase();
    return _match(haystack);
  }

  static DeeplinkAction? resolveRaw(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return resolve(Uri.tryParse(raw.trim()));
  }

  static DeeplinkAction? _match(String haystack) {
    if (haystack.contains('stopandcontinue')) {
      return DeeplinkAction.stopAndContinue;
    }
    if (haystack.contains('stopandrestart')) {
      return DeeplinkAction.stopAndRestart;
    }
    if (haystack.contains('track')) {
      return DeeplinkAction.track;
    }
    if (haystack.contains('flush')) {
      return DeeplinkAction.flush;
    }
    if (haystack.contains('fetch')) {
      return DeeplinkAction.fetch;
    }
    if (haystack.contains('inappcb')) {
      return DeeplinkAction.inAppCb;
    }
    if (haystack.contains('anonymize')) {
      return DeeplinkAction.anonymize;
    }
    return null;
  }

  /// Bottom-nav tab index for route actions; null for stop flows.
  static int? tabIndexFor(DeeplinkAction action) {
    return switch (action) {
      DeeplinkAction.fetch => 0,
      DeeplinkAction.track => 1,
      DeeplinkAction.flush => 2,
      DeeplinkAction.anonymize => 3,
      DeeplinkAction.inAppCb => 4,
      DeeplinkAction.stopAndContinue || DeeplinkAction.stopAndRestart => null,
    };
  }
}
