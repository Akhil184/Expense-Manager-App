import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

import '../data/local/database/app_database.dart';
import '../data/repositories/recurring_transaction_repository.dart';
import '../data/repositories/transaction_repository.dart';

class RecurringTransactionProvider extends ChangeNotifier {
  final RecurringTransactionRepository _repository;

  final TransactionRepository _transactionRepository;

  RecurringTransactionProvider(this._repository, this._transactionRepository) {
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

  DateTime _calculateNextDueDate(DateTime date, String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return date.add(const Duration(days: 1));

      case 'weekly':
        return date.add(const Duration(days: 7));

      case 'monthly':
        final nextMonth = DateTime(date.year, date.month + 1, 1);
        final lastDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;

        return DateTime(
          nextMonth.year,
          nextMonth.month,
          date.day > lastDay ? lastDay : date.day,
        );

      case 'yearly':
        final nextYear = date.year + 1;
        final lastDay = DateTime(nextYear, date.month + 1, 0).day;

        return DateTime(
          nextYear,
          date.month,
          date.day > lastDay ? lastDay : date.day,
        );

      default:
        throw ArgumentError('Unsupported frequency: $frequency');
    }
  }

  Future<void> generateDueTransactions() async {
    final now = DateTime.now();

    final schedules = await _repository.getAllRecurringTransactions();

    for (final schedule in schedules) {
      if (!schedule.isActive) continue;

      var dueDate = schedule.nextDueDate;

      while (!dueDate.isAfter(now)) {
        final transactionId =
            'recurring_${schedule.id}_${dueDate.microsecondsSinceEpoch}';

        final transaction = TransactionsCompanion.insert(
          id: transactionId,
          title: schedule.title,
          amount: schedule.amount,
          type: schedule.type,
          category: schedule.category,
          note: Value(schedule.note),
          transactionDate: dueDate,
          createdAt: now,
          updatedAt: now,
        );

        await _transactionRepository.addRecurringTransaction(transaction);

        final nextDate = _calculateNextDueDate(dueDate, schedule.frequency);

        await _repository.updateRecurringSchedule(
          id: schedule.id,
          nextDueDate: nextDate,
          lastGeneratedDate: dueDate,
        );

        dueDate = nextDate;
      }
    }

    await loadRecurringTransactions();
  }
}
