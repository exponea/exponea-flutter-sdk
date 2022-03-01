import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('ExponeaProject', () {
    const encode = ExponeaProjectEncoder.encode;
    const decode = ExponeaProjectEncoder.decode;

    final data = readMapData('project');
    test('check data', () async {
      expect(data.length, 5);
    });
    final noData = data[0];
    final noAuthTokenData = data[1];
    final noBaseUrlData = data[2];
    final nullBaseUrlData = data[3];
    final fullData = data[4];

    group('encode', () {
      test('no baseUrl', () async {
        const project = ExponeaProject(
          projectToken: '1234567890',
          authorizationToken: '0987654321',
        );
        expect(encode(project), noBaseUrlData);
      });

      test('with baseUrl', () async {
        const project = ExponeaProject(
          projectToken: '1234567890',
          authorizationToken: '0987654321',
          baseUrl: 'http://a.b.c',
        );
        expect(encode(project), fullData);
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

      test('no auth token', () async {
        try {
          decode(noAuthTokenData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(err.message, 'authorizationToken is required!');
        } catch (err) {
          fail('No other errors');
        }
      });

      test('no baseUrl', () async {
        const expected = ExponeaProject(
          projectToken: '1234567890',
          authorizationToken: '0987654321',
        );
        final decoded = decode(noBaseUrlData);

        expect(decoded.projectToken, expected.projectToken);
        expect(decoded.authorizationToken, expected.authorizationToken);
        expect(decoded.baseUrl, expected.baseUrl);
      });

      test('null baseUrl', () async {
        const expected = ExponeaProject(
          projectToken: '1234567890',
          authorizationToken: '0987654321',
        );
        final decoded = decode(nullBaseUrlData);

        expect(decoded.projectToken, expected.projectToken);
        expect(decoded.authorizationToken, expected.authorizationToken);
        expect(decoded.baseUrl, expected.baseUrl);
      });

      test('with baseUrl', () async {
        const expected = ExponeaProject(
          projectToken: '1234567890',
          authorizationToken: '0987654321',
          baseUrl: 'http://a.b.c',
        );
        final decoded = decode(fullData);

        expect(decoded.projectToken, expected.projectToken);
        expect(decoded.authorizationToken, expected.authorizationToken);
        expect(decoded.baseUrl, expected.baseUrl);
      });
    });
  });
}
