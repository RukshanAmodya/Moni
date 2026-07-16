import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:moni/main.dart';
import 'package:moni/providers/finance_provider.dart';
import 'package:moni/providers/auth_provider.dart';

void main() {
  testWidgets('Onboarding screen title smoke test', (WidgetTester tester) async {
    final financeProvider = FinanceProvider();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => financeProvider),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MyApp(hasSeenOnboarding: false),
      ),
    );

    // Verify that onboarding screen shows the title 'MONI'
    expect(find.text('Moni'), findsOneWidget);
  });
}
