import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

import '../data/local/database/app_database.dart';
import '../data/repositories/savings_goal_repository.dart';

class SavingsGoalProvider extends ChangeNotifier {
  final SavingsGoalRepository _repository;

  SavingsGoalProvider(this._repository) {
    loadSavingsGoals();
  }

  List<SavingsGoal> _savingsGoals = [];
  bool _isLoading = false;
  String? _error;

  List<SavingsGoal> get savingsGoals => _savingsGoals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load savings goals
  Future<void> loadSavingsGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _savingsGoals = await _repository.getAllSavingsGoals();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add savings goal
  Future<void> addSavingsGoal({
    required String title,
    required double targetAmount,
    DateTime? targetDate,
  }) async {
    final now = DateTime.now();

    final goal = SavingsGoalsCompanion.insert(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      targetAmount: targetAmount,
      targetDate: Value(targetDate),
      createdAt: now,
      updatedAt: now,
    );

    await _repository.addSavingsGoal(goal);
    await loadSavingsGoals();
  }

  // Update savings goal
  Future<void> updateSavingsGoal({
    required String id,
    required String title,
    required double targetAmount,
    DateTime? targetDate,
  }) async {
    final goal = SavingsGoalsCompanion(
      id: Value(id),
      title: Value(title),
      targetAmount: Value(targetAmount),
      targetDate: Value(targetDate),
      updatedAt: Value(DateTime.now()),
    );

    await _repository.updateSavingsGoal(goal);
    await loadSavingsGoals();
  }

  // Add money to savings goal
  Future<void> addMoney({required String id, required double amount}) async {
    final goal = _savingsGoals.firstWhere((goal) => goal.id == id);

    final updatedAmount = goal.currentAmount + amount;

    await _repository.updateCurrentAmount(id, updatedAmount);

    await loadSavingsGoals();
  }

  // Delete savings goal
  Future<void> deleteSavingsGoal(String id) async {
    await _repository.deleteSavingsGoal(id);
    await loadSavingsGoals();
  }

  // Calculate progress
  double getProgress(SavingsGoal goal) {
    if (goal.targetAmount <= 0) return 0;

    return (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
  }

  // Remaining amount
  double getRemainingAmount(SavingsGoal goal) {
    return (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);
  }
}
