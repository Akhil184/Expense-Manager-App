import 'dart:async';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

import '../data/local/database/app_database.dart';
import '../data/repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionProvider(this._repository) {
    loadTransactions();
  }

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  String _selectedType = 'all';
  String _selectedCategory = 'all';

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  String get selectedCategory => _selectedCategory;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome {
    return _transactions
        .where((transaction) => transaction.type == 'income')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalExpense {
    return _transactions
        .where((transaction) => transaction.type == 'expense')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get balance => totalIncome - totalExpense;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _repository.getAllTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionsCompanion transaction) async {
    await _repository.addTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionsCompanion transaction) async {
    await _repository.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    await loadTransactions();
  }

  void applyFilters({
    String? search,
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    if (search != null) _searchQuery = search.toLowerCase();
    if (type != null) _selectedType = type;
    if (category != null) _selectedCategory = category;

    if (clearDates) {
      _startDate = null;
      _endDate = null;
    } else {
      if (startDate != null) _startDate = startDate;
      if (endDate != null) _endDate = endDate;
    }

    notifyListeners();
  }

  List<Transaction> get filteredTransactions {
    return _transactions.where((transaction) {
      final matchesSearch = transaction.title.toLowerCase().contains(
        _searchQuery,
      );

      final matchesType =
          _selectedType == 'all' || transaction.type == _selectedType;

      final matchesCategory =
          _selectedCategory == 'all' ||
          transaction.category == _selectedCategory;

      final transactionDate = transaction.transactionDate;

      final matchesStartDate =
          _startDate == null ||
          !transactionDate.isBefore(
            DateTime(_startDate!.year, _startDate!.month, _startDate!.day),
          );

      final matchesEndDate =
          _endDate == null ||
          !transactionDate.isAfter(
            DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day,
              23,
              59,
              59,
            ),
          );

      return matchesSearch &&
          matchesType &&
          matchesCategory &&
          matchesStartDate &&
          matchesEndDate;
    }).toList();
  }
}
