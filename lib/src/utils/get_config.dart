import 'package:flutter_rename_app/src/models/config.dart';

import 'utils.dart';

Future<Config> getConfig(String newAppName) async {
  final String newIdentifier = Utils.fromNameToIdentifier(newAppName);

  final String currentAppIdentifier = await Utils.getCurrentAppIdentifier();
  final String currentAppName = Utils.fromIdentifierToName(currentAppIdentifier);

  return Config(
    oldAppName: currentAppName,
    oldIdentifier: currentAppIdentifier,
    newAppName: newAppName,
    newIdentifier: newIdentifier,
  );
}
