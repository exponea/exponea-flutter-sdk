import 'package:meta/meta.dart';

@immutable
class AppInboxAction {
  final String? action;
  final String? title;
  final String? url;

  const AppInboxAction({this.action, this.title, this.url});

  @override
  String toString() {
    return 'AppInboxAction{action: $action, title: $title, url: $url}';
  }
}
