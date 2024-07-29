import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gratitude_diary/resources/resources.dart';

void main() {
  test('images assets test', () {
    expect(File(Images.google).existsSync(), isTrue);
  });
}
