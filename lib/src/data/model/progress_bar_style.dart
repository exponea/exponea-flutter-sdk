import '../util/Codable.dart';

class ProgressBarStyle extends Encodable {
  final bool? visible;
  final String? progressColor;
  final String? backgroundColor;

  ProgressBarStyle({this.visible, this.progressColor, this.backgroundColor});

  @override
  String toString() {
    return 'ProgressBarStyle{visible: $visible, progressColor: $progressColor, backgroundColor: $backgroundColor}';
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'visible': visible,
      'progressColor': progressColor,
      'backgroundColor': backgroundColor,
    };
  }
}
