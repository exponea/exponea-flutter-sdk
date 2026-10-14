import 'package:exponea_example/app/brand_colors.dart';
import 'package:flutter/material.dart';

Future<void> showExampleBottomSheet(
  BuildContext context, {
  required Widget child,
}) {
  final sheetHeight = MediaQuery.sizeOf(context).height * 0.85;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: BrandColors.grey100,
    builder: (context) {
      return SizedBox(
        height: sheetHeight,
        width: double.infinity,
        child: child,
      );
    },
  );
}

class ExampleBottomSheetHeader extends StatelessWidget {
  const ExampleBottomSheetHeader({
    super.key,
    required this.title,
    required this.closeSemanticsId,
    this.actions = const [],
  });

  final String title;
  final String closeSemanticsId;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BrandColors.black,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: BrandColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...actions,
            Semantics(
              identifier: closeSemanticsId,
              button: true,
              label: 'Close',
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
                icon: const Icon(Icons.close, color: BrandColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
