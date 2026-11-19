import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/recurring_transaction_provider.dart';
import '../../../providers/category_provider.dart';

class AddRecurringTransactionScreen extends StatefulWidget {
  const AddRecurringTransactionScreen({super.key});

  @override
  State<AddRecurringTransactionScreen> createState() =>
      _AddRecurringTransactionScreenState();
}

class _AddRecurringTransactionScreenState
    extends State<AddRecurringTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  String _frequency = 'monthly';
  String _category = 'Food';

  DateTime _nextDueDate = DateTime.now();

  List<String> _getDefaultCategories() {
    if (_type == 'income') {
      return ['Salary', 'Business', 'Investment', 'Gift', 'Other'];
    }

    return [
      'Food',
      'Travel',
      'Shopping',
      'Bills',
      'Health',
      'Entertainment',
      'Other',
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _nextDueDate = pickedDate;
      });
    }
  }

  Future<void> _saveRecurringTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) return;

    try {
      await context
          .read<RecurringTransactionProvider>()
          .addRecurringTransaction(
            title: _titleController.text.trim(),
            amount: amount,
            type: _type,
            category: _category,
            note: _noteController.text,
            frequency: _frequency,
            nextDueDate: _nextDueDate,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recurring transaction added successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final customCategories = context
        .watch<CategoryProvider>()
        .categories
        .where((category) => category.type == _type)
        .map((category) => category.name)
        .toList();

    final categoryOptions = {
      ..._getDefaultCategories(),
      ...customCategories,
    }.toList();

    final selectedCategory = categoryOptions.contains(_category)
        ? _category
        : categoryOptions.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Recurring Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
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
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                      _category = _getDefaultCategories().first;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categoryOptions.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Repeat Frequency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _frequency = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  'Next Due Date: '
                  '${_nextDueDate.day}/${_nextDueDate.month}/${_nextDueDate.year}',
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveRecurringTransaction,
                  child: const Text('Save Recurring Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
