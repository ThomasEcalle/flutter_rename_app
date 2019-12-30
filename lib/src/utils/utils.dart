import 'dart:io';

import 'package:yaml/yaml.dart';

class Utils {
  static String fromNameToIdentifier(String newName) {
    return newName.toLowerCase().replaceAll(" ", "_");
  }

  static Future<String> getCurrentDartPackageName() async {
    final File file = File("pubspec.yaml");
    final String yamlString = file.readAsStringSync();
    final Map<dynamic, dynamic> yamlMap = loadYaml(yamlString);

    return yamlMap["name"];
  }

  static String fromIdentifierToName(String identifier) {
    return identifier
        .split("_")
        .map((word) => "${word[0].toUpperCase()}${word.substring(1, word.length)}")
        .toList()
        .join(" ");
  }
}
