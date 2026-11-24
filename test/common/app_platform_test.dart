import 'package:bookish/ui/common/app_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPlatformTest -', () {
    tearDown(() => AppPlatform.debugOverride = null);

    group('iosMajorVersion -', () {
      test('Reads the major version from iOS version strings', () {
        expect(AppPlatform.iosMajorVersion('Version 26.1 (Build 23B82)'), 26);
        expect(AppPlatform.iosMajorVersion('Version 18.6 (Build 22G86)'), 18);
        expect(AppPlatform.iosMajorVersion('26.0'), 26);
      });

      test('Unreadable version gives 0, so classic UI is used', () {
        expect(AppPlatform.iosMajorVersion(''), 0);
        expect(AppPlatform.iosMajorVersion('unknown'), 0);
      });
    });

    test('debugOverride wins over detection', () {
      AppPlatform.debugOverride = AppPlatform.iosGlass;
      expect(AppPlatform.current, AppPlatform.iosGlass);
      expect(AppPlatform.current.isIos, isTrue);
    });

    test('Only Android is not iOS', () {
      expect(AppPlatform.android.isIos, isFalse);
      expect(AppPlatform.iosClassic.isIos, isTrue);
    });
  });
}
