import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/datasources/database_helper.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dbHelper = DatabaseHelper.instance;
  
  // Repositories
  final transactionRepo = TransactionRepositoryImpl(dbHelper);
  final categoryRepo = CategoryRepositoryImpl(dbHelper);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider(transactionRepo)..loadTransactions()),
        ChangeNotifierProvider(create: (_) => CategoryProvider(categoryRepo)..loadCategories()),
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: const DashboardScreen(),
    );
  }
}
