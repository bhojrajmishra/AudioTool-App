import 'package:flutter_test/flutter_test.dart';
import 'package:audiobook_record/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('HomeViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
