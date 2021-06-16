import '../model/event_type.dart';
import '../model/project.dart';
import '../util/object.dart';
import 'event_type.dart';

abstract class ExponeaProjectEncoder {
  static ExponeaProject decode(Map<String, dynamic> data) {
    return ExponeaProject(
      projectToken: data.getRequired('projectToken'),
      authorizationToken: data.getRequired('authorizationToken'),
      baseUrl: data.getOptional('baseUrl'),
    );
  }

  static Map<String, dynamic> encode(ExponeaProject project) {
    return {
      'projectToken': project.projectToken,
      'authorizationToken': project.authorizationToken,
      'baseUrl': project.baseUrl,
    }..removeWhere((key, value) => value == null);
  }
}

abstract class ExponeaProjectMappingEncoder {
  static Map<EventType, List<ExponeaProject>> decode(
    Map<String, dynamic> data,
  ) {
    return data.map(
      (key, value) => MapEntry(
        EventTypeEncoder.decode(key),
        value
            .map((project) => ExponeaProjectEncoder.decode(project))
            .cast<ExponeaProject>()
            .toList(),
      ),
    );
  }

  static Map<String, dynamic> encode(
    Map<EventType, List<ExponeaProject>> mapping,
  ) {
    return mapping.map(
      (key, value) => MapEntry(
        EventTypeEncoder.encode(key),
        value
            .map((project) => ExponeaProjectEncoder.encode(project))
            .cast<Map<String, dynamic>>()
            .toList(),
      ),
    );
  }
}
