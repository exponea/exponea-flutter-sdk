import 'package:exponea_example/services/exponea_service.dart';
import 'package:flutter/widgets.dart';

class ExponeaServiceScope extends InheritedWidget {
  const ExponeaServiceScope({
    super.key,
    required this.service,
    required super.child,
  });

  final ExponeaService service;

  static ExponeaService of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ExponeaServiceScope>();
    assert(scope != null, 'ExponeaServiceScope not found');
    return scope!.service;
  }

  @override
  bool updateShouldNotify(ExponeaServiceScope oldWidget) {
    return service != oldWidget.service;
  }
}
