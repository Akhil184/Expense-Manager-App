import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

import '../data/local/database/app_database.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/transaction_repository.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _budgetRepository;
  final TransactionRepository _transactionRepository;

  BudgetProvider(this._budgetRepository, this._transactionRepository) {
    loadBudgets();
  }

  List<Budget> _budgets = [];
  List<Transaction> _transactions = [];

  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load budgets and transactions
  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _budgetRepository.getAllBudgets();
      _transactions = await _transactionRepository.getAllTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add budget
  Future<void> addBudget({
    required String category,
    required double amount,
    required int month,
    required int year,
  }) async {
    final budget = BudgetsCompanion.insert(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      category: category,
      amount: amount,
      month: month,
      year: year,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _budgetRepository.addBudget(budget);
    await loadBudgets();
  }

  // Update budget
  Future<void> updateBudget({
    required String id,
    required String category,
    required double amount,
    required int month,
    required int year,
  }) async {
    final budget = BudgetsCompanion(
      id: Value(id),
      category: Value(category),
      amount: Value(amount),
      month: Value(month),
      year: Value(year),
      updatedAt: Value(DateTime.now()),
    );

    await _budgetRepository.updateBudget(budget);
    await loadBudgets();
  }

  // Delete budget
  Future<void> deleteBudget(String id) async {
    await _budgetRepository.deleteBudget(id);
    await loadBudgets();
  }

  // Get spending for a category in a given month
  double getSpentAmount({
    required String category,
    required int month,
    required int year,
  }) {
    return _transactions
        .where(
          (transaction) =>
              transaction.type == 'expense' &&
              transaction.category == category &&
              transaction.transactionDate.month == month &&
              transaction.transactionDate.year == year,
        )
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  // Get remaining budget
  double getRemainingAmount(Budget budget) {
    final spent = getSpentAmount(
      category: budget.category,
      month: budget.month,
      year: budget.year,
    );

    return budget.amount - spent;
  }

  // Check whether the budget is exceeded
  bool isBudgetExceeded(Budget budget) {
    return getRemainingAmount(budget) < 0;
  }

  // Get budget usage percentage
  double getUsagePercentage(Budget budget) {
    if (budget.amount <= 0) return 0;

    final spent = getSpentAmount(
      category: budget.category,
      month: budget.month,
      year: budget.year,
    );

    return (spent / budget.amount).clamp(0.0, 1.0);
  }
}
