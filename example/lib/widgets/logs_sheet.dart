import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/logging/log_record.dart';
import 'package:exponea_example/logging/sdk_log_bridge.dart';
import 'package:exponea_example/logging/sdk_log_store_scope.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/widgets/example_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _emptyLogsMessage =
    'No logs yet. Trigger an SDK action to populate.';

Future<void> showLogsSheet(BuildContext context) {
  return showExampleBottomSheet(
    context,
    child: const _LogsSheetBody(),
  );
}

class _LogsSheetBody extends StatefulWidget {
  const _LogsSheetBody();

  @override
  State<_LogsSheetBody> createState() => _LogsSheetBodyState();
}

class _LogsSheetBodyState extends State<_LogsSheetBody> {
  SdkLogFilter _filter = SdkLogFilter.all;

  String _formatTime(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    String three(int value) => value.toString().padLeft(3, '0');
    return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}.'
        '${three(time.millisecond)}';
  }

  List<DisplayLogEntry> _visibleLogs(BuildContext context) {
    final service = ExponeaServiceScope.of(context);
    final store = SdkLogStoreScope.of(context);
    final merged = mergeLogEntries(
      sdkRecords: store.records,
      appLogs: service.logs,
    );
    return filterDisplayLogs(merged, _filter);
  }

  Future<void> _copyLogs(List<DisplayLogEntry> logs) async {
    final text = logs
        .map(
          (entry) =>
              '${entry.level.shortLabel} ${_formatTime(entry.time)} ${entry.tag}: ${entry.message}',
        )
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }

  Future<void> _clearLogs() async {
    ExponeaServiceScope.of(context).clearLogs();
    SdkLogStoreScope.of(context).clear();
    await SdkLogBridge.clearNative();
    if (!mounted) {
      return;
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SdkLogStoreScope.of(context),
      builder: (context, _) {
        final logs = _visibleLogs(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LogsHeader(
              onCopy: () => _copyLogs(logs),
              onClear: _clearLogs,
            ),
            _LogsFilterBar(
              selected: _filter,
              onSelected: (filter) => setState(() => _filter = filter),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: BrandColors.grey300,
            ),
            Expanded(
              child: ColoredBox(
                color: BrandColors.white,
                child: logs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Semantics(
                            identifier: 'lbl_logs_empty',
                            label: _emptyLogsMessage,
                            child: const Text(
                              _emptyLogsMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: BrandColors.grey600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Semantics(
                        identifier: 'list_logs',
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: logs.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: BrandColors.grey200,
                          ),
                          itemBuilder: (context, index) {
                            return _LogEntryRow(
                              entry: logs[index],
                              formattedTime: _formatTime(logs[index].time),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LogEntryRow extends StatelessWidget {
  const _LogEntryRow({
    required this.entry,
    required this.formattedTime,
  });

  final DisplayLogEntry entry;
  final String formattedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LevelPill(level: entry.level),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$formattedTime · ${entry.tag}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: BrandColors.grey600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            entry.message,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: BrandColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.level});

  final SdkLogLevel level;

  Color get _backgroundColor => switch (level) {
        SdkLogLevel.error => const Color(0xFFFFCDD2),
        SdkLogLevel.warn => const Color(0xFFFFE0B2),
        SdkLogLevel.info => const Color(0xFFBBDEFB),
        SdkLogLevel.debug => const Color(0xFFC8E6C9),
        SdkLogLevel.verbose => const Color(0xFFE0E0E0),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BrandColors.grey300),
      ),
      child: Text(
        level.shortLabel,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: BrandColors.black,
        ),
      ),
    );
  }
}

class _LogsHeader extends StatelessWidget {
  const _LogsHeader({
    required this.onCopy,
    required this.onClear,
  });

  final VoidCallback onCopy;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ExampleBottomSheetHeader(
      title: 'SDK Logs',
      closeSemanticsId: 'btn_logs_close',
      actions: [
        Semantics(
          identifier: 'btn_logs_copy',
          button: true,
          label: 'Copy logs',
          child: IconButton(
            onPressed: onCopy,
            tooltip: 'Copy logs',
            icon: const Icon(Icons.copy_outlined, color: BrandColors.white),
          ),
        ),
        Semantics(
          identifier: 'btn_logs_clear',
          button: true,
          label: 'Clear logs',
          child: IconButton(
            onPressed: onClear,
            tooltip: 'Clear logs',
            icon: const Icon(
              Icons.delete_outline,
              color: BrandColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogsFilterBar extends StatelessWidget {
  const _LogsFilterBar({
    required this.selected,
    required this.onSelected,
  });

  final SdkLogFilter selected;
  final ValueChanged<SdkLogFilter> onSelected;

  static const _filters = <(SdkLogFilter, String, String)>[
    (SdkLogFilter.all, 'All', 'btn_logs_filter_all'),
    (SdkLogFilter.verbose, 'V', 'btn_logs_filter_verbose'),
    (SdkLogFilter.debug, 'D', 'btn_logs_filter_debug'),
    (SdkLogFilter.info, 'I', 'btn_logs_filter_info'),
    (SdkLogFilter.warn, 'W', 'btn_logs_filter_warn'),
    (SdkLogFilter.error, 'E', 'btn_logs_filter_error'),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BrandColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            for (final (filter, label, semanticsId) in _filters)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _FilterChip(
                  label: label,
                  semanticsId: semanticsId,
                  selected: selected == filter,
                  onTap: () => onSelected(filter),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.semanticsId,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    final chip = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? BrandColors.yellow : BrandColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? BrandColors.black : BrandColors.grey400,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: BrandColors.black,
              ),
            ),
          ),
        ),
      ),
    );
    final id = semanticsId;
    if (id == null) {
      return chip;
    }
    return Semantics(
      identifier: id,
      button: true,
      selected: selected,
      label: label,
      child: chip,
    );
  }
}
