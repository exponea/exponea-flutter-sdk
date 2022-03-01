import 'dart:async';

import 'package:exponea_example/page/config.dart';
import 'package:exponea_example/page/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription? _linkSub;

  @override
  void initState() {
    _handleInitialLink();
    _handleIncomingLinks();
    super.initState();
  }

  Future<void> _handleInitialLink() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _showSnackBarMessage('App opened with link: $initialLink');
      }
    } on PlatformException catch (err) {
      // ignore: avoid_print
      print('initialLink: $err');
    }
  }

  void _handleIncomingLinks() {
    _linkSub = linkStream.listen((String? link) {
      _showSnackBarMessage('App resumed with link: $link');
    }, onError: (err) {
      _showSnackBarMessage('App resume with link failed: $err');
    });
  }

  void _showSnackBarMessage(String text) {
    final snackBar = SnackBar(content: Text(text));
    _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(
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
      builder: (context, child) => child!,
    );
  }
}
