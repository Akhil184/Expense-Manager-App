import 'package:expense_manager_app/features/transactions/screens/recurring_transaction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/local/database/app_database.dart';
import '../../../providers/transaction_provider.dart';
import 'add_recurring_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions'),actions: [
        IconButton(
          icon: const Icon(Icons.repeat),
          tooltip: 'Add Recurring Transaction',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const  RecurringTransactionListScreen(),
              ),
            );
          },
        ),
      ],),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final transactions = provider.filteredTransactions;

          final categories =
              provider.transactions
                  .map((transaction) => transaction.category)
                  .toSet()
                  .toList()
                ..sort();

          return Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    provider.applyFilters(search: value);
                  },
                ),
              ),

              // Type and category filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: provider.selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(
                            value: 'expense',
                            child: Text('Expense'),
                          ),
                          DropdownMenuItem(
                            value: 'income',
                            child: Text('Income'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            provider.applyFilters(type: value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: categories.contains(provider.selectedCategory)
                            ? provider.selectedCategory
                            : 'all',
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'all',
                            child: Text('All'),
                          ),
                          ...categories.map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            provider.applyFilters(category: value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Date range filter
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          provider.startDate == null
                              ? 'Select Date Range'
                              : '${provider.startDate!.day}/${provider.startDate!.month}/${provider.startDate!.year}'
                                    ' - '
                                    '${provider.endDate!.day}/${provider.endDate!.month}/${provider.endDate!.year}',
                        ),
                        onPressed: () async {
                          final now = DateTime.now();

                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: now,
                            initialDateRange:
                                provider.startDate != null &&
                                    provider.endDate != null
                                ? DateTimeRange(
                                    start: provider.startDate!,
                                    end: provider.endDate!,
                                  )
                                : null,
                          );

                          if (picked != null) {
                            provider.applyFilters(
                              startDate: picked.start,
                              endDate: picked.end,
                            );
                          }
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.applyFilters(
                          search: '',
                          type: 'all',
                          category: 'all',
                          clearDates: true,
                        );
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Transaction count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${transactions.length} transactions found',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Transaction list
              Expanded(
                child: transactions.isEmpty
                    ? const Center(child: Text('No transactions found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];

                          return _buildTransactionCard(context, transaction);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
    final isIncome = transaction.type == 'income';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.red.withValues(alpha: 0.15),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.category} • '
          '${transaction.transactionDate.day}/'
          '${transaction.transactionDate.month}/'
          '${transaction.transactionDate.year}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}₹'
              '${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                _confirmDelete(context, transaction.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: const Text(
            'Are you sure you want to delete this transaction?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await context.read<TransactionProvider>().deleteTransaction(
                    id,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction deleted')),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
