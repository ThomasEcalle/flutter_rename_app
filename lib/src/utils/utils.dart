import 'dart:io';

import 'package:flutter_rename_app/src/utils/logger.dart';
import 'package:yaml/yaml.dart';

class Utils {
  static const Duration fakeDelay = Duration(milliseconds: 500);

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
        .map((word) => "${word[0].toUpperCase()}${word.substring(1, word.length)}")
        .toList()
        .join(" ");
  }

  /// Return the filename based on path
  static String getFileName(String filePath) {
    return filePath.split("/").last;
  }

  /// Change content of the given File by the given content
  static changeContentInFile(String filePath, RegExp regexp, String replacement) async {
    try {
      final File file = File(filePath);
      final String content = file.readAsStringSync();
      if (content.contains(regexp)) {
        final String newContent = content.replaceAll(regexp, replacement);
        file.writeAsStringSync(newContent);
        Logger.info("$filePath", greenPart: "MODIFIED");
        await Future.delayed(Utils.fakeDelay);
      }
    } catch (error) {}
  }
}
