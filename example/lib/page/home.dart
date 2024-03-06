import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'in_app_cb_page.dart';

final _plugin = ExponeaPlugin();

class HomePage extends StatefulWidget {
  final ExponeaConfiguration config;

  const HomePage({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _flushPeriodController = ValueNotifier<int>(5);
  final _flushModeController = ValueNotifier<FlushMode?>(FlushMode.manual);
  final _logLevelController = ValueNotifier<LogLevel?>(LogLevel.info);
  final _pushController = ValueNotifier<String>('- none -');
  late final StreamSubscription<OpenedPush> _openedPushSub;
  late final StreamSubscription<ReceivedPush> _receivedPushSub;
  late final StreamSubscription<InAppMessageAction> _inAppMessageActionSub;

  @override
  void initState() {
    _openedPushSub = _plugin.openedPushStream.listen(_onPushEvent);
    _receivedPushSub = _plugin.receivedPushStream.listen(_onPushEvent);
    _inAppMessageActionSub = _plugin
        .inAppMessageActionStream()
        .listen(_onInAppMessageActionEvent);
    super.initState();
  }

  @override
  void dispose() {
    _openedPushSub.cancel();
    _receivedPushSub.cancel();
    _inAppMessageActionSub.cancel();
    _flushPeriodController.dispose();
    _flushModeController.dispose();
    _pushController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exponea Demo'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Push events'),
                  subtitle: ValueListenableBuilder<String>(
                    valueListenable: _pushController,
                    builder: (context, value, _) => Text(value),
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _requestPushAuthorization(context),
                    child: const Text('Request Push Authorization'),
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _checkIsConfigured(context),
                    child: const Text('Configured?'),
                  ),
                ),
                ListTile(
                  title: const Text('Customer'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _getCustomerCookie(context),
                        child: const Text('Get Cookie'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _identifyCustomer(context),
                        child: const Text('Identify'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _anonymize(context),
                        child: const Text('Anonymize'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Default Properties'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _getDefaultProps(context),
                        child: const Text('Get'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _setDefaultProps(context),
                        child: const Text('Set'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Fetch'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _fetchConsents(context),
                        child: const Text('Consents'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _fetchRecommendations(context),
                        child: const Text('Recommendations'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Flush Mode'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _getFlushMode(context),
                        child: const Text('Get'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _setFlushMode(context),
                        child: const Text('Set'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ValueListenableBuilder<FlushMode?>(
                          valueListenable: _flushModeController,
                          builder: (context, selectedMode, _) =>
                              DropdownButton<FlushMode>(
                            value: selectedMode,
                            onChanged: (value) =>
                                _flushModeController.value = value,
                            items: FlushMode.values
                                .map(
                                  (mode) => DropdownMenuItem<FlushMode>(
                                    value: mode,
                                    child: Text(mode.toString()),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _flush(context),
                    child: const Text('Flush'),
                  ),
                ),
                ListTile(
                  title: const Text('Flush Period'),
                  subtitle: Row(
                    children: [
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _setFlushPeriod(context),
                        child: const Text('Set'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ValueListenableBuilder<int>(
                          valueListenable: _flushPeriodController,
                          builder: (context, period, _) => Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Text('$period min'),
                              ),
                              Expanded(
                                child: Slider(
                                  value: period.toDouble(),
                                  min: 1,
                                  max: 60,
                                  onChanged: (value) => _flushPeriodController
                                      .value = value.toInt(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Track'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _trackEvent(context),
                        child: const Text('Event'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            (widget.config.automaticSessionTracking ?? true)
                                ? null
                                : () => _trackSessionStart(context),
                        child: const Text('Session Start'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            (widget.config.automaticSessionTracking ?? true)
                                ? null
                                : () => _trackSessionEnd(context),
                        child: const Text('Session End'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Trigger in-app message by event:'),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            _triggerInAppMessage(context, 'test_msg_modal'),
                        child: const Text('Modal'),
                      ),
                      ElevatedButton(
                        onPressed: () => _triggerInAppMessage(
                            context, 'test_msg_fullscreen'),
                        child: const Text('Fullscreen'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _triggerInAppMessage(context, 'test_msg_slide'),
                        child: const Text('Slide-in'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _triggerInAppMessage(context, 'test_msg_alert'),
                        child: const Text('Alert'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Log Level'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _getLogLevel(context),
                        child: const Text('Get'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ValueListenableBuilder<LogLevel?>(
                          valueListenable: _logLevelController,
                          builder: (context, selected, _) => Row(
                            children: [
                              DropdownButton<LogLevel>(
                                value: selected,
                                onChanged: (value) =>
                                    _logLevelController.value = value,
                                items: LogLevel.values
                                    .map(
                                      (level) => DropdownMenuItem<LogLevel>(
                                        value: level,
                                        child: Text(level.toString()),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('App Inbox'),
                  subtitle: Row(
                      children: const [
                        SizedBox(width: 150, height: 50, child: AppInboxProvider()),
                      ]
                  )
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _fetchAppInbox(context),
                    child: const Text('Fetch all'),
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _fetchAppInboxItem(context),
                    child: const Text('Fetch first'),
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _markFirstAppInboxItemAsRead(context),
                    child: const Text('Mark first as read'),
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const InAppCbPage())),
                    child: const Text('In App CB Example Page'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchAppInbox(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.fetchAppInbox();
      });

  Future<void> _fetchAppInboxItem(BuildContext context) =>
      _runAndShowResult(context, () async {
        var messages = await _plugin.fetchAppInbox();
        if (messages.isEmpty) return "EMPTY APPINBOX";
        return messages[0];
      });

  Future<void> _markFirstAppInboxItemAsRead(BuildContext context) =>
      _runAndShowResult(context, () async {
        var messages = await _plugin.fetchAppInbox();
        if (messages.isEmpty) return "EMPTY APPINBOX";
        return await _plugin.markAppInboxAsRead(messages.first);
      });

  Future<void> _checkIsConfigured(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.isConfigured();
      });

  Future<void> _getCustomerCookie(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.getCustomerCookie();
      });

  Future<void> _identifyCustomer(BuildContext context) =>
      _runAndShowResult(context, () async {
        const email = 'test-user-1@test.com';
        const customerIds = {'registered': email};
        const customer = Customer(ids: customerIds);
        final sp = await SharedPreferences.getInstance();
        var customerIdsString = json.encode(customerIds);
        await sp.setString("customer_ids", customerIdsString);
        await _plugin.identifyCustomer(customer);
        return email;
      });

  Future<void> _anonymize(BuildContext context) =>
      _runAndShowResult(context, () async {
        await _plugin.anonymize();
      });

  Future<void> _getDefaultProps(BuildContext context) =>
      _runAndShowResult(context, () async {
        final props = await _plugin.getDefaultProperties();
        final values = props
            .map((key, value) => MapEntry(key, '$key: $value'))
            .values
            .join(', ');
        return '{ $values }';
      });

  Future<void> _setDefaultProps(BuildContext context) =>
      _runAndShowResult(context, () async {
        await _plugin.setDefaultProperties({
          'default_prop_1': 'test',
        });
      });

  Future<void> _fetchConsents(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.fetchConsents();
      });

  Future<void> _fetchRecommendations(BuildContext context) =>
      _runAndShowResult(context, () async {
        const options = RecommendationOptions(
          id: '60db38da9887668875998c49',
          fillWithRandom: true,
          items: {},
        );
        return await _plugin.fetchRecommendations(options);
      });

  Future<void> _getFlushMode(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.getFlushMode();
      });

  Future<void> _setFlushMode(BuildContext context) =>
      _runAndShowResult(context, () async {
        final mode = _flushModeController.value!;
        return await _plugin.setFlushMode(mode);
      });

  Future<void> _flush(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.flushData();
      });

  Future<void> _getFlushPeriod(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.getFlushPeriod();
      });

  Future<void> _setFlushPeriod(BuildContext context) =>
      _runAndShowResult(context, () async {
        final period = Duration(minutes: _flushPeriodController.value);
        return await _plugin.setFlushPeriod(period);
      });

  Future<void> _trackEvent(BuildContext context) =>
      _runAndShowResult(context, () async {
        const event = Event(
          name: 'event_name',
          properties: {
            'property': '5s',
            'int': 12,
            'double': 34.56,
            'string': 'test'
          },
        );
        await _plugin.trackEvent(event);
      });

  Future<void> _triggerInAppMessage(BuildContext context, String name) =>
      _runAndShowResult(context, () async {
        await _plugin.trackEvent(Event(name: name));
      });

  Future<void> _trackSessionStart(BuildContext context) =>
      _runAndShowResult(context, () async {
        await _plugin.trackSessionStart();
      });

  Future<void> _trackSessionEnd(BuildContext context) =>
      _runAndShowResult(context, () async {
        await _plugin.trackSessionEnd();
      });

  Future<void> _getLogLevel(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.getLogLevel();
      });

  Future<void> _setLogLevel(BuildContext context) =>
      _runAndShowResult(context, () async {
        final level = _logLevelController.value!;
        return await _plugin.setLogLevel(level);
      });

  Future<void> _requestPushAuthorization(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.requestPushAuthorization();
      });

  Future<void> _runAndShowResult(
    BuildContext context,
    Future<dynamic> Function() block,
  ) async {
    String msg;
    try {
      final res = await block.call();
      if (res != null) {
        msg = 'Done: $res';
      } else {
        msg = 'Done';
      }
    } on PlatformException catch (err) {
      msg = 'Error: $err';
    }
    final snackBar = SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onPushEvent(dynamic push) {
    _pushController.value = '$push\nat: ${DateTime.now().toIso8601String()}';
  }

  void _onInAppMessageActionEvent(InAppMessageAction action) {
    print('received in-app action: $action');
  }

}
