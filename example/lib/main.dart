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
      theme: ThemeData.from(
        colorScheme: ColorScheme.light(
          primary: Colors.amber,
          secondary: Colors.blueAccent,
        ),
      ),
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
