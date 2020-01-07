/*
 * applicationId stands for the android application_id
 * bundleId stands for the iOS bundle_id
 * appName stands for the displayed Application name
 * i18nAppNames stands the internationalized app names
 * dartPackageName stands for the name in the pubspec.yaml and every imports
 * androidPackageName stands for the android's package_name
 */
class Config {
  final String oldApplicationId;
  final String newApplicationId;

  final String oldBundleId;
  final String newBundleId;

  final String newAppName;
  final String oldAppName;

  final Map<String, String> oldI18nAppNames;
  final Map<String, String> newI18nAppNames;

  final String oldDartPackageName;
  final String newDartPackageName;

  final String oldAndroidPackageName;
  final String newAndroidPackageName;

  Config({
    this.oldApplicationId,
    this.newApplicationId,
    this.oldBundleId,
    this.newBundleId,
    this.newAppName,
    this.oldAppName,
    this.oldI18nAppNames,
    this.newI18nAppNames,
    this.oldDartPackageName,
    this.newDartPackageName,
    this.oldAndroidPackageName,
    this.newAndroidPackageName,
  });
}
