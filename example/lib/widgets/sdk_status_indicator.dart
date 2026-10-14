import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/services/sdk_status_scope.dart';
import 'package:exponea_example/services/sdk_status_store.dart';
import 'package:flutter/material.dart';

/// Toolbar "semafor" reflecting the SDK lifecycle state.
class SdkStatusIndicator extends StatelessWidget {
  const SdkStatusIndicator({super.key});

  Color _colorFor(SdkLifecycleState state) {
    switch (state) {
      case SdkLifecycleState.notInitialized:
        return BrandColors.red;
      case SdkLifecycleState.anonymous:
        return BrandColors.yellow;
      case SdkLifecycleState.identified:
        return BrandColors.green;
    }
  }

  String _tooltipFor(SdkLifecycleState state) {
    switch (state) {
      case SdkLifecycleState.notInitialized:
        return 'SDK not initialized';
      case SdkLifecycleState.anonymous:
        return 'Anonymous';
      case SdkLifecycleState.identified:
        return 'Identified';
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = SdkStatusScope.of(context);
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final state = store.state;
        // Publish state.name as label+value so iOS Element Should Contain Text
        // and Android DisplayText both read identified/anonymous/notInitialized
        // from the resource-id / accessibility_id node (not only Tooltip).
        return Semantics(
          identifier: 'status_sdk_indicator',
          label: state.name,
          value: state.name,
          excludeSemantics: true,
          child: Tooltip(
            message: _tooltipFor(state),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _colorFor(state),
                  shape: BoxShape.circle,
                  border: Border.all(color: BrandColors.white, width: 1),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
