import 'package:exponea/exponea.dart';
import 'package:exponea_example/main.dart';
import 'package:exponea_example/model/home_page_args.dart';
import 'package:exponea_example/util/local_jwt_generator.dart';
import 'package:exponea_example/util/sdk_setup_state.dart';
import 'package:exponea_example/util/stream_auth_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _plugin = ExponeaPlugin();

enum IntegrationMode { project, stream }

class ConfigPage extends StatefulWidget {
  const ConfigPage({
    super.key,
  });

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  static const _platform = MethodChannel('com.exponea.example/utils');

  static const _spKeyMode = 'integration_mode';
  static const _spKeyProject = 'project_token';
  static const _spKeyAuth = 'auth_token';
  static const _spKeyAdvancedAuth = 'advanced_auth_token';
  static const _spKeyStreamId = 'stream_id';
  static const _spKeyJwtKeyId = 'jwt_key_id';
  static const _spKeyJwtSecret = 'jwt_secret';
  static const _spKeyRegisteredId = 'registered_id';
  static const _spKeyBaseUrl = 'base_url';
  static const _spKeySessionTracking = 'session_tracking';
  static const _spKeyApplicationId = 'application_id';

  final _loading = ValueNotifier(false);
  IntegrationMode _mode = IntegrationMode.project;

  late final TextEditingController _projectTokenController;
  late final TextEditingController _authTokenController;
  late final TextEditingController _advancedAuthTokenController;
  late final TextEditingController _streamIdController;
  late final TextEditingController _jwtKeyIdController;
  late final TextEditingController _jwtSecretController;
  late final TextEditingController _registeredIdController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _applicationIdController;
  late final ValueNotifier<bool> _sessionTrackingController;

  Future<int?> getAndroidPushIcon() async {
    try {
      return await _platform.invokeMethod<int?>('getAndroidPushIcon');
    } catch (e) {
      return null;
    }
  }

  bool get _canConfigure {
    final baseUrl = _baseUrlController.text.trim();
    if (baseUrl.isEmpty) {
      return false;
    }
    if (_mode == IntegrationMode.project) {
      return _projectTokenController.text.trim().isNotEmpty &&
          _authTokenController.text.trim().isNotEmpty;
    }
    final streamId = _streamIdController.text.trim();
    final jwtKeyId = _jwtKeyIdController.text.trim();
    final jwtSecret = _jwtSecretController.text.trim();
    final jwtPairValid = jwtKeyId.isEmpty == jwtSecret.isEmpty;
    return streamId.isNotEmpty && jwtPairValid;
  }

