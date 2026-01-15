import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:exponea/exponea.dart';
import 'package:exponea_example/page/config.dart';
import 'package:exponea_example/page/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


final _plugin = ExponeaPlugin();

class Routes {
  static const String config = '/';
  static const String home = '/home';
}

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
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _linkSub;

  @override
  void initState() {
    _handleInitialLink();
    _handleIncomingLinks();
    super.initState();
  }

  Future<void> _handleInitialLink() async {
    try {
      final initialLink = await AppLinks().getInitialLink();
      if (initialLink != null) {
        _showSnackBarMessage('App opened with link: $initialLink');
        print('App opened with link: $initialLink');
        _handleStopIntegrationDeepLinks(initialLink.toString());
      }
    } on PlatformException catch (err) {
      // ignore: avoid_print
      print('initialLink: $err');
    }
  }

  void _handleIncomingLinks() {
    _linkSub = AppLinks().stringLinkStream.listen((String link) {
      _showSnackBarMessage('App resumed with link: $link');
      print('App resumed with link: $link');
      _handleStopIntegrationDeepLinks(link);
    }, onError: (err) {
      _showSnackBarMessage('App resume with link failed: $err');
    });
  }

  Future<void> _handleStopIntegrationDeepLinks(String link) async {
    if (link.toLowerCase().contains("stopandcontinue")) {
      print("Stop SDK and Continue: $link");
      await _plugin.stopIntegration();
    } else if (link.toLowerCase().contains("stopandrestart")) {
      print("Stop SDK and Restart: $link");
       await _plugin.stopIntegration();
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(Routes.config, (route) => false);
    }
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
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(
          primary: Colors.amber,
          secondary: Colors.blueAccent,
        ),
      ),
      initialRoute: Routes.config,
      onGenerateRoute: _onGenerateRoute,
      builder: (context, child) => child!,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.config:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ConfigPage(),
        );

      case Routes.home:
        final config = settings.arguments as ExponeaConfiguration;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => HomePage(config: config),
        );

      default:
        return null;
    }
  }
}
