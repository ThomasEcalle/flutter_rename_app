import 'dart:io';

import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/models/errors.dart';
import 'package:yaml/yaml.dart';

import 'utils.dart';

/// The section id for flutter_rename_app in the yaml file
const String yamlSectionId = 'flutter_rename_app';

/// A class of arguments which the user can specify in pubspec.yaml
class YamlArguments {
  static const String applicationName = 'application_name';
  static const String dartPackageName = 'dart_package_name';
  static const String applicationId = 'application_id';
  static const String androidPackageName = 'android_package_name';
  static const String bundleId = 'bundle_id';
}

/// Parse the YAML configuration and the Android and iOS files to get the Config
Future<Config> getConfig() async {
  final String currentDartPackageName = await Utils.getCurrentDartPackageName();

  final String oldAppName = await _loadAndroidAppName();
  String newAppName = Utils.fromIdentifierToName(currentDartPackageName);

  final Map<String, dynamic> settings = _loadSettings();
  if (settings.length < 0) {
    throw MissingConfiguration("Missing, at least, the application's name");
  }

  if (settings.containsKey(YamlArguments.applicationName)) {
    newAppName = settings[YamlArguments.applicationName];
  } else {
    throw MissingConfiguration("Missing, at least, the application's name");
  }

  String dartPackageName = currentDartPackageName;

  if (settings.containsKey(YamlArguments.dartPackageName)) {
    dartPackageName = settings[YamlArguments.dartPackageName];
  }

  final String oldBundleId = await _loadBundleId() ?? "";
  String newBundleId = oldBundleId;
  if (settings.containsKey(YamlArguments.bundleId)) {
    newBundleId = settings[YamlArguments.bundleId];
  }

  final String oldApplicationId = await _loadAndroidApplicationId() ?? "";
  String newApplicationId = oldApplicationId;
  if (settings.containsKey(YamlArguments.applicationId)) {
    newApplicationId = settings[YamlArguments.applicationId];
  }

  final String oldAndroidPackageName = await _loadAndroidPackageName() ?? "";
  String newAndroidPackageName = oldAndroidPackageName;
  if (settings.containsKey(YamlArguments.androidPackageName)) {
    newAndroidPackageName = settings[YamlArguments.androidPackageName];
  }

  return Config(
    newAppName: newAppName,
    oldAppName: oldAppName,
    oldApplicationId: oldApplicationId,
    newApplicationId: newApplicationId,
    oldBundleId: oldBundleId,
    newBundleId: newBundleId,
    oldDartPackageName: currentDartPackageName,
    newDartPackageName: dartPackageName,
    oldAndroidPackageName: oldAndroidPackageName,
    newAndroidPackageName: newAndroidPackageName,
  );
}

/// Returns configuration settings for flutter_rename_app from pubspec.yaml
Map<String, dynamic> _loadSettings() {
  final File file = File("pubspec.yaml");
  final String yamlString = file.readAsStringSync();
  final Map<dynamic, dynamic> yamlMap = loadYaml(yamlString);

  // determine <String, dynamic> map from <dynamic, dynamic> yaml
  final Map<String, dynamic> settings = <String, dynamic>{};
  if (yamlMap.containsKey(yamlSectionId)) {
    for (final kvp in yamlMap[yamlSectionId].entries) {
      settings[kvp.key] = kvp.value;
    }
  }

  return settings;
}

Future<String> _loadAndroidPackageName() async {
  try {
    return searchInFile(
      filePath: "android/app/src/main/AndroidManifest.xml",
      pattern: 'package="([a-z.]*)"',
    );
  } catch (error) {
    print("Error reading Manifest : $error");
    return "";
  }
}

Future<String> _loadAndroidAppName() async {
  try {
    return searchInFile(
      filePath: "android/app/src/main/AndroidManifest.xml",
      pattern: 'android:label="([A-Za-z0-9 _\'.]*)',
    );
  } catch (error) {
    print("Error reading Manifest : $error");
    return "";
  }
}

Future<String> _loadAndroidApplicationId() async {
  try {
    return searchInFile(
      filePath: "android/app/build.gradle",
      pattern: 'applicationId "([a-z.]*)"',
    );
  } catch (error) {
    print("Error reading build.gradle : $error");
    return "";
  }
}

Future<String> _loadBundleId() async {
  try {
    return searchInFile(
      filePath: "ios/Runner.xcodeproj/project.pbxproj",
      pattern: 'PRODUCT_BUNDLE_IDENTIFIER = ([a-z.]*)',
    );
  } catch (error) {
    print("Error reading Plist : $error");
    return "";
  }
}

Future<String> searchInFile({String filePath, String pattern}) async {
  final File file = File(filePath);
  final String fileContent = file.readAsStringSync();
  final RegExp regExp = RegExp(pattern);

  final RegExpMatch match = regExp.firstMatch(fileContent);
  return match.group(1);
}
