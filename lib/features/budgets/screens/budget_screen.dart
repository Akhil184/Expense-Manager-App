import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/budget_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: Consumer<BudgetProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.budgets.isEmpty) {
            return const Center(child: Text('No budgets added yet.'));
          }

          return RefreshIndicator(
            onRefresh: provider.loadBudgets,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.budgets.length,
              itemBuilder: (context, index) {
                final budget = provider.budgets[index];
                final spent = provider.getSpentAmount(
                  category: budget.category,
                  month: budget.month,
                  year: budget.year,
                );

                final remaining = provider.getRemainingAmount(budget);
                final percentage = provider.getUsagePercentage(budget);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                budget.category,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddBudgetScreen(
                                          budgetId: budget.id,
                                          category: budget.category,
                                          amount: budget.amount,
                                          month: budget.month,
                                          year: budget.year,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    await provider.deleteBudget(budget.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Budget: ₹${budget.amount.toStringAsFixed(2)}'),
                        Text('Spent: ₹${spent.toStringAsFixed(2)}'),
                        Text(
                          'Remaining: ₹${remaining.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: remaining < 0 ? Colors.red : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: percentage,
                          minHeight: 8,
                          color: percentage >= 1 ? Colors.red : Colors.green,
                        ),
                        const SizedBox(height: 6),
                        Text('${(percentage * 100).toStringAsFixed(0)}% used'),
                        Text(
                          '${budget.month}/${budget.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddBudgetScreen extends StatefulWidget {
  final String? budgetId;
  final String? category;
  final double? amount;
  final int? month;
  final int? year;

  const AddBudgetScreen({
    super.key,
    this.budgetId,
    this.category,
    this.amount,
    this.month,
    this.year,
  });

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String _category = 'Food';

  final List<String> _categories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Health',
    'Entertainment',
    'Other',
  ];

  bool get _isEditing => widget.budgetId != null;
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _category = widget.category ?? 'Food';
    _selectedMonth = widget.month ?? now.month;
    _selectedYear = widget.year ?? now.year;

    if (widget.amount != null) {
      _amountController.text = widget.amount.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    final provider = context.read<BudgetProvider>();

    try {
      if (_isEditing) {
        await provider.updateBudget(
          id: widget.budgetId!,
          category: _category,
          amount: amount,
          month: _selectedMonth,
          year: _selectedYear,
        );
      } else {
        await provider.addBudget(
          category: _category,
          amount: amount,
          month: _selectedMonth,
          year: _selectedYear,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Budget updated successfully'
                : 'Budget added successfully',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save budget: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Budget' : 'Add Budget')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'Month',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(12, (index) {
                  final month = index + 1;

                  return DropdownMenuItem(
                    value: month,
                    child: Text(
                      [
                        'January',
                        'February',
                        'March',
                        'April',
                        'May',
                        'June',
                        'July',
                        'August',
                        'September',
                        'October',
                        'November',
                        'December',
                      ][month - 1],
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMonth = value);
                  }
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(6, (index) {
                  final year = DateTime.now().year + index - 2;

                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedYear = value);
                  }
                },
              ),
              SizedBox(height:15,),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');

                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00B894),
                        Color(0xFF009B77),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B894).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _saveBudget,
                    icon: Icon(
                      _isEditing ? Icons.edit_rounded : Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isEditing ? 'Update Budget' : 'Save Budget',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
