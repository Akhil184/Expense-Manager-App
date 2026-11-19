import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/savings_goal_provider.dart';
import 'add_savings_goal_screen.dart';

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: Consumer<SavingsGoalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final goals = provider.savingsGoals;

          if (goals.isEmpty) {
            return const Center(child: Text('No savings goals yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final progress = provider.getProgress(goal);
              final remaining = provider.getRemainingAmount(goal);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.savings,
                            size: 30,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              goal.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'add') {
                                await _showAddMoneyDialog(context, goal.id);
                              } else if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddSavingsGoalScreen(goal: goal),
                                  ),
                                );
                              } else if (value == 'delete') {
                                await _confirmDelete(context, goal.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'add',
                                child: Text('Add Money'),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '₹${goal.currentAmount.toStringAsFixed(2)} '
                        'of ₹${goal.targetAmount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Remaining: ₹${remaining.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (goal.targetDate != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Target date: '
                          '${goal.targetDate!.day}/'
                          '${goal.targetDate!.month}/'
                          '${goal.targetDate!.year}',
                        ),
                      ],
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
            MaterialPageRoute(builder: (_) => const AddSavingsGoalScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddMoneyDialog(BuildContext context, String goalId) async {
    final provider = context.read<SavingsGoalProvider>();

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return const AddMoneyDialog();
      },
    );

    if (amount != null && context.mounted) {
      await provider.addMoney(id: goalId, amount: amount);
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: const Text(
          'Are you sure you want to delete this savings goal?',
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
      await context.read<SavingsGoalProvider>().deleteSavingsGoal(id);
    }
  }
}

class AddMoneyDialog extends StatefulWidget {
  const AddMoneyDialog({super.key});

  @override
  State<AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addAmount() {
    final amount = double.tryParse(_controller.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Money'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _addAmount, child: const Text('Add')),
      ],
    );
  }
}
