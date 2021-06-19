import 'dart:math';

import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  void dispose() {
    _flushPeriodController.dispose();
    _flushModeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exponea Demo'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: ListView(
              children: [
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _checkIsConfigured(context),
                    child: Text('Configured?'),
                  ),
                ),
                ListTile(
                  title: Text('Customer'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _getCustomerCookie(context),
                        child: Text('Get Cookie'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _identifyCustomer(context),
                        child: Text('Identify'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _anonymize(context),
                        child: Text('Anonymize'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('Default Properties'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _getDefaultProps(context),
                        child: Text('Get'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _setDefaultProps(context),
                        child: Text('Set'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('Fetch'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _fetchConsents(context),
                        child: Text('Consents'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _fetchRecommendations(context),
                        child: Text('Recommendations'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('Flush Mode'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _getFlushMode(context),
                        child: Text('Get'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _setFlushMode(context),
                        child: Text('Set'),
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
                    child: Text('Flush'),
                  ),
                ),
                ListTile(
                  title: Text('Flush Period'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _getFlushPeriod(context),
                        child: Text('Get'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _setFlushPeriod(context),
                        child: Text('Set'),
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
                  title: Text('Track'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _trackEvent(context),
                        child: Text('Event'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            (widget.config.automaticSessionTracking ?? true)
                                ? null
                                : () => _trackSessionStart(context),
                        child: Text('Session Start'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            (widget.config.automaticSessionTracking ?? true)
                                ? null
                                : () => _trackSessionEnd(context),
                        child: Text('Session End'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('Trigger in-app message by event:'),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            _triggerInAppMessage(context, 'test_msg_modal'),
                        child: Text('Modal'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _triggerInAppMessage(context, 'test_msg_fullscreen'),
                        child: Text('Fullscreen'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _triggerInAppMessage(context, 'test_msg_slide'),
                        child: Text('Slide-in'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _triggerInAppMessage(context, 'test_msg_alert'),
                        child: Text('Alert'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        final email = 'user.${Random().nextInt(10000)}@test.com';
        final customer = Customer(
          ids: {
            'registered': email,
          },
        );
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
          items: {
          }
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
        final event = Event(
          name: 'test_name',
          properties: {
            'bool': true,
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

  Future<void> _runAndShowResult(
    BuildContext context,
    Future<dynamic> block(),
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
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
