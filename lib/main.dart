import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';

import 'data/datasources/database_helper.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';
import 'data/repositories/wallet_repository_impl.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/wallet_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper.instance;

  // Repositories
  final transactionRepo = TransactionRepositoryImpl(dbHelper);
  final categoryRepo = CategoryRepositoryImpl(dbHelper);
  final walletRepo = WalletRepositoryImpl(dbHelper);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              TransactionProvider(transactionRepo)..loadTransactions(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(categoryRepo)..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletProvider(walletRepo)..loadWallets(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mmoney Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
