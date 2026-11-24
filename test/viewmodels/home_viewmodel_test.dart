import 'package:flutter_test/flutter_test.dart';
import 'package:bookish/app/app.locator.dart';
import 'package:bookish/ui/views/home/home_viewmodel.dart';

import '../helpers/test_helpers.dart';

void main() {
  HomeViewModel getModel() => HomeViewModel();

  group('HomeViewmodelTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    test('Starts on the first tab', () {
      expect(getModel().currentIndex, 0);
    });

    test('setIndex switches tabs', () {
      final model = getModel();
      model.setIndex(1);
      expect(model.currentIndex, 1);
    });
  });
}
