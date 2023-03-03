
import 'package:exponea/exponea.dart';

import '../util/Codable.dart';
import 'app_inbox_list_item_style.dart';

class AppInboxListViewStyle extends Encodable {
  final String? backgroundColor;
  final AppInboxListItemStyle? item;

  AppInboxListViewStyle({this.backgroundColor, this.item});

  @override
  String toString() {
    return 'AppInboxListViewStyle{backgroundColor: $backgroundColor, item: $item}';
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'backgroundColor': backgroundColor,
      'item': item?.encodeClean()
    };
  }
}
