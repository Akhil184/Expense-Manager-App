
import 'package:expense_manager_app/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

import 'data/local/database/app_database.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/budget_repository.dart';

import 'features/dashboard/screens/main_navigation_screen.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'data/repositories/recurring_transaction_repository.dart';
import 'providers/recurring_transaction_provider.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme
  final themeProvider = await ThemeProvider.create();

  // Initialize database
  final database = AppDatabase();

  // Initialize transaction repository
  final transactionRepository = TransactionRepository(
    database.transactionDao,
  );

  // Initialize budget repository
  final budgetRepository = BudgetRepository(
    database.budgetDao,
  );

  final categoryRepository = CategoryRepository(
    database.categoryDao,
  );

  final recurringTransactionRepository =
  RecurringTransactionRepository(database.recurringTransactionDao);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: themeProvider,
        ),

        ChangeNotifierProvider(
          create: (_) => TransactionProvider(
            transactionRepository,
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => BudgetProvider(
            budgetRepository,
            transactionRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RecurringTransactionProvider(
            recurringTransactionRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(categoryRepository),
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expense Manager',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
