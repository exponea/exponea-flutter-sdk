import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfigureRequest.isBaseUrlValid', () {
    ConfigureRequest req(String baseUrl) => ConfigureRequest(
          mode: IntegrationMode.project,
          baseUrl: baseUrl,
        );

    test('empty string is invalid', () {
      expect(req('').isBaseUrlValid, isFalse);
    });

    test('plain text is invalid', () {
      expect(req('not-a-url').isBaseUrlValid, isFalse);
    });

    test('missing scheme is invalid', () {
      expect(req('api.example.com').isBaseUrlValid, isFalse);
    });

    test('ftp scheme is invalid', () {
      expect(req('ftp://api.example.com').isBaseUrlValid, isFalse);
    });

    test('http URL is valid', () {
      expect(req('http://api.example.com').isBaseUrlValid, isTrue);
    });

    test('https URL is valid', () {
      expect(req('https://api.example.com').isBaseUrlValid, isTrue);
    });

    test('https URL with path is valid', () {
      expect(req('https://api.example.com/v2').isBaseUrlValid, isTrue);
    });
  });

  group('ConfigureRequest.isProjectValid', () {
    test('invalid URL makes project config invalid even with all tokens', () {
      const req = ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'not-a-url',
        projectToken: 'token',
        authorizationToken: 'auth',
      );
      expect(req.isProjectValid, isFalse);
    });

    test('valid URL + tokens gives valid project config', () {
      const req = ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'https://api.example.com',
        projectToken: 'token',
        authorizationToken: 'auth',
      );
      expect(req.isProjectValid, isTrue);
    });
  });

  group('ConfigureRequest.isStreamValid', () {
    test('invalid URL makes stream config invalid even with stream id', () {
      const req = ConfigureRequest(
        mode: IntegrationMode.stream,
        baseUrl: 'not-a-url',
        streamId: 'stream-id',
      );
      expect(req.isStreamValid, isFalse);
    });

    test('valid URL + streamId gives valid stream config', () {
      const req = ConfigureRequest(
        mode: IntegrationMode.stream,
        baseUrl: 'https://api.example.com',
        streamId: 'stream-id',
      );
      expect(req.isStreamValid, isTrue);
    });
  });
}
