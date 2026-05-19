import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:money_monitoring_app/main.dart';
import 'package:money_monitoring_app/presentation/providers/transaction_provider.dart';
import 'package:money_monitoring_app/presentation/providers/category_provider.dart';
import 'package:money_monitoring_app/presentation/providers/wallet_provider.dart';
import 'provider_unit_test.dart';

void main() {
  testWidgets('App starts and displays splash screen title', (
    WidgetTester tester,
  ) async {
    final mockTxRepo = MockTransactionRepository();
    final mockCategoryRepo = MockCategoryRepository();
    final mockWalletRepo = MockWalletRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => TransactionProvider(mockTxRepo)..loadTransactions(),
          ),
          ChangeNotifierProvider(
            create: (_) => CategoryProvider(mockCategoryRepo)..loadCategories(),
          ),
          ChangeNotifierProvider(
            create: (_) => WalletProvider(mockWalletRepo)..loadWallets(),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that SplashScreen builds and displays the app name
    expect(find.text('Money Flow'), findsOneWidget);
    expect(find.text('Personal Finance Monitor'), findsOneWidget);

    // Settle the splash timer and transition
    await tester.pumpAndSettle(const Duration(milliseconds: 3500));
  });
}
