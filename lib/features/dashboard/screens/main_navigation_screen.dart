
import 'package:flutter/material.dart';

import '../../dashboard/screens/dashboard_screen.dart';
import '../../transactions/screens/transaction_list_screen.dart';
import '../../analytics/screens/analytics_screen.dart';
import '../../budgets/screens/budget_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../widgets/custom_bottom_navigation.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionListScreen(),
    AnalyticsScreen(),
    BudgetScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
