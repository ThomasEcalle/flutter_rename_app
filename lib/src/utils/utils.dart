import 'dart:io';

import 'package:yaml/yaml.dart';

class Utils {
  /// Read pubspec.yaml in order to retrieve the current dart package name
  static Future<String> getCurrentDartPackageName() async {
    final File file = File("pubspec.yaml");
    final String yamlString = file.readAsStringSync();
    final Map<dynamic, dynamic> yamlMap = loadYaml(yamlString);

    return yamlMap["name"];
  }

  /// Return a String replacing _ by spaces and adding uppercase to first works
  static String fromIdentifierToName(String identifier) {
    return identifier
        .split("_")
        .map((word) =>
            "${word[0].toUpperCase()}${word.substring(1, word.length)}")
        .toList()
        .join(" ");
  }
}
