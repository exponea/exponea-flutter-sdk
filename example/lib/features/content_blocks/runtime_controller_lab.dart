import 'dart:convert';

import 'package:exponea/exponea.dart';
import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/services/exponea_service.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/util/test_environment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _defaultDeadlineMs = 3000;
const _maxLogLines = 200;
const _lifecycleSettle = Duration(milliseconds: 3000);
const _lazyInvalidatePause = Duration(milliseconds: 500);
const _timeoutProbeDeadlineMs = 1;
const _firstCustomerId = 'user_a';
const _secondCustomerId = 'user_b';
const _emptyLog = 'Runtime controller results will appear here.';

enum _Scenario {
  prefetch('prefetch', 'Prefetch', 'btn_cb_runtime_prefetch'),
  availability('availability', 'Availability', 'btn_cb_runtime_availability'),
  eagerInvalidate(
    'eager invalidate',
    'Prefetch → eager invalidate → availability',
    'btn_cb_runtime_invalidate',
  ),
  happyPath('happy path'),
  postLoginCms('post-login CMS'),
  logout('logout', 'logout', 'btn_cb_runtime_logout'),
  availabilityTimeout('availability timeout'),
  anonymizeLifecycleProbe('anonymize lifecycle probe'),
  identitySwitch('identity switch'),
  lazyInvalidate('lazy invalidate');

  const _Scenario(this.logName, [String? title, this.semanticsId])
      : title = title ?? logName;

  final String logName;
  final String title;
  final String? semanticsId;
}

/// Port of the React Native "Runtime ICB Lab": drives
/// `inAppContentBlocksController` and logs every result in the RN format.
class RuntimeControllerLab extends StatefulWidget {
  const RuntimeControllerLab({super.key, required this.platformPlaceholderId});

  final String platformPlaceholderId;

  // Inputs survive lab unmounts (tab or screen changes) until the app restarts.
  static String? _lastIdsText;
  static String _lastDeadlineText = '$_defaultDeadlineMs';

  @visibleForTesting
  static void resetInputs() {
    _lastIdsText = null;
    _lastDeadlineText = '$_defaultDeadlineMs';
  }

  @override
  State<RuntimeControllerLab> createState() => _RuntimeControllerLabState();
}

class _RuntimeControllerLabState extends State<RuntimeControllerLab> {
  late final TextEditingController _idsController = TextEditingController(
    text: RuntimeControllerLab._lastIdsText ??
        'example_top, ${widget.platformPlaceholderId}',
  );
  late final TextEditingController _deadlineController =
      TextEditingController(text: RuntimeControllerLab._lastDeadlineText);

  bool _busy = false;
  final List<String> _logs = [];
  List<String> _mounted = const [];
  int _mountVersion = 0;

  ExponeaService get _service => ExponeaServiceScope.of(context);

