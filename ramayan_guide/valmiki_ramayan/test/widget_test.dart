import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valmiki_ramayan/main.dart';
import 'package:valmiki_ramayan/providers/language_provider.dart';
import 'package:valmiki_ramayan/services/local_storage_service.dart';

void main() {
  testWidgets('App initializes successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final localStorageService = LocalStorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(localStorageService),
        ],
        child: const ValmikiRamayanApp(),
      ),
    );

    expect(find.byType(ValmikiRamayanApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
