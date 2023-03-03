
import 'package:exponea/exponea.dart';

import '../util/Codable.dart';

class ListScreenStyle extends Encodable {
  final TextViewStyle? emptyTitle;
  final TextViewStyle? emptyMessage;
  final TextViewStyle? errorTitle;
  final TextViewStyle? errorMessage;
  final ProgressBarStyle? progress;
  final AppInboxListViewStyle? list;

  ListScreenStyle({this.emptyTitle, this.emptyMessage, this.errorTitle,
      this.errorMessage, this.progress, this.list});

  @override
  String toString() {
    return 'ListScreenStyle{emptyTitle: $emptyTitle, emptyMessage: $emptyMessage, errorTitle: $errorTitle, errorMessage: $errorMessage, progress: $progress, list: $list}';
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'emptyTitle': emptyTitle?.encodeClean(),
      'emptyMessage': emptyMessage?.encodeClean(),
      'errorTitle': errorTitle?.encodeClean(),
      'errorMessage': errorMessage?.encodeClean(),
      'progress': progress?.encodeClean(),
      'list': list?.encodeClean()
    };
  }
}
