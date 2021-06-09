import 'dart:async';

import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

final _plugin = ExponeaPlugin();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exponea Example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => _configure(context),
            child: Text('Configure'),
          ),
          ElevatedButton(
            onPressed: () => _checkIsConfigured(context),
            child: Text('Configured?'),
          ),
        ],
      ),
    );
  }

  Future<void> _configure(BuildContext context) async {
    final configMinimal = ExponeaConfiguration(
      projectToken: '0987654321',
      authorizationToken: '1234567890',
    );
    final configFull = ExponeaConfiguration(
      projectToken: '0987654321',
      authorizationToken: '1234567890',
      baseUrl: 'https://test.base.url',
      pushTokenTrackingFrequency: TokenFrequency.everyLaunch,
      flushMaxRetries: 11,
      automaticSessionTracking: true,
      sessionTimeout: 22.5,
      defaultProperties: {
        'string': 'string',
        'double': 1.2,
        'int': 10,
        'bool': true,
      },
      projectMapping: {
        EventType.banner: [
          ExponeaProject(projectToken: '1', authorizationToken: '11'),
        ],
        EventType.campaignClick: [
          ExponeaProject(projectToken: '2', authorizationToken: '22'),
        ],
      },
      android: AndroidExponeaConfiguration(
        automaticPushNotifications: false,
        httpLoggingLevel: HttpLoggingLevel.body,
        pushChannelDescription: 'test-channel-desc',
        pushChannelId: 'test-channel-id',
        pushChannelName: 'test-channel-name',
        pushNotificationImportance: PushNotificationImportance.normal,
        pushAccentColor: 10,
        pushIcon: 11,
      ),
      ios: null,
    );
    String msg;
    try {
      await _plugin.configure(configFull);
      msg = 'Configuration complete';
    } on PlatformException catch (err) {
      msg = 'Configuration failed: $err';
    }
    final snackBar = SnackBar(
      content: Text(msg),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _checkIsConfigured(BuildContext context) async {
    final configured = await _plugin.isConfigured();
    final snackBar = SnackBar(
      content: Text('Configured: $configured'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
