import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('IntegrationConfig', () {
    const encode = IntegrationConfigEncoder.encode;
    const decode = IntegrationConfigEncoder.decode;

    final data = readMapData('integration_config');
    test('check data', () async {
      expect(data.length, 6);
    });
    final noData = data[0];
    final projectMinData = data[1];
    final projectWithBaseUrlData = data[2];
    final streamMinData = data[3];
    final streamWithBaseUrlData = data[4];
    final ambiguousData = data[5];

    group('encode', () {
      test('project minimal', () async {
        const config = ProjectIntegrationConfig(
          projectToken: 'mock-project-token',
          authorizationToken: 'mock-auth-token',
        );
        expect(encode(config), projectMinData);
      });

      test('project with baseUrl', () async {
        const config = ProjectIntegrationConfig(
          projectToken: 'mock-project-token',
          authorizationToken: 'mock-auth-token',
          baseUrl: 'https://api.exponea.com',
        );
        expect(encode(config), projectWithBaseUrlData);
      });

      test('stream minimal', () async {
        const config = StreamIntegrationConfig(streamId: 'mock-stream-id');
        expect(encode(config), streamMinData);
      });

      test('stream with baseUrl', () async {
        const config = StreamIntegrationConfig(
          streamId: 'mock-stream-id',
          baseUrl: 'https://stream.exponea.com',
        );
        expect(encode(config), streamWithBaseUrlData);
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

      test('project minimal', () async {
        final decoded = decode(projectMinData);
        expect(decoded, isA<ProjectIntegrationConfig>());
        final project = decoded as ProjectIntegrationConfig;
        expect(project.projectToken, 'mock-project-token');
        expect(project.authorizationToken, 'mock-auth-token');
        expect(project.baseUrl, null);
      });

      test('project with baseUrl', () async {
        final decoded = decode(projectWithBaseUrlData);
        expect(decoded, isA<ProjectIntegrationConfig>());
        final project = decoded as ProjectIntegrationConfig;
        expect(project.projectToken, 'mock-project-token');
        expect(project.authorizationToken, 'mock-auth-token');
        expect(project.baseUrl, 'https://api.exponea.com');
      });

      test('stream minimal', () async {
        final decoded = decode(streamMinData);
        expect(decoded, isA<StreamIntegrationConfig>());
        final stream = decoded as StreamIntegrationConfig;
        expect(stream.streamId, 'mock-stream-id');
        expect(stream.baseUrl, null);
      });

      test('stream with baseUrl', () async {
        final decoded = decode(streamWithBaseUrlData);
        expect(decoded, isA<StreamIntegrationConfig>());
        final stream = decoded as StreamIntegrationConfig;
        expect(stream.streamId, 'mock-stream-id');
        expect(stream.baseUrl, 'https://stream.exponea.com');
      });

      test('ambiguous streamId and projectToken', () async {
        try {
          decode(ambiguousData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(
            err.message,
            'integrationConfig cannot contain both streamId and projectToken',
          );
        } catch (err) {
          fail('No other errors');
        }
      });
    });

    group('round-trip', () {
      test('project', () async {
        const original = ProjectIntegrationConfig(
          projectToken: 'mock-project-token',
          authorizationToken: 'mock-auth-token',
          baseUrl: 'https://api.exponea.com',
        );
        final decoded = decode(encode(original));
        expect(decoded, isA<ProjectIntegrationConfig>());
        final project = decoded as ProjectIntegrationConfig;
        expect(project.projectToken, original.projectToken);
        expect(project.authorizationToken, original.authorizationToken);
        expect(project.baseUrl, original.baseUrl);
      });

      test('stream', () async {
        const original = StreamIntegrationConfig(
          streamId: 'mock-stream-id',
          baseUrl: 'https://stream.exponea.com',
        );
        final decoded = decode(encode(original));
        expect(decoded, isA<StreamIntegrationConfig>());
        final stream = decoded as StreamIntegrationConfig;
        expect(stream.streamId, original.streamId);
        expect(stream.baseUrl, original.baseUrl);
      });
    });
  });
}
