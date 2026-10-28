import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/features/content_blocks/runtime_controller_lab.dart';
import 'package:exponea_example/util/test_environment.dart';
import 'package:exponea/exponea.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ContentBlocksScreen extends StatefulWidget {
  const ContentBlocksScreen({super.key});

  @override
  State<ContentBlocksScreen> createState() => _ContentBlocksScreenState();
}

class _ContentBlocksScreenState extends State<ContentBlocksScreen> {
  static const _productCount = 50;
  static const _contentBlockEvery = 5;
  static const _listHeight = 400.0;

  bool _showRuntimeLab = false;
  bool _showCarousels = false;
  final bool _placeholdersBuilt = true;
  bool _carouselsBuilt = false;
  int _exampleTopHeightPx = 0;

  String? _carouselName;
  int _carouselIndex = -1;
  int _carouselCount = 0;

  bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  String get _platformPlaceholderId =>
      _isIos ? 'ph_x_example_iOS' : 'ph_x_example_Android';

  String get _platformPlaceholderLabel =>
      _isIos ? 'Placeholder: ph_x_example_iOS' : 'Placeholder: ph_x_example_Android';

  String get _platformCarouselId =>
      _isIos ? 'example_carousel_ios' : 'example_carousel_and';

  String get _platformCarouselLabel => _isIos
      ? 'iOS carousel: example_carousel_ios'
      : 'Android carousel: example_carousel_and';

  String get _carouselStatusText {
    if (_carouselCount == 0) {
      return 'Carousel is empty';
    }
    return 'Showing ${_carouselName ?? ''} as ${_carouselIndex + 1} of $_carouselCount';
  }

  void _onToggleCarousels(bool value) {
    setState(() {
      _showCarousels = value;
      if (value) {
        _carouselsBuilt = true;
      }
    });
  }

  void _onDefaultCarouselMessageShown(
    String placeholderId,
    InAppContentBlock contentBlock,
    int index,
    int count,
  ) {
    setState(() {
      _carouselName = contentBlock.name;
      _carouselIndex = index;
      _carouselCount = count;
    });
  }

  void _onDefaultCarouselMessagesChanged(
    int count,
    List<InAppContentBlock> messages,
  ) {
    setState(() {
      if (count == 0) {
        _carouselName = null;
        _carouselIndex = -1;
      }
      _carouselCount = count;
    });
  }

  int _productListItemCount() =>
      _productCount + _productCount ~/ _contentBlockEvery;

  int _productDataIndex(int position) {
    return (position - (position / _contentBlockEvery).ceil()).toInt();
  }

  Widget _placeholderWidget(String placeholderId) {
    if (isFlutterWidgetTest) {
      return _NativeWidgetStub(label: 'CB placeholder: $placeholderId');
    }
    return InAppContentBlockPlaceholder(placeholderId: placeholderId);
  }

  Widget _defaultCarouselWidget() {
    if (isFlutterWidgetTest) {
      return const _NativeWidgetStub(label: 'CB carousel: example_carousel');
    }
    return InAppContentBlockCarousel(
      placeholderId: 'example_carousel',
      trackActions: true,
      onMessageShown: _onDefaultCarouselMessageShown,
      onMessagesChanged: _onDefaultCarouselMessagesChanged,
    );
  }

  Widget _filteredCarouselWidget() {
    if (isFlutterWidgetTest) {
      return const _NativeWidgetStub(label: 'CB carousel: example_carousel (filtered)');
    }
    return InAppContentBlockCarousel(
      placeholderId: 'example_carousel',
      maxMessagesCount: 5,
      scrollDelay: 10,
      filterContentBlocks: (contentBlocks) {
        return contentBlocks
            .where((block) => !block.name.toLowerCase().contains('discarded'))
            .toList();
      },
      sortContentBlocks: (contentBlocks) {
        return contentBlocks.reversed.toList();
      },
    );
  }

