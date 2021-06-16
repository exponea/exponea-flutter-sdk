import 'dart:convert';
import 'dart:io';

String _readFileContent(String fileName) {
  final file = File('test/values/$fileName.json');
  return file.readAsStringSync();
}

List<String> readFile(String fileName) {
  final content = _readFileContent(fileName);
  final data = json.decode(content) as List;
  return data.map((it) => json.encode(it)).toList();
}

List<Map<String, dynamic>> readMapData(String fileName) {
  final content = _readFileContent(fileName);
  final data = json.decode(content) as List;
  return data.cast<Map<String, dynamic>>();
}

List<String> readStringData(String fileName) {
  final content = _readFileContent(fileName);
  final data = json.decode(content) as List;
  return data.cast<String>();
}
