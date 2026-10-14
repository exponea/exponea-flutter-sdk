import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/models/sdk_configuration_snapshot.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/widgets/example_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future<void> showConfigurationInfoSheet(BuildContext context) {
  return showExampleBottomSheet(
    context,
    child: const _ConfigurationInfoSheetBody(),
  );
}

class _ConfigurationInfoSheetBody extends StatelessWidget {
  const _ConfigurationInfoSheetBody();

  @override
  Widget build(BuildContext context) {
    final service = ExponeaServiceScope.of(context);
    final snapshot = service.configurationSnapshot;
    final isConfigured = service.isConfigured && snapshot != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ExampleBottomSheetHeader(
          title: 'Exponea configuration',
          closeSemanticsId: 'btn_config_close',
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: BrandColors.grey300,
        ),
        Expanded(
          child: ColoredBox(
            color: BrandColors.white,
            child: isConfigured
                ? _ConfigurationRows(snapshot: snapshot)
                : const _NotConfiguredMessage(),
          ),
        ),
      ],
    );
  }
}

class _NotConfiguredMessage extends StatelessWidget {
  const _NotConfiguredMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Semantics(
          identifier: 'lbl_config_not_configured',
          label: 'SDK not configured',
          child: const Text(
            'SDK not configured',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BrandColors.grey600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfigurationRows extends StatelessWidget {
  const _ConfigurationRows({required this.snapshot});

  final SdkConfigurationSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final rows = <({String label, String value, String semanticsId})>[
      (
        label: 'Token track frequency',
        value: snapshot.tokenTrackFrequency,
        semanticsId: 'lbl_config_token_frequency',
      ),
      (
        label: 'Application ID',
        value: snapshot.applicationId,
        semanticsId: 'lbl_config_application_id',
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        color: BrandColors.grey200,
      ),
      itemBuilder: (context, index) {
        final row = rows[index];
        return _ConfigurationRow(
          label: row.label,
          value: row.value,
          valueSemanticsId: row.semanticsId,
        );
      },
    );
  }
}

class _ConfigurationRow extends StatelessWidget {
  const _ConfigurationRow({
    required this.label,
    required this.value,
    required this.valueSemanticsId,
  });

  final String label;
  final String value;
  final String valueSemanticsId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: BrandColors.grey600,
            ),
          ),
          const SizedBox(height: 4),
          Semantics(
            identifier: valueSemanticsId,
            label: '$label: $value',
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: BrandColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
