
import 'package:exponea/exponea.dart';

import '../util/Codable.dart';

class DetailViewStyle extends Encodable {
  final TextViewStyle? title;
  final TextViewStyle? content;
  final TextViewStyle? receivedTime;
  final TextViewStyle? image;
  final SimpleButtonStyle? button;

  DetailViewStyle({
      this.title, this.content, this.receivedTime, this.image, this.button});

  @override
  String toString() {
    return 'DetailViewStyle{title: $title, content: $content, receivedTime: $receivedTime, image: $image, button: $button}';
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'title': title?.encodeClean(),
      'content': content?.encodeClean(),
      'receivedTime': receivedTime?.encodeClean(),
      'image': image?.encodeClean(),
      'button': button?.encodeClean()
    };
  }

}
