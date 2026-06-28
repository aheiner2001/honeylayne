import 'package:flutter_test/flutter_test.dart';

import 'package:honeylayne/data/backend.dart';
import 'package:honeylayne/data/store.dart';
import 'package:honeylayne/main.dart';

void main() {
  testWidgets('Storefront renders the Honey Layne wordmark', (tester) async {
    final store = HoneyStore(LocalBackend());
    await tester.pumpWidget(HoneyApp(store: store));
    await tester.pump();

    expect(find.text('Honey Layne'), findsWidgets);
  });
}
