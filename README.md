# flutter_rename_app

Rename Flutter applications in one command.

> This package assumes that you created your flutter project using `flutter create` command line.

## Usage

<p align="center">
<img src="https://raw.githubusercontent.com/ThomasEcalle/flutter_rename_app/master/documentation/readme_gif.gif" width="700" height="350"/>
</p>

### Add dependency

```
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_rename_app:
```

### Define Settings

```
flutter_rename_app:
  application_name: Bank App
  dart_package_name: bank_app
  application_id: com.android.bank
  bundle_id: com.ios.bank
  android_package_name: com.bank.app
```

| setting | description | required |
| ---- | -- | -- |
| application_name | Your application's name | yes |
| dart_package_name | The dart package name (used in all imports in your `lib` or `test` directories) | no |
| application_id | The android `application_id`, must be unique on the Play Store | no |
| bundle_id | The iOS `bundle_id`, must be unique on the Apple Store | no |
| android_package_name | The android `package_name`, used only for the architecture of your android files | no |

## Run package

Make sure that your current working directory is the project root.

> Make sure to be able to get back to previous state in case something went wrong, by commiting your work before running the package for example.


```
flutter pub get
flutter pub run flutter_rename_app
```
