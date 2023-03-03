
import 'package:exponea/exponea.dart';

import '../util/Codable.dart';

class AppInboxListItemStyle extends Encodable {
  final String? backgroundColor;
  final ImageViewStyle? readFlag;
  final TextViewStyle? receivedTime;
  final TextViewStyle? title;
  final TextViewStyle? content;
  final ImageViewStyle? image;

  AppInboxListItemStyle({this.backgroundColor, this.readFlag, this.receivedTime,
      this.title, this.content, this.image});

  @override
  String toString() {
    return 'AppInboxListItemStyle{backgroundColor: $backgroundColor, readFlag: $readFlag, receivedTime: $receivedTime, title: $title, content: $content, image: $image}';
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'backgroundColor': backgroundColor,
      'readFlag': readFlag?.encodeClean(),
      'receivedTime': receivedTime?.encodeClean(),
      'title': title?.encodeClean(),
      'content': content?.encodeClean(),
      'image': image?.encodeClean()
    };
  }
}
