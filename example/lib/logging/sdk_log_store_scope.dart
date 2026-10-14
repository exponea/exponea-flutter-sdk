import 'package:exponea_example/logging/sdk_log_store.dart';
import 'package:flutter/widgets.dart';

class SdkLogStoreScope extends InheritedNotifier<SdkLogStore> {
  const SdkLogStoreScope({
    super.key,
    required SdkLogStore store,
    required super.child,
  }) : super(notifier: store);

  static SdkLogStore of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<SdkLogStoreScope>();
    assert(scope != null, 'SdkLogStoreScope not found');
    return scope!.notifier!;
  }
}
