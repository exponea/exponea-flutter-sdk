import '../util/Codable.dart';

class ImageViewStyle extends Encodable {
  final bool? visible;
  final String? backgroundColor;

  ImageViewStyle({this.visible, this.backgroundColor});

  @override
  String toString() {
    return 'ImageViewStyle{visible: $visible, backgroundColor: $backgroundColor}';
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'visible': visible,
      'backgroundColor': backgroundColor
    };
  }
}
