import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _plugin = ExponeaPlugin();

typedef ConfigCallback = void Function(ExponeaConfiguration configuration);

class ConfigPage extends StatefulWidget {
  final ConfigCallback doneCallback;

  const ConfigPage({
    Key? key,
    required this.doneCallback,
  }) : super(key: key);

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  static const _spKeyProject = 'project_token';
  static const _spKeyAuth = 'auth_token';
  static const _spKeyBaseUrl = 'base_url';
  static const _spKeySessionTracking = 'session_tracking';

  final _loading = ValueNotifier(false);
  late final TextEditingController _projectTokenController;
  late final TextEditingController _authTokenController;
  late final TextEditingController _baseUrlController;
  late final ValueNotifier<bool> _sessionTrackingController;

  @override
  void initState() {
    _projectTokenController = TextEditingController(text: '');
    _authTokenController = TextEditingController(text: '');
    _baseUrlController = TextEditingController(text: '');
    _sessionTrackingController = ValueNotifier(true);
    SharedPreferences.getInstance().then((sp) async {
      _projectTokenController.text = sp.getString(_spKeyProject) ?? '';
      _authTokenController.text = sp.getString(_spKeyAuth) ?? '';
      _baseUrlController.text = sp.getString(_spKeyBaseUrl) ?? '';
      _sessionTrackingController.value =
          sp.getBool(_spKeySessionTracking) ?? true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exponea Demo Configuration'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                ListTile(
                  title: TextField(
                    controller: _projectTokenController,
                    decoration: const InputDecoration(
                      labelText: 'Project Token',
                    ),
                  ),
                ),
                ListTile(
                  title: TextField(
                    controller: _authTokenController,
                    decoration: const InputDecoration(labelText: 'Auth Token'),
                  ),
                ),
                ListTile(
                  title: TextField(
                    controller: _baseUrlController,
                    decoration: const InputDecoration(labelText: 'Base URL'),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _sessionTrackingController,
                  builder: (context, enabled, _) => SwitchListTile(
                    title: const Text('Automatic Session Tracking'),
                    value: enabled,
                    onChanged: (value) =>
                        _sessionTrackingController.value = value,
                  ),
                ),
                const Spacer(),
                ValueListenableBuilder<bool>(
                  valueListenable: _loading,
                  builder: (context, loading, _) => loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _configure(context),
                          child: const Text('Configure'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _configure(BuildContext context) async {
    _loading.value = true;
    final projectToken = _projectTokenController.text.trim();
    final authToken = _authTokenController.text.trim();
    final rawBaseUrl = _baseUrlController.text.trim();
    final baseUrl = rawBaseUrl.isNotEmpty ? rawBaseUrl : null;
    final sessionTracking = _sessionTrackingController.value;

    final sp = await SharedPreferences.getInstance();
    await sp.setString(_spKeyProject, projectToken);
    await sp.setString(_spKeyAuth, authToken);
    await sp.setString(_spKeyBaseUrl, rawBaseUrl);
    await sp.setBool(_spKeySessionTracking, sessionTracking);

    final config = ExponeaConfiguration(
      projectToken: projectToken,
      authorizationToken: authToken,
      baseUrl: baseUrl,
      pushTokenTrackingFrequency: TokenFrequency.everyLaunch,
      flushMaxRetries: 11,
      automaticSessionTracking: sessionTracking,
      sessionTimeout: 22.5,
      defaultProperties: const {
        'string': 'string',
        'double': 1.2,
        'int': 10,
        'bool': true,
      },
      allowDefaultCustomerProperties: false,
      // projectMapping: {
      //   EventType.banner: [
      //     ExponeaProject(projectToken: '1', authorizationToken: '11'),
      //   ],
      //   EventType.campaignClick: [
      //     ExponeaProject(projectToken: '2', authorizationToken: '22'),
      //   ],
      // },
      android: const AndroidExponeaConfiguration(
        automaticPushNotifications: true,
        httpLoggingLevel: HttpLoggingLevel.body,
        pushChannelDescription: 'test-channel-desc',
        pushChannelId: 'test-channel-id',
        pushChannelName: 'test-channel-name',
        pushNotificationImportance: PushNotificationImportance.normal,
        // pushAccentColor: 10,
        // pushIcon: 11,
      ),
      ios: const IOSExponeaConfiguration(
        requirePushAuthorization: true,
        appGroup: 'group.com.exponea.ExponeaSDK-Example2',
      ),
    );
    try {
      final configured = await _plugin.configure(config);
      if (!configured) {
        const snackBar = SnackBar(
          content: Text('SDK was already configured'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      _plugin.setLogLevel(LogLevel.verbose);
      widget.doneCallback.call(config);
    } on PlatformException catch (err) {
      final snackBar = SnackBar(
        content: Text('Configuration failed: $err'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    _loading.value = false;
  }
}
