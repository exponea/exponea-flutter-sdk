import 'package:exponea/src/data/encoder/main.dart';

import '../model/event_type.dart';
import '../model/project.dart';

abstract class ExponeaProjectEncoder {
  static ExponeaProject decode(Map<String, dynamic> data) {
    return ExponeaProject(
      projectToken: data['projectToken'],
      authorizationToken: data['authorizationToken'],
      baseUrl: data['baseUrl'],
    );
  }

  static Map<String, dynamic> encode(ExponeaProject project) {
    return {
      'projectToken': project.projectToken,
      'authorizationToken': project.authorizationToken,
      'baseUrl': project.baseUrl,
    };
  }
}

abstract class ExponeaProjectMappingEncoder {
  static Map<EventType, List<ExponeaProject>> decode(
    Map<String, dynamic> data,
  ) {
    return data.map(
      (key, value) => MapEntry(
        EventTypeEncoder.decode(key),
        value.map((project) => ExponeaProjectEncoder.decode(project)).toList(),
      ),
    );
  }

  static Map<String, dynamic> encode(
    Map<EventType, List<ExponeaProject>> mapping,
  ) {
    return mapping.map(
      (key, value) => MapEntry(
        EventTypeEncoder.encode(key),
        value.map((project) => ExponeaProjectEncoder.encode(project)).toList(),
      ),
    );
  }
}