  Widget _platformCarouselWidget() {
    if (isFlutterWidgetTest) {
      return _NativeWidgetStub(label: 'CB carousel: $_platformCarouselId');
    }
    return InAppContentBlockCarousel(placeholderId: _platformCarouselId);
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
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    semanticsId: 'cb_tab_classic',
                    label: 'Basic',
                    selected: !_showRuntimeLab,
                    onPressed: () => setState(() => _showRuntimeLab = false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TabButton(
                    semanticsId: 'cb_tab_runtime_lab',
                    label: 'Runtime Control',
                    selected: _showRuntimeLab,
                    onPressed: () => setState(() => _showRuntimeLab = true),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _showRuntimeLab
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    child: _SectionCard(
                      title: 'Runtime Control',
                      child: RuntimeControllerLab(
                        platformPlaceholderId: _platformPlaceholderId,
                      ),
                    ),
                  )
                : _buildBasicTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Card(
            margin: EdgeInsets.zero,
            color: BrandColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: BrandColors.grey300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Show carousels',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Semantics(
                    identifier: 'btn_toggle_carousels',
                    label: 'Show carousels',
                    toggled: _showCarousels,
                    excludeSemantics: true,
                    child: Switch(
                      value: _showCarousels,
                      onChanged: _onToggleCarousels,
                      thumbColor: WidgetStateProperty.resolveWith(
                        (states) => BrandColors.black,
                      ),
                      trackColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? BrandColors.yellow
                            : BrandColors.grey400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: _showCarousels
                ? (_carouselsBuilt
                    ? _buildCarouselsGroup()
                    : const SizedBox.shrink())
                : (_placeholdersBuilt
                    ? _buildPlaceholdersGroup()
                    : const SizedBox.shrink()),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholdersGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: 'Placeholder: example_top',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                identifier: 'cb_placeholder_example_top',
                child: _placeholderWidget('example_top'),
              ),
              const SizedBox(height: 6),
              // Android ContentBlocksScreen parity — suite asserts text containing "Height:".
              Text('Height: ${_exampleTopHeightPx}px'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _SectionCard(
          title: _platformPlaceholderLabel,
          child: Semantics(
            identifier: 'cb_placeholder_example_platform',
            child: _placeholderWidget(_platformPlaceholderId),
          ),
        ),
        const SizedBox(height: 8),
        _SectionCard(
          title: 'Inline placeholder: example_list (every 5th row)',
          child: Semantics(
            identifier: 'cb_placeholder_example_list',
            child: SizedBox(
              height: _listHeight,
              child: ListView.builder(
                itemCount: _productListItemCount(),
                itemBuilder: (context, index) {
                  if (index % _contentBlockEvery == 0) {
                    return _placeholderWidget('example_list');
                  }
                  final dataIndex = _productDataIndex(index);
                  final productNumber = dataIndex + 1;
                  return ListTile(
                    leading: Icon(_productIcon(productNumber)),
                    title: Text('Product $productNumber'),
                    subtitle: Text(
                      'Demo description for product $productNumber.',
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _productIcon(int productNumber) {
    const icons = [
      Icons.shopping_bag_outlined,
      Icons.edit_note_outlined,
      Icons.cloud_download_outlined,
      Icons.view_carousel_outlined,
    ];
    return icons[(productNumber - 1) % icons.length];
  }

  Widget _buildCarouselsGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: 'Default carousel: example_carousel',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                identifier: 'cb_carousel_default',
                child: _defaultCarouselWidget(),
              ),
              const SizedBox(height: 6),
              Semantics(
                identifier: 'lbl_carousel_status',
                // Put the status on this node (resource-id) so Appium
                // Get Android DisplayText does not fall through to unsupported
                // stateDescription on an empty Flutter semantics container.
                label: _carouselStatusText,
                value: _carouselStatusText,
                excludeSemantics: true,
                child: _StatusBox(text: _carouselStatusText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _SectionCard(
          title: 'Filtered carousel: example_carousel',
          child: Semantics(
            identifier: 'cb_carousel_filtered',
            child: _filteredCarouselWidget(),
          ),
        ),
        const SizedBox(height: 8),
        _SectionCard(
          title: _platformCarouselLabel,
          child: Semantics(
            identifier: 'cb_carousel_platform',
            child: _platformCarouselWidget(),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.semanticsId,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String semanticsId;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? BrandColors.yellow : BrandColors.white,
          foregroundColor: BrandColors.black,
          side: BorderSide(
              color: selected ? BrandColors.black : BrandColors.grey300),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          minimumSize: const Size.fromHeight(44),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        child: Text(label),
      ),
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
  const _StatusBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: BrandColors.grey200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrandColors.grey300),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: BrandColors.grey600,
        ),
      ),
    );
  }
}

class _NativeWidgetStub extends StatelessWidget {
  const _NativeWidgetStub({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: BrandColors.grey200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrandColors.grey300),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: BrandColors.grey600,
        ),
      ),
    );
  }
}
