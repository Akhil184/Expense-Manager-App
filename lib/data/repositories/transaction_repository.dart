import 'package:drift/drift.dart';

import '../local/database/app_database.dart';
import '../local/dao/transaction_dao.dart';

class TransactionRepository {
  final TransactionDao _transactionDao;

  TransactionRepository(this._transactionDao);

  // Add a transaction
  Future<int> addTransaction(TransactionsCompanion transaction) {
    return _transactionDao.insertTransaction(transaction);
  }

  // Get all active transactions
  Future<List<Transaction>> getAllTransactions() {
    return _transactionDao.getAllTransactions();
  }

  // Watch transactions for automatic UI updates
  Stream<List<Transaction>> watchTransactions() {
    return _transactionDao.watchTransactions();
  }

  // Get a transaction by ID
  Future<Transaction?> getTransactionById(String id) {
    return _transactionDao.getTransactionById(id);
  }

  Future<int> addRecurringTransaction(TransactionsCompanion transaction) {
    return _transactionDao.insertRecurringTransaction(transaction);
  }

  // Update a transaction
  Future<int> updateTransaction(TransactionsCompanion transaction) {
    return _transactionDao.updateTransaction(transaction);
  }

  // Soft-delete a transaction
  Future<void> deleteTransaction(String id) {
    return _transactionDao.deleteTransaction(id);
  }

  // Get transactions with pagination
  Future<List<Transaction>> getTransactionsPaginated({
    required int limit,
    required int offset,
  }) {
    return _transactionDao.getTransactionsPaginated(
      limit: limit,
      offset: offset,
    );
  }
}
