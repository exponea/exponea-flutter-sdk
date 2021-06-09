import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushActionTypeEncoder', () {
    final encode = PushActionTypeEncoder.encode;
    final decode = PushActionTypeEncoder.decode;

    test('encode', () async {
      expect(encode(PushActionType.app), 'app');
      expect(encode(PushActionType.deeplink), 'deeplink');
      expect(encode(PushActionType.web), 'web');
    });

    test('decode', () async {
      expect(decode('app'), PushActionType.app);
      expect(decode('deeplink'), PushActionType.deeplink);
      expect(decode('web'), PushActionType.web);
      expect(() => decode('foo'), throwsUnsupportedError);
    });
  });
}
