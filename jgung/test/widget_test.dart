import 'package:flutter_test/flutter_test.dart';
import 'package:jgung/main.dart';

void main() {
  testWidgets('App basic initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaniJagungApp());
    expect(find.byType(TaniJagungApp), findsOneWidget);
  });
}
