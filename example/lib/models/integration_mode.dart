enum IntegrationMode {
  project,
  stream,
}

extension IntegrationModeParsing on IntegrationMode {
  static IntegrationMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'stream':
        return IntegrationMode.stream;
      case 'project':
      default:
        return IntegrationMode.project;
    }
  }

  String get envValue => name;
}
