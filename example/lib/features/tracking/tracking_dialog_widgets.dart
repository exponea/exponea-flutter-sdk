import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/features/tracking/in_app_message_presets.dart';
import 'package:flutter/material.dart';

/// Shared layout helpers for Tracking tab dialogs (Android v2 parity).
abstract final class TrackingDialogWidgets {
  static String formatAttributesJson(Map<String, dynamic> attributes) {
    if (attributes.isEmpty) {
      return '{\n\n}';
    }
    final buffer = StringBuffer('{\n');
    final entries = attributes.entries.toList();
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      buffer.write('\t ${entry.key}: ${entry.value}');
      if (index != entries.length - 1) {
        buffer.write(',\n');
      }
    }
    buffer.write('\n}');
    return buffer.toString();
  }

  static Widget title(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: BrandColors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Widget resultPanel({
    required String text,
    double minHeight = 0,
    String? semanticsId,
  }) {
    final panel = DecoratedBox(
      decoration: BoxDecoration(
        color: BrandColors.grey200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrandColors.grey300),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: BrandColors.grey600,
            ),
          ),
        ),
      ),
    );
    final id = semanticsId;
    if (id == null) {
      return panel;
    }
    return Semantics(
      identifier: id,
      label: text,
      child: panel,
    );
  }

  static Widget outlineField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    bool readOnly = false,
    String? semanticsId,
  }) {
    final field = TextField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      showCursor: !readOnly,
      enableInteractiveSelection: !readOnly,
      style: readOnly
          ? const TextStyle(color: BrandColors.grey600)
          : null,
      decoration: InputDecoration(
        labelText: label,
        filled: readOnly,
        fillColor: readOnly ? BrandColors.grey200 : null,
        labelStyle: readOnly
            ? const TextStyle(color: BrandColors.grey600)
            : null,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: BrandColors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: BrandColors.black, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: BrandColors.grey300),
        ),
      ),
    );
    if (semanticsId == null) {
      return field;
    }
    // Expose controller text as Semantics.value so Appium can read read-only
    // Flutter fields (Get Text / content-desc are often empty after preset apply).
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Semantics(
        identifier: semanticsId,
        textField: true,
        label: label,
        value: controller.text,
        child: field,
      ),
    );
  }

  static Widget outlinedButton({
    required String label,
    required VoidCallback? onPressed,
    String? semanticsId,
  }) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: BrandColors.black,
        side: const BorderSide(color: BrandColors.black),
        minimumSize: const Size.fromHeight(44),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
    if (semanticsId == null) {
      return SizedBox(width: double.infinity, child: button);
    }
    return Semantics(
      identifier: semanticsId,
      button: true,
      label: label,
      child: SizedBox(width: double.infinity, child: button),
    );
  }

  static Widget filledButton({
    required String label,
    required VoidCallback? onPressed,
    String? semanticsId,
  }) {
    final button = FilledButton(
      onPressed: onPressed,
      child: Text(label),
    );
    if (semanticsId == null) {
      return SizedBox(width: double.infinity, child: button);
    }
    return Semantics(
      identifier: semanticsId,
      button: true,
      label: label,
      child: SizedBox(width: double.infinity, child: button),
    );
  }

  /// In-app message preset picker (Appium-friendly).
  ///
  /// Tapping [sel_inapp_preset] opens a modal bottom sheet listing each preset
  /// as plain [Text] (not [ListTile], which merges labels into content-desc on
  /// Android) so UiAutomator can match `@text='Control Group'` etc.
  static Widget presetDropdown({
    required InAppMessagePreset? value,
    required ValueChanged<InAppMessagePreset?> onSelected,
  }) {
    final label = value?.label ?? '(custom)';
    return Builder(
      builder: (context) {
        Future<void> openPicker() async {
          final picked = await showModalBottomSheet<_PresetPick>(
            context: context,
            isScrollControlled: true,
            builder: (sheetContext) {
              Widget option({
                required String text,
                required VoidCallback onTap,
                bool enabled = true,
              }) {
                // Compact rows so every preset fits on screen at once: an
                // off-screen row is still in the accessibility tree, and a tap
                // on its coordinates selects nothing.
                final child = Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: enabled ? 7 : 4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      style: enabled
                          ? null
                          : const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: BrandColors.grey600,
                            ),
                    ),
                  ),
                );
                if (!enabled) {
                  // Category headers: keep plain @text for diagnostics; not tappable.
                  return Semantics(
                    container: true,
                    explicitChildNodes: true,
                    child: child,
                  );
                }
                // Keep plain Text as its own node so Android exposes exact @text
                // (e.g. 'Control Group'). Do not set Semantics label+value with
                // excludeSemantics — that yields content-desc 'Label\nLabel' and
                // breaks the suite's exact xpath match.
                return InkWell(
                  onTap: onTap,
                  child: Semantics(
                    container: true,
                    explicitChildNodes: true,
                    child: child,
                  ),
                );
              }

              return SafeArea(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.9,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      option(
                        text: '(custom)',
                        onTap: () => Navigator.pop(
                          sheetContext,
                          const _PresetPick.custom(),
                        ),
                      ),
                      for (final category in inAppMessagePresetCategories) ...[
                        option(
                          text: category,
                          enabled: false,
                          onTap: () {},
                        ),
                        for (final preset in inAppMessagePresets.where(
                          (p) => p.category == category,
                        ))
                          option(
                            text: preset.label,
                            onTap: () => Navigator.pop(
                              sheetContext,
                              _PresetPick.preset(preset),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
          if (picked == null) {
            return; // barrier dismiss — keep current selection
          }
          onSelected(picked.preset);
        }

        return Semantics(
          identifier: 'sel_inapp_preset',
          button: true,
          label: 'In-app message preset',
          onTap: openPicker,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'In-app message preset',
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: BrandColors.black),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: BrandColors.black, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            child: InkWell(
              onTap: openPicker,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(label),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget dialogShell({required List<Widget> children}) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: BrandColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _PresetPick {
  const _PresetPick.custom() : preset = null;
  const _PresetPick.preset(this.preset);
  final InAppMessagePreset? preset;
}
