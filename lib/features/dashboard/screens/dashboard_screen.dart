
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/transaction_provider.dart';
import '../../transactions/screens/add_transaction_screen.dart';
import '../../transactions/screens/transaction_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings screen will be connected later.
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Text('Error: ${provider.error}'),
            );
          }

          final transactions = provider.transactions;

          final recentTransactions = transactions.take(5).toList();

          return RefreshIndicator(
            onRefresh: provider.loadTransactions,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBalanceCard(provider),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Income',
                        amount: provider.totalIncome,
                        color: Colors.green,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Expenses',
                        amount: provider.totalExpense,
                        color: Colors.red,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const TransactionListScreen(),
                          ),
                        );
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (recentTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No transactions yet.'),
                    ),
                  )
                else
                  ...recentTransactions.map((transaction) {
                    final isIncome = transaction.type == 'income';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            isIncome
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isIncome
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        title: Text(transaction.title),
                        subtitle: Text(transaction.category),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}₹'
                              '${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isIncome
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(TransactionProvider provider) {
    return Card(
      elevation: 3,
      color: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '₹${provider.balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(title),
            const SizedBox(height: 6),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
