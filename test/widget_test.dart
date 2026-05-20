// Smoke test: the app boots and renders its first frame without throwing.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazan/app.dart';

void main() {
  testWidgets('App boots without exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: QazanApp()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
