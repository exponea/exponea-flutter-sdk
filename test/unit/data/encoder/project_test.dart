import 'dart:convert';

import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExponeaProjectEncoder', () {
    final encode = ExponeaProjectEncoder.encode;
    final decode = ExponeaProjectEncoder.decode;

    group('encode', () {
      test('no baseUrl', () async {
        final project = ExponeaProject(
          projectToken: '1234567890',
          authorizationToken: '0987654321',
        );
        expect(
          json.encode(encode(project)),
          '{"projectToken":"1234567890","authorizationToken":"0987654321","baseUrl":null}',
        );
      });

      test('with baseUrl', () async {
        final project = ExponeaProject(
          projectToken: '1234567890',
          authorizationToken: '0987654321',
          baseUrl: 'http://a.b.c',
        );
        expect(
          json.encode(encode(project)),
          '{"projectToken":"1234567890","authorizationToken":"0987654321","baseUrl":"http://a.b.c"}',
        );
      });
    });

    group('decode', () {
      test('no baseUrl', () async {
        final expected = ExponeaProject(
          projectToken: '1234567890',
          authorizationToken: '0987654321',
        );
        final decoded = decode(json.decode(
          '{"projectToken":"1234567890","authorizationToken":"0987654321","baseUrl":null}',
        ));

        expect(decoded.projectToken, expected.projectToken);
        expect(decoded.authorizationToken, expected.authorizationToken);
        expect(decoded.baseUrl, expected.baseUrl);
      });

      test('with baseUrl', () async {
        final expected = ExponeaProject(
          projectToken: '1234567890',
          authorizationToken: '0987654321',
          baseUrl: 'http://a.b.c',
        );
        final decoded = decode(json.decode(
          '{"projectToken":"1234567890","authorizationToken":"0987654321","baseUrl":"http://a.b.c"}',
        ));

        expect(decoded.projectToken, expected.projectToken);
        expect(decoded.authorizationToken, expected.authorizationToken);
        expect(decoded.baseUrl, expected.baseUrl);
      });
    });
  });
}
