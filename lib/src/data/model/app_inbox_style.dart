
import 'package:exponea/exponea.dart';

import '../util/Codable.dart';

class AppInboxStyle extends Encodable {
  final SimpleButtonStyle? appInboxButton;
  final DetailViewStyle? detailView;
  final ListScreenStyle? listView;

  AppInboxStyle({this.appInboxButton, this.detailView, this.listView});

  @override
  String toString() {
    return 'AppInboxStyle{appInboxButton: $appInboxButton, detailView: $detailView, listView: $listView}';
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'appInboxButton': appInboxButton?.encodeClean(),
      'detailView': detailView?.encodeClean(),
      'listView': listView?.encodeClean()
    };
  }

}
