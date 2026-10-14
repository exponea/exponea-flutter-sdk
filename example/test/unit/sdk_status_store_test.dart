import 'package:exponea_example/services/sdk_status_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SdkStatusStore', () {
    test('defaults to notInitialized', () {
      final store = SdkStatusStore();
      expect(store.state, SdkLifecycleState.notInitialized);
    });

    test('set updates state and notifies listeners', () {
      final store = SdkStatusStore();
      var notifications = 0;
      store.addListener(() => notifications++);

      store.set(SdkLifecycleState.anonymous);
      expect(store.state, SdkLifecycleState.anonymous);
      expect(notifications, 1);

      store.set(SdkLifecycleState.identified);
      expect(store.state, SdkLifecycleState.identified);
      expect(notifications, 2);
    });

    test('setting the same value does not notify', () {
      final store = SdkStatusStore();
      store.set(SdkLifecycleState.anonymous);

      var notifications = 0;
      store.addListener(() => notifications++);
      store.set(SdkLifecycleState.anonymous);

      expect(notifications, 0);
      expect(store.state, SdkLifecycleState.anonymous);
    });
  });
}
