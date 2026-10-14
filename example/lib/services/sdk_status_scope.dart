import 'package:exponea_example/services/sdk_status_store.dart';
import 'package:flutter/widgets.dart';

class SdkStatusScope extends InheritedNotifier<SdkStatusStore> {
  const SdkStatusScope({
    super.key,
    required SdkStatusStore store,
    required super.child,
  }) : super(notifier: store);

  static SdkStatusStore of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<SdkStatusScope>();
    assert(scope != null, 'SdkStatusScope not found');
    return scope!.notifier!;
  }
}
