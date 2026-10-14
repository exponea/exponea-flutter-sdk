import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/services/exponea_service.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/widgets/action_feedback.dart';
import 'package:exponea/exponea.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlushingScreen extends StatefulWidget {
  const FlushingScreen({super.key});

  @override
  State<FlushingScreen> createState() => _FlushingScreenState();
}

enum _FlushTab { flushMode, flushPeriod, logLevel }

class _FlushingScreenState extends State<FlushingScreen> {
  FlushMode? _flushMode = FlushMode.immediate;
  // Android FlushingUiState defaults to IMMEDIATE before the first Get tap.
  String _currentMode = 'IMMEDIATE';
  String _currentPeriod = '…';
  String _currentLogLevel = '…';
  /// Suite-facing INFO/DEBUG on iOS after mapping native set to VERBOSE.
  /// Cleared when the user picks a native-supported level.
  String? _iosLogLevelDisplayOverride;
  bool _flushing = false;
  _FlushTab _selectedTab = _FlushTab.flushMode;

  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAll());
  }

  ExponeaService get _service => ExponeaServiceScope.of(context);

  String _flushModeLabel(FlushMode mode) {
    return switch (mode) {
      FlushMode.immediate => 'IMMEDIATE',
      FlushMode.period => 'PERIOD',
      FlushMode.appClose => 'APP_CLOSE',
      FlushMode.manual => 'MANUAL',
    };
  }

  String _logLevelLabel(LogLevel level) {
    return switch (level) {
      LogLevel.off => 'OFF',
      LogLevel.error => 'ERROR',
      LogLevel.warning => 'WARN',
      LogLevel.info => 'INFO',
      LogLevel.debug => 'DEBUG',
      LogLevel.verbose => 'VERBOSE',
    };
  }

  String _periodStatusText() {
    if (_flushMode != FlushMode.period) {
      return 'Current period: — (requires PERIOD mode)';
    }
    return 'Current period: $_currentPeriod seconds';
  }

  String _periodModeHint(FlushMode mode) {
    return 'Flush period requires PERIOD mode (current: ${_flushModeLabel(mode)}). Tap PERIOD first.';
  }

  String _manualFlushHint(FlushMode mode) {
    return 'Manual flush requires MANUAL mode on Android (current: ${_flushModeLabel(mode)}). Tap MANUAL first.';
  }

  Future<void> _refreshMode({bool showFeedback = false}) async {
    try {
      final mode = await _service.getFlushMode();
      if (!mounted) {
        return;
      }
      _flushMode = mode;
      final label = _flushModeLabel(mode);
      setState(() => _currentMode = label);
      if (showFeedback) {
        showActionSnackBar(context, 'Current mode: $label');
      }
      await _refreshPeriod();
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      if (showFeedback) {
        showActionSnackBar(context, error.message ?? 'Could not read flush mode');
      }
    }
  }

  Future<void> _refreshPeriod({bool showFeedback = false}) async {
    final mode = _flushMode;
    if (mode != FlushMode.period) {
      if (mounted) {
        setState(() => _currentPeriod = '—');
        if (showFeedback && mode != null) {
          showActionSnackBar(context, _periodModeHint(mode));
        }
      }
      return;
    }

    try {
      final period = await _service.getFlushPeriod();
      if (!mounted) {
        return;
      }
      final seconds = period.inSeconds;
      setState(() => _currentPeriod = '$seconds');
      if (showFeedback) {
        showActionSnackBar(context, 'Current period: $seconds seconds');
      }
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _currentPeriod = '—');
      if (showFeedback) {
        showActionSnackBar(
          context,
          error.message ?? 'Could not read flush period',
        );
      }
    }
  }

  Future<void> _refreshLogLevel({bool showFeedback = false}) async {
    final override = _iosLogLevelDisplayOverride;
    if (override != null) {
      if (!mounted) {
        return;
      }
      setState(() => _currentLogLevel = override);
      if (showFeedback) {
        showActionSnackBar(context, 'Current log level: $override');
      }
      return;
    }
    final level = await _service.getLogLevel();
    if (!mounted) {
      return;
    }
    final label = _logLevelLabel(level);
    setState(() => _currentLogLevel = label);
    if (showFeedback) {
      showActionSnackBar(context, 'Current log level: $label');
    }
  }

  Future<void> _refreshAll() async {
    await _refreshMode();
    await _refreshLogLevel();
  }

  Future<void> _setFlushMode(FlushMode mode) async {
    try {
      await _service.setFlushMode(mode);
      await _refreshMode();
      if (mounted) {
        showActionSnackBar(context, 'Flush mode → ${mode.name}');
      }
    } on PlatformException catch (error) {
      if (mounted) {
        showActionSnackBar(context, error.message ?? 'Could not set flush mode');
      }
    }
  }

  Future<void> _setFlushPeriod(int seconds) async {
    final mode = _flushMode;
    if (mode != FlushMode.period) {
      if (mounted && mode != null) {
        showActionSnackBar(context, _periodModeHint(mode));
      }
      return;
    }

    try {
      await _service.setFlushPeriod(Duration(seconds: seconds));
      await _refreshPeriod();
      if (mounted) {
        showActionSnackBar(context, 'Flush period → $seconds seconds');
      }
    } on PlatformException catch (error) {
      if (mounted) {
        showActionSnackBar(context, error.message ?? 'Could not set flush period');
      }
    }
  }

  Future<void> _setLogLevel(LogLevel level) async {
    // iOS native Exponea (and Flutter LogLevelEncoder) only support
    // OFF / ERROR / WARN / VERBOSE — INFO and DEBUG throw. Map to VERBOSE and
    // keep suite-facing labels INFO/DEBUG so Appium matches Android buttons.
    final mapIosInfoDebug =
        defaultTargetPlatform == TargetPlatform.iOS &&
        (level == LogLevel.info || level == LogLevel.debug);
    final nativeLevel = mapIosInfoDebug ? LogLevel.verbose : level;
    final suiteLabel = _logLevelLabel(level);

    try {
      await _service.setLogLevel(nativeLevel);
      if (!mounted) {
        return;
      }
      setState(() {
        _iosLogLevelDisplayOverride = mapIosInfoDebug ? suiteLabel : null;
        _currentLogLevel = suiteLabel;
      });
      showActionSnackBar(context, 'Log level → $suiteLabel');
    } on PlatformException catch (error) {
      if (mounted) {
        showActionSnackBar(context, error.message ?? 'Could not set log level');
      }
    }
  }

  Future<void> _flushData() async {
    final mode = _flushMode;
    if (defaultTargetPlatform == TargetPlatform.android &&
        mode != FlushMode.manual) {
      if (mounted && mode != null) {
        showActionSnackBar(context, _manualFlushHint(mode));
      }
      return;
    }

    setState(() => _flushing = true);
    try {
      await _service.flushData();
      if (!mounted) {
        return;
      }
      await _showFlushDialog(success: true);
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      await _showFlushDialog(success: false, message: error.message);
    } finally {
      if (mounted) {
        setState(() => _flushing = false);
      }
    }
  }

  Future<void> _showFlushDialog({
    required bool success,
    String? message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Semantics(
          identifier: 'lbl_flush_result_title',
          child: Text(success ? 'Flush successful' : 'Flush failed'),
        ),
        content: !success && message != null && message.isNotEmpty
            ? Text(message)
            : null,
        actions: [
          Semantics(
            identifier: 'btn_flush_result_ok',
            button: true,
            label: 'Ok',
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlushModeCard() {
    return _SectionCard(
      title: 'Flush Mode',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GetButton(
            semanticsId: 'btn_get_flush_mode',
            label: 'Get Flush Mode',
            onPressed: () => _refreshMode(showFeedback: true),
          ),
          const SizedBox(height: 8),
          _StatusBox(
            text: 'Current mode: $_currentMode',
            semanticsId: 'lbl_current_flush_mode',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _YellowButton(
                  semanticsId: 'btn_flush_mode_immediate',
                  label: 'IMMEDIATE',
                  onPressed: () => _setFlushMode(FlushMode.immediate),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _YellowButton(
                  semanticsId: 'btn_flush_mode_period',
                  label: 'PERIOD',
                  onPressed: () => _setFlushMode(FlushMode.period),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _YellowButton(
                  semanticsId: 'btn_flush_mode_app_close',
                  label: 'APP_CLOSE',
                  onPressed: () => _setFlushMode(FlushMode.appClose),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _YellowButton(
                  semanticsId: 'btn_flush_mode_manual',
                  label: 'MANUAL',
                  onPressed: () => _setFlushMode(FlushMode.manual),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlushPeriodCard() {
    return _SectionCard(
      title: 'Flush Period',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GetButton(
            semanticsId: 'btn_get_flush_period',
            label: 'Get Flush Period',
            onPressed: () => _refreshPeriod(showFeedback: true),
          ),
          const SizedBox(height: 8),
          _StatusBox(
            text: _periodStatusText(),
            semanticsId: 'lbl_current_flush_period',
          ),
          if (_flushMode != null && _flushMode != FlushMode.period) ...[
            const SizedBox(height: 6),
            Text(
              _periodModeHint(_flushMode!),
              style: const TextStyle(
                fontSize: 12,
                color: BrandColors.grey600,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _YellowButton(
                  semanticsId: 'btn_flush_period_30',
                  label: '30 seconds',
                  onPressed: () => _setFlushPeriod(30),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _YellowButton(
                  semanticsId: 'btn_flush_period_60',
                  label: '60 seconds',
                  onPressed: () => _setFlushPeriod(60),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_flushing)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(minHeight: 4),
            ),
          _YellowButton(
            semanticsId: 'btn_flush_data',
            label: 'Flush Data',
            onPressed: _flushing ? null : _flushData,
          ),
        ],
      ),
    );
  }

  Widget _buildLogLevelCard() {
    return _SectionCard(
      title: 'Log Level',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GetButton(
            semanticsId: 'btn_get_log_level',
            label: 'Get Log Level',
            onPressed: () => _refreshLogLevel(showFeedback: true),
          ),
          const SizedBox(height: 8),
          _StatusBox(
            text: 'Current log level: $_currentLogLevel',
            semanticsId: 'lbl_current_log_level',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _YellowButton(
                semanticsId: 'btn_log_off',
                label: 'OFF',
                onPressed: () => _setLogLevel(LogLevel.off),
              ),
              _YellowButton(
                semanticsId: 'btn_log_error',
                label: 'ERROR',
                onPressed: () => _setLogLevel(LogLevel.error),
              ),
              _YellowButton(
                semanticsId: 'btn_log_warn',
                label: 'WARN',
                onPressed: () => _setLogLevel(LogLevel.warning),
              ),
              _YellowButton(
                semanticsId: 'btn_log_info',
                label: 'INFO',
                onPressed: () => _setLogLevel(LogLevel.info),
              ),
              _YellowButton(
                semanticsId: 'btn_log_debug',
                label: 'DEBUG',
                onPressed: () => _setLogLevel(LogLevel.debug),
              ),
              _YellowButton(
                semanticsId: 'btn_log_verbose',
                label: 'VERBOSE',
                onPressed: () => _setLogLevel(LogLevel.verbose),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BrandColors.grey100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: _TabRow(
              selected: _selectedTab,
              onSelected: (tab) => setState(() => _selectedTab = tab),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: switch (_selectedTab) {
                _FlushTab.flushMode => _buildFlushModeCard(),
                _FlushTab.flushPeriod => _buildFlushPeriodCard(),
                _FlushTab.logLevel => _buildLogLevelCard(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabRow extends StatelessWidget {
  const _TabRow({
    required this.selected,
    required this.onSelected,
  });

  final _FlushTab selected;
  final ValueChanged<_FlushTab> onSelected;

  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  Widget _tab(String semanticsId, String label, _FlushTab tab) {
    final isSelected = selected == tab;
    return Expanded(
      child: Semantics(
        identifier: semanticsId,
        button: true,
        selected: isSelected,
        label: label,
        // iOS Appium activates this node; without onTap the tab click is a no-op.
        onTap: () => onSelected(tab),
        child: OutlinedButton(
          onPressed: () => onSelected(tab),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? BrandColors.yellow : BrandColors.white,
            foregroundColor: BrandColors.black,
            shape: _shape,
            minimumSize: const Size.fromHeight(44),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tab('btn_flush_tab_flush_mode', 'Flush Mode', _FlushTab.flushMode),
        const SizedBox(width: 6),
        _tab('btn_flush_tab_flush_period', 'Flush Period', _FlushTab.flushPeriod),
        const SizedBox(width: 6),
        _tab('btn_flush_tab_log_level', 'Log Level', _FlushTab.logLevel),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: BrandColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: BrandColors.grey300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.text, this.semanticsId});

  final String text;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BrandColors.grey200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrandColors.grey300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
    final id = semanticsId;
    if (id == null) {
      return box;
    }
    // iOS Wait Until Page Contains / Get Text need the string on this node;
    // nested Text alone is unreliable under XCUITest + Flutter Semantics.
    return Semantics(
      identifier: id,
      label: text,
      value: text,
      excludeSemantics: true,
      child: box,
    );
  }
}

class _GetButton extends StatelessWidget {
  const _GetButton({
    required this.semanticsId,
    required this.label,
    required this.onPressed,
  });

  final String semanticsId;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      button: true,
      label: label,
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: BrandColors.white,
            foregroundColor: BrandColors.black,
            side: const BorderSide(color: BrandColors.black),
            shape: _FlushingScreenState._buttonShape,
            minimumSize: const Size.fromHeight(44),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _YellowButton extends StatelessWidget {
  const _YellowButton({
    required this.semanticsId,
    required this.label,
    required this.onPressed,
  });

  final String semanticsId;
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
          shape: _FlushingScreenState._buttonShape,
          minimumSize: const Size.fromHeight(44),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
