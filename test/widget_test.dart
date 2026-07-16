import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:moni/main.dart';
import 'package:moni/providers/finance_provider.dart';

void main() {
  testWidgets('Onboarding screen title smoke test', (WidgetTester tester) async {
    final provider = FinanceProvider();
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: const MyApp(hasSeenOnboarding: false),
      ),
    );

    // Verify that onboarding screen shows the title 'MONI'
    expect(find.text('MONI'), findsOneWidget);
  });
}
