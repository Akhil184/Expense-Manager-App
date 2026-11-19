
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/recurring_transaction_provider.dart';
import 'add_recurring_transaction_screen.dart';

class RecurringTransactionListScreen extends StatelessWidget {
  const RecurringTransactionListScreen({super.key});

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> confirmDelete(
      BuildContext context,
      String id,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete recurring transaction?'),
        content: const Text(
          'Are you sure you want to delete this recurring transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context
          .read<RecurringTransactionProvider>()
          .deleteRecurringTransaction(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
      ),
      body: Consumer<RecurringTransactionProvider>(
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

          final transactions = provider.recurringTransactions;

          if (transactions.isEmpty) {
            return const Center(
              child: Text('No recurring transactions found.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Icon(
                            transaction.type == 'income'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                          ),
                        ),
                        title: Text(
                          transaction.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${transaction.category} • '
                              '${transaction.frequency}',
                        ),
                        trailing: Text(
                          '₹${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: transaction.type == 'income'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),

                      const Divider(),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Next due: '
                                  '${formatDate(transaction.nextDueDate)}',
                            ),
                          ),
                          const Text('Active'),
                          Switch(
                            value: transaction.isActive,
                            onChanged: (value) {
                              provider.updateRecurringStatus(
                                transaction.id,
                                value,
                              );
                            },
                          ),
                        ],
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            confirmDelete(
                              context,
                              transaction.id,
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const AddRecurringTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
