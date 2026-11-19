import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

import '../data/local/database/app_database.dart';
import '../data/repositories/recurring_transaction_repository.dart';

class RecurringTransactionProvider extends ChangeNotifier {
  final RecurringTransactionRepository _repository;

  RecurringTransactionProvider(this._repository) {
    loadRecurringTransactions();
  }

  List<RecurringTransaction> _recurringTransactions = [];

  bool _isLoading = false;
  String? _error;

  List<RecurringTransaction> get recurringTransactions =>
      _recurringTransactions;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // Load recurring transactions
  Future<void> loadRecurringTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recurringTransactions = await _repository.getAllRecurringTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add recurring transaction
  Future<void> addRecurringTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
    String? note,
    required String frequency,
    required DateTime nextDueDate,
  }) async {
    final now = DateTime.now();

    final recurringTransaction = RecurringTransactionsCompanion.insert(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      amount: amount,
      type: type,
      category: category,
      note: Value(note?.trim().isEmpty == true ? null : note?.trim()),
      frequency: frequency,
      nextDueDate: nextDueDate,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.addRecurringTransaction(recurringTransaction);
    await loadRecurringTransactions();
  }

  // Update recurring transaction
  Future<void> updateRecurringTransaction({
    required String id,
    required String title,
    required double amount,
    required String type,
    required String category,
    String? note,
    required String frequency,
    required DateTime nextDueDate,
  }) async {
    final recurringTransaction = RecurringTransactionsCompanion(
      id: Value(id),
      title: Value(title.trim()),
      amount: Value(amount),
      type: Value(type),
      category: Value(category),
      note: Value(note?.trim().isEmpty == true ? null : note?.trim()),
      frequency: Value(frequency),
      nextDueDate: Value(nextDueDate),
      updatedAt: Value(DateTime.now()),
    );

    await _repository.updateRecurringTransaction(recurringTransaction);
    await loadRecurringTransactions();
  }

  // Pause or resume recurring transaction
  Future<void> updateRecurringStatus(String id, bool isActive) async {
    await _repository.updateRecurringStatus(id, isActive);
    await loadRecurringTransactions();
  }

  // Delete recurring transaction
  Future<void> deleteRecurringTransaction(String id) async {
    await _repository.deleteRecurringTransaction(id);
    await loadRecurringTransactions();
  }
}
