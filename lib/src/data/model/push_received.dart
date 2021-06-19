import 'package:meta/meta.dart';

@immutable
class ReceivedPush {
  final Map<String, dynamic> data;

  const ReceivedPush({
    required this.data,
  });

  @override
  String toString() {
    return 'ReceivedPush{data: $data}';
  }
}
