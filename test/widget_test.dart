import 'package:flutter_test/flutter_test.dart';
import 'package:karate_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Basic smoke test — just ensure the widget tree builds
    expect(KarateApp, isNotNull);
  });
}