  @override
  void initState() {
    StreamAuthListener.stop();
    _projectTokenController = TextEditingController(text: '');
    _authTokenController = TextEditingController(text: '');
    _advancedAuthTokenController = TextEditingController(text: '');
    _streamIdController = TextEditingController(text: '');
    _jwtKeyIdController = TextEditingController(text: '');
    _jwtSecretController = TextEditingController(text: '');
    _registeredIdController = TextEditingController(text: '');
    _baseUrlController = TextEditingController(text: '');
    _applicationIdController = TextEditingController(text: '');
    _sessionTrackingController = ValueNotifier(true);
    SharedPreferences.getInstance().then((sp) async {
      _mode = sp.getString(_spKeyMode) == 'stream'
          ? IntegrationMode.stream
          : IntegrationMode.project;
      _projectTokenController.text = sp.getString(_spKeyProject) ?? '';
      _authTokenController.text = sp.getString(_spKeyAuth) ?? '';
      _advancedAuthTokenController.text =
          sp.getString(_spKeyAdvancedAuth) ?? '';
      _streamIdController.text = sp.getString(_spKeyStreamId) ?? '';
      _jwtKeyIdController.text = sp.getString(_spKeyJwtKeyId) ?? '';
      _jwtSecretController.text = sp.getString(_spKeyJwtSecret) ?? '';
      _registeredIdController.text = sp.getString(_spKeyRegisteredId) ?? '';
      _baseUrlController.text = sp.getString(_spKeyBaseUrl) ?? '';
      _applicationIdController.text = sp.getString(_spKeyApplicationId) ?? '';
      _sessionTrackingController.value =
          sp.getBool(_spKeySessionTracking) ?? true;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _projectTokenController.dispose();
    _authTokenController.dispose();
    _advancedAuthTokenController.dispose();
    _streamIdController.dispose();
    _jwtKeyIdController.dispose();
    _jwtSecretController.dispose();
    _registeredIdController.dispose();
    _baseUrlController.dispose();
    _applicationIdController.dispose();
    _sessionTrackingController.dispose();
    _loading.dispose();
    super.dispose();
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                SegmentedButton<IntegrationMode>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor:
                        Theme.of(context).colorScheme.primary,
                    selectedForegroundColor:
                        Theme.of(context).colorScheme.onPrimary,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: IntegrationMode.project,
                      label: Text('Project Config'),
                    ),
                    ButtonSegment(
                      value: IntegrationMode.stream,
                      label: Text('Stream Config'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) {
                    setState(() => _mode = selection.first);
                  },
                ),
                const SizedBox(height: 12),
                if (_mode == IntegrationMode.project) ...[
                  ListTile(
                    title: TextField(
                      controller: _projectTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Project Token',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      controller: _authTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Auth Token',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      controller: _advancedAuthTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Advanced Auth key (optional)',
                      ),
                    ),
                  ),
                ] else ...[
                  ListTile(
                    title: TextField(
                      controller: _streamIdController,
                      decoration: const InputDecoration(
                        labelText: 'Stream ID',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      controller: _jwtKeyIdController,
                      decoration: const InputDecoration(
                        labelText: 'JWT Key ID (optional)',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      controller: _jwtSecretController,
                      decoration: const InputDecoration(
                        labelText: 'JWT Secret (optional)',
                      ),
                      obscureText: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
                ListTile(
                  title: TextField(
                    controller: _registeredIdController,
                    decoration: const InputDecoration(
                      labelText: 'Registered ID (optional)',
                    ),
                  ),
                ),
                ListTile(
                  title: TextField(
                    controller: _baseUrlController,
                    decoration: const InputDecoration(labelText: 'Base URL'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                ListTile(
                  title: TextField(
                    controller: _applicationIdController,
                    decoration: const InputDecoration(
                      labelText: 'Application ID',
                    ),
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
                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: _loading,
                  builder: (context, loading, _) => loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed:
                              _canConfigure ? () => _configure(context) : null,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Configure'),
                        ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => _clearLocalCustomerData(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Clear Local Data'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<ExponeaConfiguration> _buildConfiguration(int? pushIcon) async {
    final rawBaseUrl = _baseUrlController.text.trim();
    final baseUrl = rawBaseUrl.isNotEmpty ? rawBaseUrl : null;
    final sessionTracking = _sessionTrackingController.value;
    final applicationId = _applicationIdController.text.trim();
    final advancedAuthToken = _advancedAuthTokenController.text.trim();
    const pushTokenTrackingFrequency = TokenFrequency.everyLaunch;
    const requirePushAuthorization = true;
    const flushMaxRetries = 11;
    const sessionTimeout = 22.5;
    const defaultProperties = {
      'string': 'string',
      'double': 1.2,
      'int': 10,
      'bool': true,
      'fontWeight': 'normal',
    };
    const allowDefaultCustomerProperties = false;
    final android = AndroidExponeaConfiguration(
      automaticPushNotifications: true,
      httpLoggingLevel: HttpLoggingLevel.body,
      pushChannelDescription: 'test-channel-desc',
      pushChannelId: 'test-channel-id',
      pushChannelName: 'test-channel-name',
      pushNotificationImportance: PushNotificationImportance.normal,
      pushAccentColor: 0xFFFFD500,
      pushIcon: pushIcon,
    );
    const ios = IOSExponeaConfiguration(
      // Must match Runner + ExampleNotificationService entitlements and
      // ExampleNotificationService/NotificationService.swift (push delivery tracking).
      appGroup: 'group.com.exponea.sdk.example',
    );
    const inAppContentBlockPlaceholdersAutoLoad = [
      'example_top',
      'example_list',
    ];
    final resolvedApplicationId =
        applicationId.isNotEmpty ? applicationId : null;

    if (_mode == IntegrationMode.stream) {
      return ExponeaConfiguration(
        integrationConfig: StreamIntegrationConfig(
          streamId: _streamIdController.text.trim(),
          baseUrl: baseUrl!,
        ),
        pushTokenTrackingFrequency: pushTokenTrackingFrequency,
        requirePushAuthorization: requirePushAuthorization,
        flushMaxRetries: flushMaxRetries,
        automaticSessionTracking: sessionTracking,
        sessionTimeout: sessionTimeout,
        defaultProperties: defaultProperties,
        allowDefaultCustomerProperties: allowDefaultCustomerProperties,
        android: android,
        ios: ios,
        inAppContentBlockPlaceholdersAutoLoad:
            inAppContentBlockPlaceholdersAutoLoad,
        applicationId: resolvedApplicationId,
      );
    }

    return ExponeaConfiguration(
      integrationConfig: ProjectIntegrationConfig(
        projectToken: _projectTokenController.text.trim(),
        authorizationToken: _authTokenController.text.trim(),
        baseUrl: baseUrl!,
      ),
      pushTokenTrackingFrequency: pushTokenTrackingFrequency,
      requirePushAuthorization: requirePushAuthorization,
      flushMaxRetries: flushMaxRetries,
      automaticSessionTracking: sessionTracking,
      sessionTimeout: sessionTimeout,
      defaultProperties: defaultProperties,
      allowDefaultCustomerProperties: allowDefaultCustomerProperties,
      advancedAuthEnabled: advancedAuthToken.isNotEmpty,
      android: android,
      ios: ios,
      inAppContentBlockPlaceholdersAutoLoad:
          inAppContentBlockPlaceholdersAutoLoad,
      applicationId: resolvedApplicationId,
    );
  }

  Future<CustomerIdentifier?> _buildCustomerIdentifier({
    required bool isStream,
  }) async {
    final registeredId = _registeredIdController.text.trim();
    if (registeredId.isEmpty) {
      return null;
    }
    final customerIds = {'registered': registeredId};
    await SdkSetupState.setCustomerIds(customerIds);
    if (isStream && LocalJwtTokenGenerator.instance.isConfigured) {
      final token = LocalJwtTokenGenerator.instance.generateToken(customerIds);
      return CustomerIdentity(
        customerIds: customerIds,
        sdkAuthToken: token,
      );
    }
    return CustomerIdentity(customerIds: customerIds);
  }

  Future<void> _configure(BuildContext context) async {
    final pushIcon = await getAndroidPushIcon();
    _loading.value = true;

    final isStream = _mode == IntegrationMode.stream;
    final projectToken = _projectTokenController.text.trim();
    final authToken = _authTokenController.text.trim();
    final advancedAuthToken = _advancedAuthTokenController.text.trim();
    final rawBaseUrl = _baseUrlController.text.trim();
    final sessionTracking = _sessionTrackingController.value;
    final applicationId = _applicationIdController.text.trim();
    final jwtKeyId = _jwtKeyIdController.text.trim();
    final jwtSecret = _jwtSecretController.text.trim();

    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _spKeyMode,
      isStream ? 'stream' : 'project',
    );
    await sp.setString(_spKeyProject, projectToken);
    await sp.setString(_spKeyAuth, authToken);
    await sp.setString(_spKeyAdvancedAuth, advancedAuthToken);
    await sp.setString(_spKeyStreamId, _streamIdController.text.trim());
    await sp.setString(_spKeyJwtKeyId, jwtKeyId);
    await sp.setString(_spKeyJwtSecret, jwtSecret);
    await sp.setString(_spKeyRegisteredId, _registeredIdController.text.trim());
    await sp.setString(_spKeyBaseUrl, rawBaseUrl);
    await sp.setBool(_spKeySessionTracking, sessionTracking);
    await sp.setString(_spKeyApplicationId, applicationId);

    if (isStream && jwtKeyId.isNotEmpty && jwtSecret.isNotEmpty) {
      LocalJwtTokenGenerator.instance.configure(
        secret: jwtSecret,
        kid: jwtKeyId,
      );
    }

    await SdkSetupState.reset();
    final customerIdentifier =
        await _buildCustomerIdentifier(isStream: isStream);

    try {
      final config = await _buildConfiguration(pushIcon);
      await _plugin.setAppInboxProvider(
        AppInboxStyle(
          appInboxButton: SimpleButtonStyle(
            backgroundColor: 'rgb(245, 195, 68)',
            borderRadius: '10dp',
            showIcon: true,
            enabled: true,
            textSize: '12dp',
            textOverride: 'App Inbox',
            textWeight: 'normal',
            textColor: 'white',
          ),
          detailView: DetailViewStyle(
            button: SimpleButtonStyle(
              backgroundColor: 'red',
            ),
            title: TextViewStyle(
              textSize: '20sp',
              textOverride: 'TEST',
              textWeight: 'bold',
              textColor: 'rgba(100, 100, 100, 1.0)',
            ),
          ),
          listView: ListScreenStyle(
            errorTitle: TextViewStyle(
              textColor: 'red',
            ),
            errorMessage: TextViewStyle(
              textColor: 'red',
            ),
            list: AppInboxListViewStyle(
              backgroundColor: 'blue',
              item: AppInboxListItemStyle(
                backgroundColor: 'yellow',
                content: TextViewStyle(
                  textColor: '#FFF',
                  textWeight: '700',
                ),
              ),
            ),
          ),
        ),
      );
      if (isStream && LocalJwtTokenGenerator.instance.isConfigured) {
        StreamAuthListener.start();
      }
      final configured = await _plugin.configure(
        config,
        customerIdentifier: customerIdentifier,
      );
      if (!configured && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SDK was already configured')),
        );
      }
      _plugin.setLogLevel(LogLevel.verbose);
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home,
          (route) => false,
          arguments: HomePageArgs(
            config: config,
            isStreamConfig: isStream,
          ),
        );
      }
    } on PlatformException catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Configuration failed: $err')),
        );
      }
    } catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Configuration failed: $err')),
        );
      }
    } finally {
      _loading.value = false;
    }
  }

  Future<void> _clearLocalCustomerData(BuildContext context) async {
    try {
      await _plugin.clearLocalCustomerData(
        appGroup: 'group.com.exponea.sdk.example',
      );
      await SdkSetupState.reset();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sdk has been cleared')),
        );
      }
    } on PlatformException catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Clearing local customer data $err')),
        );
      }
    }
  }
}
