import 'package:drift/drift.dart';

import '../database/app_database.dart';

part 'recurring_transaction_dao.g.dart';

@DriftAccessor(tables: [RecurringTransactions])
class RecurringTransactionDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringTransactionDaoMixin {
  RecurringTransactionDao(super.db);

  // Add recurring transaction
  Future<int> addRecurringTransaction(
    RecurringTransactionsCompanion recurringTransaction,
  ) {
    return into(recurringTransactions).insert(recurringTransaction);
  }

  // Get all recurring transactions
  Future<List<RecurringTransaction>> getAllRecurringTransactions() {
    return (select(
      recurringTransactions,
    )..orderBy([(table) => OrderingTerm.asc(table.nextDueDate)])).get();
  }

  // Watch recurring transactions
  Stream<List<RecurringTransaction>> watchRecurringTransactions() {
    return (select(
      recurringTransactions,
    )..orderBy([(table) => OrderingTerm.asc(table.nextDueDate)])).watch();
  }

  // Get recurring transaction by ID
  Future<RecurringTransaction?> getRecurringTransactionById(String id) {
    return (select(
      recurringTransactions,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  // Update recurring transaction
  Future<bool> updateRecurringTransaction(
    RecurringTransactionsCompanion recurringTransaction,
  ) {
    return update(recurringTransactions).replace(recurringTransaction);
  }

  // Pause or resume recurring transaction
  Future<int> updateRecurringStatus(String id, bool isActive) {
    return (update(
      recurringTransactions,
    )..where((table) => table.id.equals(id))).write(
      RecurringTransactionsCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Delete recurring transaction
  Future<int> deleteRecurringTransaction(String id) {
    return (delete(
      recurringTransactions,
    )..where((table) => table.id.equals(id))).go();
  }
}
