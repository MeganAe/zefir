import 'package:flutter_test/flutter_test.dart';
import 'package:zefir/app.dart';

void main() {
  testWidgets('Zefir smoke test - Navigation Bar rendering', (WidgetTester tester) async {
    await tester.pumpWidget(const ZefirApp());
    expect(find.text('COMPRESSION'), findsWidgets);
    expect(find.text('HISTORIQUE'), findsWidgets);
    expect(find.text('PARAMÈTRES'), findsWidgets);
  });
}
