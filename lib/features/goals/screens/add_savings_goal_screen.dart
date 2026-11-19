import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/local/database/app_database.dart';
import '../../../providers/savings_goal_provider.dart';

class AddSavingsGoalScreen extends StatefulWidget {
  final SavingsGoal? goal;

  const AddSavingsGoalScreen({super.key, this.goal});

  @override
  State<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _targetDate;
  bool _isSaving = false;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _titleController.text = widget.goal!.title;
      _amountController.text = widget.goal!.targetAmount.toString();
      _targetDate = widget.goal!.targetDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectTargetDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _targetDate = selectedDate;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<SavingsGoalProvider>();

      final title = _titleController.text.trim();
      final amount = double.parse(_amountController.text.trim());

      if (_isEditing) {
        await provider.updateSavingsGoal(
          id: widget.goal!.id,
          title: title,
          targetAmount: amount,
          targetDate: _targetDate,
        );
      } else {
        await provider.addSavingsGoal(
          title: title,
          targetAmount: amount,
          targetDate: _targetDate,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Savings goal updated' : 'Savings goal added',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save goal: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Savings Goal' : 'Add Savings Goal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  prefixIcon: Icon(Icons.savings),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter goal name';
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
                  labelText: 'Target Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');

                  if (amount == null || amount <= 0) {
                    return 'Enter a valid target amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectTargetDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Target Date (Optional)',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _targetDate == null
                        ? 'Select target date'
                        : '${_targetDate!.day}/'
                              '${_targetDate!.month}/'
                              '${_targetDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isSaving
                          ? [Colors.grey, Colors.blueGrey]
                          : const [
                        Color(0xFF6C63FF),
                        Color(0xFF4834D4),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      if (!_isSaving)
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveGoal,
                    icon: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Icon(
                      _isEditing ? Icons.edit_rounded : Icons.savings_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isSaving
                          ? 'Please wait...'
                          : _isEditing
                          ? 'Update Goal'
                          : 'Save Goal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
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
