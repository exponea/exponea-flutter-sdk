import '../util/Codable.dart';

class SimpleButtonStyle extends Encodable {
  final String? textOverride;
  final String? textColor;
  final String? backgroundColor;
  final bool? showIcon;
  final String? textSize;
  final bool? enabled;
  final String? borderRadius;
  final String? textWeight;

  SimpleButtonStyle({
      this.textOverride,
      this.textColor,
      this.backgroundColor,
      this.showIcon,
      this.textSize,
      this.enabled,
      this.borderRadius,
      this.textWeight});

  @override
  String toString() {
    return 'ButtonStyle{textOverride: $textOverride, textColor: $textColor, backgroundColor: $backgroundColor, showIcon: $showIcon, textSize: $textSize, enabled: $enabled, borderRadius: $borderRadius, textWeight: $textWeight}';
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'textOverride': textOverride,
      'textColor': textColor,
      'backgroundColor': backgroundColor,
      'showIcon': showIcon,
      'textSize': textSize,
      'enabled': enabled,
      'borderRadius': borderRadius,
      'textWeight': textWeight
    };
  }
}
