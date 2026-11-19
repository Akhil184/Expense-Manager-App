import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/transaction_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final income = provider.totalIncome;
          final expense = provider.totalExpense;
          final savings = income - expense;

          final expenses = provider.transactions
              .where((transaction) => transaction.type == 'expense')
              .toList();

          final Map<String, double> categoryTotals = {};

          for (final transaction in expenses) {
            categoryTotals[transaction.category] =
                (categoryTotals[transaction.category] ?? 0) +
                transaction.amount;
          }

          final sortedCategories = categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final highestExpense = sortedCategories.isEmpty
              ? 0.0
              : sortedCategories.first.value;

          final total = income + expense;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Financial Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _summaryCard(
                title: 'Total Income',
                amount: income,
                color: Colors.green,
                icon: Icons.trending_up,
              ),

              _summaryCard(
                title: 'Total Expenses',
                amount: expense,
                color: Colors.red,
                icon: Icons.trending_down,
              ),

              _summaryCard(
                title: 'Savings',
                amount: savings,
                color: Colors.blue,
                icon: Icons.account_balance_wallet,
              ),

              const SizedBox(height: 24),

              const Text(
                'Income vs Expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _comparisonBar(
                title: 'Income',
                amount: income,
                total: total,
                color: Colors.green,
              ),

              const SizedBox(height: 16),

              _comparisonBar(
                title: 'Expenses',
                amount: expense,
                total: total,
                color: Colors.red,
              ),

              const SizedBox(height: 28),

              const Text(
                'Expenses by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              if (sortedCategories.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No expense data available.'),
                  ),
                )
              else
                ...sortedCategories.map((entry) {
                  return _categoryItem(
                    category: entry.key,
                    amount: entry.value,
                    highestExpense: highestExpense,
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _comparisonBar({
    required String title,
    required double amount,
    required double total,
    required Color color,
  }) {
    final progress = total > 0 ? amount / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title), Text('₹${amount.toStringAsFixed(2)}')],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          color: color,
          backgroundColor: Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _categoryItem({
    required String category,
    required double amount,
    required double highestExpense,
  }) {
    final progress = highestExpense > 0 ? amount / highestExpense : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }
}
