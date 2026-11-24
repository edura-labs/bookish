import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Which UI the app renders. Decided once, here, and nowhere else:
/// views and widgets never check `Platform` or OS versions themselves.
enum AppPlatform {
  /// Material 3, following Android design guidelines.
  android,

  /// iOS 25 and below: native-looking Cupertino UI, no glass.
  iosClassic,

  /// iOS 26 and above: Cupertino UI with Liquid Glass navigation chrome.
  iosGlass;

  bool get isIos => this != AppPlatform.android;

  /// Forces a platform in tests and goldens. Leave null in the app.
  @visibleForTesting
  static AppPlatform? debugOverride;

  static final AppPlatform _detected = _detect();

  static AppPlatform get current => debugOverride ?? _detected;

  /// Whether to render Liquid Glass here: iOS 26+, unless the user has turned
  /// on Increase Contrast, which gets the solid Cupertino version instead.
  static bool usesGlass(BuildContext context) =>
      current == AppPlatform.iosGlass && !MediaQuery.highContrastOf(context);

  /// First iOS version with Liquid Glass.
  static const glassMinimumIosVersion = 26;

  static AppPlatform _detect() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return AppPlatform.android;
    }
    final major = iosMajorVersion(Platform.operatingSystemVersion);
    return major >= glassMinimumIosVersion
        ? AppPlatform.iosGlass
        : AppPlatform.iosClassic;
  }

  /// Reads the major version from iOS's `operatingSystemVersion`, which looks
  /// like `Version 26.1 (Build 23B82)`. Returns 0 when it can't be read, so an
  /// unknown version gets the safe classic UI rather than glass.
  @visibleForTesting
  static int iosMajorVersion(String operatingSystemVersion) {
    final match = RegExp(r'(\d+)').firstMatch(operatingSystemVersion);
    return match == null ? 0 : int.parse(match.group(1)!);
  }
}
