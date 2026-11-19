import '../local/database/app_database.dart';
import '../local/dao/recurring_transaction_dao.dart';

class RecurringTransactionRepository {
  final RecurringTransactionDao _recurringTransactionDao;

  RecurringTransactionRepository(this._recurringTransactionDao);

  // Add recurring transaction
  Future<int> addRecurringTransaction(
    RecurringTransactionsCompanion recurringTransaction,
  ) {
    return _recurringTransactionDao.addRecurringTransaction(
      recurringTransaction,
    );
  }

  // Get all recurring transactions
  Future<List<RecurringTransaction>> getAllRecurringTransactions() {
    return _recurringTransactionDao.getAllRecurringTransactions();
  }

  // Watch recurring transactions
  Stream<List<RecurringTransaction>> watchRecurringTransactions() {
    return _recurringTransactionDao.watchRecurringTransactions();
  }

  // Get recurring transaction by ID
  Future<RecurringTransaction?> getRecurringTransactionById(String id) {
    return _recurringTransactionDao.getRecurringTransactionById(id);
  }

  // Update recurring transaction
  Future<bool> updateRecurringTransaction(
    RecurringTransactionsCompanion recurringTransaction,
  ) {
    return _recurringTransactionDao.updateRecurringTransaction(
      recurringTransaction,
    );
  }

  // Pause or resume recurring transaction
  Future<int> updateRecurringStatus(String id, bool isActive) {
    return _recurringTransactionDao.updateRecurringStatus(id, isActive);
  }

  // Delete recurring transaction
  Future<int> deleteRecurringTransaction(String id) {
    return _recurringTransactionDao.deleteRecurringTransaction(id);
  }
}