  @override
  void dispose() {
    _idsController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  void _log(String message) {
    if (!mounted) return;
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceFirstMapped(
          RegExp(r'(\.\d{3})\d*Z$'),
          (match) => '${match[1]}Z',
        );
    setState(() {
      if (_logs.length >= _maxLogLines) _logs.removeAt(0);
      _logs.add('$timestamp $message');
    });
  }

  RuntimeInAppContentBlockController _requireController() {
    final controller = _service.inAppContentBlocksController;
    if (controller == null) throw StateError('SDK is not configured');
    return controller;
  }

  static String _encodeDecision(InAppContentBlockAvailabilityDecision decision) {
    return jsonEncode(switch (decision) {
      InAppContentBlockAvailabilityResolved(:final availability) => {
          'status': 'resolved',
          'availability': availability.name,
        },
      InAppContentBlockAvailabilityTimedOut() => {'status': 'timedOut'},
    });
  }

  static String _encodeSnapshot(Map<String, InAppContentBlockAvailability> snapshot) =>
      jsonEncode(snapshot.map((id, availability) => MapEntry(id, availability.name)));

  static String _describeError(Object error) => switch (error) {
        PlatformException(:final code, :final message) => message ?? code,
        StateError(:final message) => message,
        _ => error.toString(),
      };

  Future<void> _run(_Scenario scenario) async {
    if (_busy) return;
    final ids = _idsController.text
        .split(RegExp(r'[,\n]'))
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    final deadline = int.tryParse(_deadlineController.text.trim());
    if (ids.isEmpty || deadline == null || deadline < 0) {
      _log('WARN: Enter at least one placeholder ID and a non-negative deadline in milliseconds.');
      return;
    }
    final name = scenario.logName;
    setState(() => _busy = true);
    _log('BEGIN $name ids=${ids.join(', ')} deadline=${deadline}ms');
    try {
      final controller = _requireController();

      Future<void> prefetch() async {
        _log('prefetch: ${_encodeSnapshot(await _requireController().prefetch(ids))}');
      }

      Future<void> availability([int? timeout, List<String>? allIds]) async {
        final effectiveTimeout = timeout ?? deadline;
        for (final id in allIds ?? ids) {
          final decision = await _requireController().availability(id, effectiveTimeout);
          _log('availability($id, ${effectiveTimeout}ms): ${_encodeDecision(decision)}');
        }
      }

      Future<void> invalidate(InAppContentBlockInvalidateMode mode) async {
        await _requireController().invalidate(ids, 'example lab: $name', mode);
        _log('invalidate(${mode.name}): accepted; reload completion is checked separately');
      }

      void mount() {
        setState(() {
          _mountVersion++;
          _mounted = ids;
        });
        _log('Mount placeholders after prefetch; Flutter loads them when the platform view is created.');
      }

      Future<void> anonymize() async {
        _log('anonymize');
        await _service.anonymize();
      }

      Future<void> identify(String id) async {
        _log('identify registered=$id');
        await _service.identifyCustomer(customerIds: {'registered': id});
      }

      switch (scenario) {
        case _Scenario.prefetch:
          _log('prefetch snapshot: ${_encodeSnapshot(await controller.prefetch(ids, deadline))}');
        case _Scenario.availability:
          await availability();
        case _Scenario.eagerInvalidate:
          // Deliberately does what the docs warn against: invalidating right after a
          // ready prefetch discards the warmed content. The final availability shows
          // the reload; this is a diagnostic scenario, not an integration pattern.
          await prefetch();
          await invalidate(InAppContentBlockInvalidateMode.eager);
          await availability();
        case _Scenario.happyPath:
          await prefetch();
          mount();
        case _Scenario.postLoginCms:
          await identify(_firstCustomerId);
          await prefetch();
          mount();
        case _Scenario.logout:
          await prefetch();
          await anonymize();
          await prefetch();
        case _Scenario.availabilityTimeout:
          await invalidate(InAppContentBlockInvalidateMode.eager);
          // A warm/fast response can resolve even within 1ms; report the actual decision.
          await availability(_timeoutProbeDeadlineMs, ids.take(1).toList());
        case _Scenario.anonymizeLifecycleProbe:
          await prefetch();
          await anonymize();
          _log('Immediate post-anonymize prefetch');
          await prefetch();
          await Future<void>.delayed(_lifecycleSettle);
          _log('Settled post-anonymize prefetch');
          await prefetch();
        case _Scenario.identitySwitch:
          await identify(_firstCustomerId);
          await prefetch();
          await identify(_secondCustomerId);
          await prefetch();
        case _Scenario.lazyInvalidate:
          await prefetch();
          await invalidate(InAppContentBlockInvalidateMode.lazy);
          _log('Pause ${_lazyInvalidatePause.inMilliseconds}ms without accessing content');
          await Future<void>.delayed(_lazyInvalidatePause);
          await prefetch();
      }
      _log('END $name');
    } catch (error) {
      _log('FAILED $name: ${_describeError(error)}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _placeholder(String id) {
    if (isFlutterWidgetTest) {
      return _PlaceholderStub(label: 'CB placeholder: $id');
    }
    return InAppContentBlockPlaceholder(
      placeholderId: id,
      onMessageShown: (_, __) => _log('VIEW $id: shown'),
      onNoMessageFound: (_) => _log('VIEW $id: no message found'),
      onError: (_, __, message) => _log('VIEW $id: error $message'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logText = _logs.isEmpty ? _emptyLog : _logs.join('\n');
    const bold = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Runtime ICB Lab', style: bold),
        const Text(
          'ExponeaPlugin().inAppContentBlocksController',
          style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: BrandColors.grey600),
        ),
        const SizedBox(height: 8),
        Text(
          'Controller: ${_service.inAppContentBlocksController != null ? 'present' : 'not configured'}',
        ),
        const SizedBox(height: 8),
        const Text('Placeholder IDs (comma-separated or one per line)'),
        TextField(
          key: const ValueKey('cb_runtime_ids_input'),
          controller: _idsController,
          enabled: !_busy,
          minLines: 1,
          maxLines: 4,
          autocorrect: false,
          onChanged: (value) => RuntimeControllerLab._lastIdsText = value,
        ),
        const SizedBox(height: 8),
        const Text('Availability / prefetch snapshot deadline (milliseconds)'),
        TextField(
          key: const ValueKey('cb_runtime_deadline_input'),
          controller: _deadlineController,
          enabled: !_busy,
          keyboardType: TextInputType.number,
          onChanged: (value) => RuntimeControllerLab._lastDeadlineText = value,
        ),
        const SizedBox(height: 8),
        const Text('Identity scenarios change the SDK customer to user_a, user_b or anonymous.'),
        const SizedBox(height: 8),
        for (final scenario in _Scenario.values) ...[
          _LabButton(
            semanticsId: scenario.semanticsId,
            label: scenario.title,
            onPressed: _busy ? null : () => _run(scenario),
          ),
          const SizedBox(height: 8),
        ],
        const Text(
          'Happy path and post-login mount warmed content. Lazy invalidate waits '
          '500ms before fetching again. Timeout uses a 1ms deadline.',
        ),
        const SizedBox(height: 8),
        for (final id in _mounted)
          // A new key per mount creates a new platform view, which loads fresh content.
          Column(
            key: ValueKey('$_mountVersion:$id'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Placeholder: $id'),
              _placeholder(id),
              const SizedBox(height: 8),
            ],
          ),
        Semantics(
          identifier: 'lbl_cb_runtime_status',
          label: logText,
          value: logText,
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: BrandColors.grey200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: BrandColors.grey300),
            ),
            child: SelectableText(
              logText,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: BrandColors.grey600),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _LabButton(label: 'Clear log', onPressed: () => setState(_logs.clear)),
        const SizedBox(height: 8),
        // Copies instead of RN's share sheet; the example app has no share dependency.
        _LabButton(
          label: 'Copy log',
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: _logs.isEmpty ? 'No runtime ICB results yet.' : _logs.join('\n')),
            );
            if (!context.mounted) return;
            ScaffoldMessenger.maybeOf(context)
                ?.showSnackBar(const SnackBar(content: Text('Log copied to clipboard')));
          },
        ),
      ],
    );
  }
}

class _LabButton extends StatelessWidget {
  const _LabButton({this.semanticsId, required this.label, required this.onPressed});

  final String? semanticsId;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      button: true,
      label: label,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: BrandColors.yellow,
          foregroundColor: BrandColors.black,
          disabledBackgroundColor: BrandColors.yellow.withOpacity(0.5),
          disabledForegroundColor: BrandColors.grey600,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          minimumSize: const Size.fromHeight(44),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        child: Text(label),
      ),
    );
  }
}

class _PlaceholderStub extends StatelessWidget {
  const _PlaceholderStub({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      color: BrandColors.grey200,
      child: Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
    );
  }
}
