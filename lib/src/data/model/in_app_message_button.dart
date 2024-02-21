import 'package:meta/meta.dart';

@immutable
class InAppMessageButton {
  final String? text;
  final String? url;

  const InAppMessageButton({
    this.text,
    this.url,
  });

  @override
  String toString() {
    return 'InAppMessageButton{text: $text, url: $url}';
  }
}
