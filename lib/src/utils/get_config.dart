import 'dart:io';

import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/models/errors.dart';
import 'package:yaml/yaml.dart';

import 'utils.dart';

/// The section id for flutter_rename_app in the yaml file
const String yamlSectionId = 'flutter_rename_app';

/// App Name can be any characters
const String appNameRegexpPattern = ".*";

/// A class of arguments which the user can specify in pubspec.yaml
class YamlArguments {
  static const String applicationName = 'application_name';
  static const String dartPackageName = 'dart_package_name';
  static const String applicationId = 'application_id';
  static const String androidPackageName = 'android_package_name';
  static const String bundleId = 'bundle_id';
  static const String i18nAppNames = 'i18n_application_names';
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

  Map<String, String> previousI18nNames = Map();
  Map<String, String> newI18nNames = Map();

  if (settings.containsKey(YamlArguments.i18nAppNames)) {
    previousI18nNames = await _loadPreviousI18nAppNames();
    for (final kvp in settings[YamlArguments.i18nAppNames].entries) {
      if (kvp.value is String) {
        newI18nNames[kvp.key] = kvp.value;
      } else {
        throw MissingConfiguration("${kvp.key}'s value must be a String");
      }
    }
  }

  return Config(
    newAppName: newAppName,
    oldAppName: oldAppName,
    oldI18nAppNames: previousI18nNames,
    newI18nAppNames: newI18nNames,
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

/// Returns a Map<String, String> of previous internationalized names in Android
Future<Map<String, String>> _loadPreviousI18nAppNames() async {
  final Directory androidResources = Directory("android/app/src/main/res");
  final List<FileSystemEntity> resourcesEntities = androidResources.listSync();
  final Map<String, String> result = Map();

  for (final FileSystemEntity resourceEntity in resourcesEntities) {
    final String resourceName = Utils.getFileName(resourceEntity.path);

    if (resourceName.contains("values") && resourceEntity is Directory) {
      final List<FileSystemEntity> valuesEntities = resourceEntity.listSync();

      for (final FileSystemEntity valuesEntity in valuesEntities) {
        final String valuesEntityName = Utils.getFileName(valuesEntity.path);
        if (valuesEntityName == "strings.xml" && valuesEntity is File) {
          final String appName = await Utils.searchInFile(
            filePath: valuesEntity.path,
            pattern: RegExp('<string name="app_name">($appNameRegexpPattern)</string>'),
          );

          if (appName != null) {
            final String lang = _getLangFromAndroidValuesDir(resourceName);
            if (lang != null) {
              result[lang] = appName;
            }
          }
        }
      }
    }
  }

  return result;
}

/// Returns locale (en, fr, etc.)
/// from android values directory name
String _getLangFromAndroidValuesDir(String valuesDirName) {
  final RegExpMatch match = RegExp("values-([a-zA-Z-]+)").firstMatch(valuesDirName);
  return match?.group(1);
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
    return Utils.searchInFile(
      filePath: "android/app/src/main/AndroidManifest.xml",
      pattern: RegExp('package="([a-z_.]*)"'),
    );
  } catch (error) {
    print("Error reading Manifest : $error");
    return "";
  }
}

Future<String> _loadAndroidAppName() async {
  try {
    return Utils.searchInFile(
      filePath: "android/app/src/main/AndroidManifest.xml",
      pattern: RegExp('android:label="($appNameRegexpPattern)"'),
    );
  } catch (error) {
    print("Error reading Manifest : $error");
    return "";
  }
}

Future<String> _loadAndroidApplicationId() async {
  try {
    return Utils.searchInFile(
      filePath: "android/app/build.gradle",
      pattern: RegExp('applicationId "([a-z_.]*)"'),
    );
  } catch (error) {
    print("Error reading build.gradle : $error");
    return "";
  }
}

Future<String> _loadBundleId() async {
  try {
    return Utils.searchInFile(
      filePath: "ios/Runner.xcodeproj/project.pbxproj",
      pattern: RegExp('PRODUCT_BUNDLE_IDENTIFIER = ([a-z_.]*)'),
    );
  } catch (error) {
    print("Error reading Plist : $error");
    return "";
  }
}
