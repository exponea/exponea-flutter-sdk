import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Official Bloomreach logo, rendered from SVG assets converted path-for-path
/// from the Android example app drawables (see ADR 2026-10-06-1410).
///
/// Never recreate the logo from text glyphs; use [BrandLogo.mini] or
/// [BrandLogo.wordmark].
class BrandLogo extends StatelessWidget {
  /// Yellow circle with "b" (Android `ic_br_mini`).
  const BrandLogo.mini({super.key, this.size = 28})
      : _asset = miniAsset,
        _width = size,
        _height = size;

  /// "bloomreach" wordmark (Android `ic_br_logo`).
  const BrandLogo.wordmark({super.key, double width = 220})
      : _asset = wordmarkAsset,
        _width = width,
        _height = null,
        size = width;

  static const miniAsset = 'assets/brand/br_mini.svg';
  static const wordmarkAsset = 'assets/brand/br_wordmark.svg';

  final double size;
  final String _asset;
  final double _width;
  final double? _height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _asset,
      width: _width,
      height: _height,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
