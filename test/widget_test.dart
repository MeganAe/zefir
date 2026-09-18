import 'package:flutter_test/flutter_test.dart';
import 'package:zefir/app.dart';

void main() {
  testWidgets('Zefir smoke test - Navigation Bar rendering',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ZefirApp());
    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Recherche'), findsWidgets);
    expect(find.text('Favoris'), findsWidgets);
    expect(find.text('Paramètres'), findsWidgets);
  });
}
