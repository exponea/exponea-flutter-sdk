import 'package:flutter/material.dart';

import 'page/config.dart';
import 'page/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => ConfigPage(
          doneCallback: (config) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(config: config),
              ),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
