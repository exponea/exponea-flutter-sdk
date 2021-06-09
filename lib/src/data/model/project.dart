import 'package:meta/meta.dart';

@immutable
class ExponeaProject {
  /// Project token of the Exponea project
  final String projectToken;

  /// Authorization token of the Exponea project
  final String authorizationToken;

  /// Base URL of the Exponea project
  final String? baseUrl;

  const ExponeaProject({
    required this.projectToken,
    required this.authorizationToken,
    this.baseUrl,
  });
}
