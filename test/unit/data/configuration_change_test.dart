import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('ExponeaConfigurationChange', () {
    const encode = ExponeaConfigurationChangeEncoder.encode;
    const decode = ExponeaConfigurationChangeEncoder.decode;

    final data = readMapData('configuration_change');
    test('check data', () async {
      expect(data.length, 4);
    });
    final noData = data[0];
    final minData = data[1];
    final withBaseUrlData = data[2];
    final fullData = data[3];

    group('encode', () {
      test('minimal', () async {
        const change = ExponeaConfigurationChange(
          project: ExponeaProject(
            projectToken: 'mock-project-token',
            authorizationToken: 'mock-auth-token',
          ),
        );

        expect(encode(change), minData);
      });

      test('with base url', () async {
        const change = ExponeaConfigurationChange(
          project: ExponeaProject(
            projectToken: 'mock-project-token',
            authorizationToken: 'mock-auth-token',
            baseUrl: 'http://mock.base.url.com',
          ),
        );

        expect(encode(change), withBaseUrlData);
      });

      test('full', () async {
        const change = ExponeaConfigurationChange(
          project: ExponeaProject(
            projectToken: 'mock-project-token',
            authorizationToken: 'mock-auth-token',
            baseUrl: 'http://mock.base.url.com',
          ),
          mapping: {
            EventType.payment: [
              ExponeaProject(
                projectToken: 'other-project-token',
                authorizationToken: 'other-auth-token',
              ),
            ],
          },
        );

        expect(encode(change), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        final decoded = decode(noData);

        expect(decoded.project != null, false);
        expect(decoded.mapping != null, false);
      });

      test('minimal', () async {
        final decoded = decode(minData);

        expect(decoded.project != null, true);
        expect(decoded.project!.projectToken, 'mock-project-token');
        expect(decoded.project!.authorizationToken, 'mock-auth-token');
        expect(decoded.project!.baseUrl, null);
        expect(decoded.mapping != null, false);
      });

      test('with base url', () async {
        final decoded = decode(withBaseUrlData);

        expect(decoded.project != null, true);
        expect(decoded.project!.projectToken, 'mock-project-token');
        expect(decoded.project!.authorizationToken, 'mock-auth-token');
        expect(decoded.project!.baseUrl, 'http://mock.base.url.com');
        expect(decoded.mapping != null, false);
      });

      test('full', () async {
        final decoded = decode(fullData);

        expect(decoded.project != null, true);
        expect(decoded.project!.projectToken, 'mock-project-token');
        expect(decoded.project!.authorizationToken, 'mock-auth-token');
        expect(decoded.project!.baseUrl, 'http://mock.base.url.com');
        expect(decoded.mapping != null, true);
        final mapping = decoded.mapping!;
        expect(mapping.length, 1);
        final projectList = mapping[EventType.payment]!;
        expect(projectList.length, 1);
        expect(projectList.single.projectToken, 'other-project-token');
        expect(projectList.single.authorizationToken, 'other-auth-token');
        expect(projectList.single.baseUrl, null);
      });
    });
  });
}
