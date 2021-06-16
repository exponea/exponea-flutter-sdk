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
      body: ListView(
        children: [
          ListTile(
            title: ElevatedButton(
              onPressed: () => _checkIsConfigured(context),
              child: Text('Configured?'),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () => _getCustomerCookie(context),
              child: Text('Get customer cookie'),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () => _identifyCustomer(context),
              child: Text('Identify customer'),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () => _anonymize(context),
              child: Text('Anonymize'),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () => _getDefaultProps(context),
              child: Text('Get default properties'),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () => _setDefaultProps(context),
              child: Text('Set default properties'),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () => _getFlushMode(context),
              child: Text('Get flush mode'),
            ),
          ),
          ListTile(
            title: ValueListenableBuilder<FlushMode?>(
              valueListenable: _flushModeController,
              builder: (context, selectedMode, _) => Row(
                children: [
                  DropdownButton<FlushMode>(
                    value: selectedMode,
                    onChanged: (value) => _flushModeController.value = value,
                    items: FlushMode.values
                        .map(
                          (mode) => DropdownMenuItem<FlushMode>(
                            value: mode,
                            child: Text(mode.toString()),
                          ),
                        )
                        .toList(),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: (selectedMode != null)
                        ? () => _setFlushMode(context)
                        : null,
                    child: Text('Set flush mode'),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () => _flush(context),
              child: Text('Flush'),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () => _getFlushPeriod(context),
              child: Text('Get flush period'),
            ),
          ),
          ListTile(
            title: ValueListenableBuilder<int>(
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
                      onChanged: (value) =>
                          _flushPeriodController.value = value.toInt(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _setFlushPeriod(context),
                    child: Text('Set flush period'),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () => _trackEvent(context),
              child: Text('Track event'),
            ),
          ),
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (widget.config.automaticSessionTracking ?? true)
                        ? null
                        : () => _trackSessionStart(context),
                    child: Text('Track session start'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (widget.config.automaticSessionTracking ?? true)
                        ? null
                        : () => _trackSessionEnd(context),
                    child: Text('Track session end'),
                  ),
                ),
              ],
            ),
          ),
        ],
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
