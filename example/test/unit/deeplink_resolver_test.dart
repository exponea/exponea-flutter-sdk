import 'package:exponea_example/navigation/deeplink_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeeplinkResolver', () {
    test('resolves exponea scheme host paths', () {
      expect(
        DeeplinkResolver.resolve(Uri.parse('exponea://track')),
        DeeplinkAction.track,
      );
      expect(
        DeeplinkResolver.resolve(Uri.parse('exponea://fetch')),
        DeeplinkAction.fetch,
      );
      expect(
        DeeplinkResolver.resolve(Uri.parse('exponea://flush')),
        DeeplinkAction.flush,
      );
      expect(
        DeeplinkResolver.resolve(Uri.parse('exponea://anonymize')),
        DeeplinkAction.anonymize,
      );
      expect(
        DeeplinkResolver.resolve(Uri.parse('exponea://inappcb')),
        DeeplinkAction.inAppCb,
      );
      expect(
        DeeplinkResolver.resolve(Uri.parse('exponea://stopAndContinue')),
        DeeplinkAction.stopAndContinue,
      );
      expect(
        DeeplinkResolver.resolve(Uri.parse('exponea://stopAndRestart')),
        DeeplinkAction.stopAndRestart,
      );
    });

    test('resolves https universal-link paths', () {
      expect(
        DeeplinkResolver.resolve(
          Uri.parse('https://mobile-sdk-example-apps.web.app/exponea/track'),
        ),
        DeeplinkAction.track,
      );
      expect(
        DeeplinkResolver.resolve(
          Uri.parse('https://mobile-sdk-example-apps.web.app/exponea/fetch'),
        ),
        DeeplinkAction.fetch,
      );
      expect(
        DeeplinkResolver.resolve(
          Uri.parse(
            'https://mobile-sdk-example-apps.web.app/exponea/anonymize.html',
          ),
        ),
        DeeplinkAction.anonymize,
      );
    });

    test('resolves campaign-style exponea host URLs', () {
      expect(
        DeeplinkResolver.resolve(
          Uri.parse(
            'exponea://mobile-sdk-example-apps.web.app/exponea/anonymize.html',
          ),
        ),
        DeeplinkAction.anonymize,
      );
    });

    test('maps route actions to tab indexes', () {
      expect(DeeplinkResolver.tabIndexFor(DeeplinkAction.fetch), 0);
      expect(DeeplinkResolver.tabIndexFor(DeeplinkAction.track), 1);
      expect(DeeplinkResolver.tabIndexFor(DeeplinkAction.flush), 2);
      expect(DeeplinkResolver.tabIndexFor(DeeplinkAction.anonymize), 3);
      expect(DeeplinkResolver.tabIndexFor(DeeplinkAction.inAppCb), 4);
      expect(
        DeeplinkResolver.tabIndexFor(DeeplinkAction.stopAndContinue),
        isNull,
      );
    });
  });
}
