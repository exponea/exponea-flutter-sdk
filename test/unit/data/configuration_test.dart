import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('ExponeaConfiguration', () {
    const encode = ExponeaConfigurationEncoder.encode;
    const decode = ExponeaConfigurationEncoder.decode;

    final data = readMapData('configuration');
    test('check data', () async {
      expect(data.length, 4);
    });
    final noData = data[0];
    final minData = data[1];
    final defaultSession = data[2];
    final fullData = data[3];

    group('encode', () {
      test('minimal', () async {
        const config = ExponeaConfiguration(
          projectToken: 'mock-project-token',
          authorizationToken: 'mock-auth-token',
        );
        expect(encode(config), minData);
      });

      test('defaultSession', () async {
        const config = ExponeaConfiguration(
          projectToken: 'mock-project-token',
          authorizationToken: 'mock-auth-token',
          baseUrl: 'http://mock.base.url.com',
          projectMapping: {
            EventType.banner: [
              ExponeaProject(
                projectToken: 'other-project-token',
                authorizationToken: 'other-auth-token',
              ),
            ],
          },
          defaultProperties: {
            "string": "value",
            "boolean": false,
            "number": 3.14159,
            "array": ["value1", "value2"],
            "object": {"key": "value"},
          },
          allowDefaultCustomerProperties: true,
          flushMaxRetries: 10,
          sessionTimeout: 60,
          automaticSessionTracking: true,
          advancedAuthEnabled: true,
          inAppContentBlockPlaceholdersAutoLoad: [
            'mock-placeholder-1',
            'mock-placeholder-2'
          ],
          pushTokenTrackingFrequency: TokenFrequency.daily,
          requirePushAuthorization: true,
          manualSessionAutoClose: true,
          android: AndroidExponeaConfiguration(
            automaticPushNotifications: true,
            pushIcon: 12345,
            pushAccentColor: 0xFF112233,
            pushChannelName: 'mock-push-channel-name',
            pushChannelDescription: 'mock-push-channel-description',
            pushChannelId: 'mock-push-channel-id',
            pushNotificationImportance: PushNotificationImportance.high,
            httpLoggingLevel: HttpLoggingLevel.body,
            appInboxDetailImageInset: 16,
            allowWebViewCookies: true,
          ),
          ios: IOSExponeaConfiguration(
            requirePushAuthorization: false,
            appGroup: 'mock-app-group',
          ),
        );

        expect(encode(config), defaultSession);
      });

      test('full', () async {
        const config = ExponeaConfiguration(
          projectToken: 'mock-project-token',
          authorizationToken: 'mock-auth-token',
          baseUrl: 'http://mock.base.url.com',
          projectMapping: {
            EventType.banner: [
              ExponeaProject(
                projectToken: 'other-project-token',
                authorizationToken: 'other-auth-token',
              ),
            ],
          },
          defaultProperties: {
            "string": "value",
            "boolean": false,
            "number": 3.14159,
            "array": ["value1", "value2"],
            "object": {"key": "value"},
          },
          allowDefaultCustomerProperties: true,
          flushMaxRetries: 10,
          sessionTimeout: 45,
          automaticSessionTracking: true,
          advancedAuthEnabled: true,
          inAppContentBlockPlaceholdersAutoLoad: [
            'mock-placeholder-1',
            'mock-placeholder-2'
          ],
          pushTokenTrackingFrequency: TokenFrequency.daily,
          requirePushAuthorization: true,
          manualSessionAutoClose: true,
          android: AndroidExponeaConfiguration(
            automaticPushNotifications: true,
            pushIcon: 12345,
            pushAccentColor: 0xFF112233,
            pushChannelName: 'mock-push-channel-name',
            pushChannelDescription: 'mock-push-channel-description',
            pushChannelId: 'mock-push-channel-id',
            pushNotificationImportance: PushNotificationImportance.high,
            httpLoggingLevel: HttpLoggingLevel.body,
            appInboxDetailImageInset: 16,
            allowWebViewCookies: true,
          ),
          ios: IOSExponeaConfiguration(
            requirePushAuthorization: false,
            appGroup: 'mock-app-group',
          ),
        );

        expect(encode(config), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        try {
          decode(noData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(err.message, 'projectToken is required!');
        } catch (err) {
          fail('No other errors');
        }
      });

      test('minimal', () async {
        final decoded = decode(minData);

        expect(decoded.projectToken, 'mock-project-token');
        expect(decoded.authorizationToken, 'mock-auth-token');
        expect(decoded.projectMapping, null);
        expect(decoded.defaultProperties, null);
        expect(decoded.flushMaxRetries, null);
        expect(decoded.sessionTimeout, null);
        expect(decoded.automaticSessionTracking, null);
        expect(decoded.pushTokenTrackingFrequency, null);
        expect(decoded.requirePushAuthorization, null);
        expect(decoded.allowDefaultCustomerProperties, null);
        expect(decoded.advancedAuthEnabled, null);
        expect(decoded.inAppContentBlockPlaceholdersAutoLoad, null);
        expect(decoded.manualSessionAutoClose, null);
        expect(decoded.baseUrl, null);
        expect(decoded.android, null);
        expect(decoded.ios, null);
      });

      test('defaultSession', () async {
        final decoded = decode(defaultSession);

        expect(decoded.projectToken, 'mock-project-token');
        expect(decoded.authorizationToken, 'mock-auth-token');
        expect(decoded.baseUrl, 'http://mock.base.url.com');
        final mapping = decoded.projectMapping!;
        expect(mapping.length, 1);
        final bannerProjects = mapping[EventType.banner]!;
        expect(bannerProjects.length, 1);
        expect(bannerProjects.single.projectToken, 'other-project-token');
        expect(bannerProjects.single.authorizationToken, 'other-auth-token');
        expect(bannerProjects.single.baseUrl, null);
        final props = decoded.defaultProperties!;
        expect(props.length, 5);
        expect(props['string'], 'value');
        expect(props['boolean'], false);
        expect(props['number'], 3.14159);
        expect(props['array'], ["value1", "value2"]);
        expect(props['object'], {"key": "value"});
        expect(decoded.flushMaxRetries, 10);
        expect(decoded.sessionTimeout, 60.0);
        expect(decoded.automaticSessionTracking, true);
        expect(decoded.allowDefaultCustomerProperties, true);
        expect(decoded.advancedAuthEnabled, true);
        expect(decoded.inAppContentBlockPlaceholdersAutoLoad, ["mock-placeholder-1", "mock-placeholder-2"]);
        expect(decoded.pushTokenTrackingFrequency, TokenFrequency.daily);
        expect(decoded.requirePushAuthorization, true);
        expect(decoded.android != null, true);
        final android = decoded.android!;
        expect(android.automaticPushNotifications, true);
        expect(android.pushIcon, 12345);
        expect(android.pushAccentColor, 0xFF112233);
        expect(android.pushChannelName, 'mock-push-channel-name');
        expect(android.pushChannelDescription, 'mock-push-channel-description');
        expect(android.pushChannelId, 'mock-push-channel-id');
        expect(android.pushNotificationImportance,
            PushNotificationImportance.high);
        expect(android.httpLoggingLevel, HttpLoggingLevel.body);
        expect(android.appInboxDetailImageInset, 16);
        expect(android.allowWebViewCookies, true);
        expect(decoded.ios != null, true);
        final ios = decoded.ios!;
        expect(ios.requirePushAuthorization, false);
        expect(ios.appGroup, 'mock-app-group');
      });

      test('full', () async {
        final decoded = decode(fullData);

        expect(decoded.projectToken, 'mock-project-token');
        expect(decoded.authorizationToken, 'mock-auth-token');
        expect(decoded.baseUrl, 'http://mock.base.url.com');
        final mapping = decoded.projectMapping!;
        expect(mapping.length, 1);
        final bannerProjects = mapping[EventType.banner]!;
        expect(bannerProjects.length, 1);
        expect(bannerProjects.single.projectToken, 'other-project-token');
        expect(bannerProjects.single.authorizationToken, 'other-auth-token');
        expect(bannerProjects.single.baseUrl, null);
        final props = decoded.defaultProperties!;
        expect(props.length, 5);
        expect(props['string'], 'value');
        expect(props['boolean'], false);
        expect(props['number'], 3.14159);
        expect(props['array'], ["value1", "value2"]);
        expect(props['object'], {"key": "value"});
        expect(decoded.flushMaxRetries, 10);
        expect(decoded.sessionTimeout, 45.0);
        expect(decoded.automaticSessionTracking, true);
        expect(decoded.allowDefaultCustomerProperties, true);
        expect(decoded.advancedAuthEnabled, true);
        expect(decoded.inAppContentBlockPlaceholdersAutoLoad, ["mock-placeholder-1", "mock-placeholder-2"]);
        expect(decoded.pushTokenTrackingFrequency, TokenFrequency.daily);
        expect(decoded.requirePushAuthorization, true);
        expect(decoded.android != null, true);
        final android = decoded.android!;
        expect(android.automaticPushNotifications, true);
        expect(android.pushIcon, 12345);
        expect(android.pushAccentColor, 0xFF112233);
        expect(android.pushChannelName, 'mock-push-channel-name');
        expect(android.pushChannelDescription, 'mock-push-channel-description');
        expect(android.pushChannelId, 'mock-push-channel-id');
        expect(android.pushNotificationImportance,
            PushNotificationImportance.high);
        expect(android.httpLoggingLevel, HttpLoggingLevel.body);
        expect(android.appInboxDetailImageInset, 16);
        expect(android.allowWebViewCookies, true);
        expect(decoded.ios != null, true);
        final ios = decoded.ios!;
        expect(ios.requirePushAuthorization, false);
        expect(ios.appGroup, 'mock-app-group');
      });
    });
  });
}
