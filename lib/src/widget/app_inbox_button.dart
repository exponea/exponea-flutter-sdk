import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppInboxProvider extends StatelessWidget {
  const AppInboxProvider({Key? key}) : super(key: key);

  static const String viewType = 'FluffView';

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android){
      return const AndroidView(viewType: viewType);
    } else if (defaultTargetPlatform == TargetPlatform.iOS){
      return const UiKitView(viewType: viewType);
    } else {
      return const SizedBox.shrink();
    }
  }
}
