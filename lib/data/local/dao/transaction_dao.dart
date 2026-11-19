
import 'package:drift/drift.dart';

import '../database/app_database.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  // Insert a transaction.
  Future<int> insertTransaction(
      TransactionsCompanion transaction,
      ) {
    return into(transactions).insert(transaction);
  }

  // Fetch all active transactions.
  Future<List<Transaction>> getAllTransactions() {
    return (select(transactions)
      ..where((table) => table.deletedAt.isNull())
      ..orderBy([
            (table) => OrderingTerm.desc(table.transactionDate),
      ]))
        .get();
  }

  // Watch transactions for real-time UI updates.
  Stream<List<Transaction>> watchTransactions() {
    return (select(transactions)
      ..where((table) => table.deletedAt.isNull())
      ..orderBy([
            (table) => OrderingTerm.desc(table.transactionDate),
      ]))
        .watch();
  }

  // Fetch one transaction by ID.
  Future<Transaction?> getTransactionById(String id) {
    return (select(transactions)
      ..where((table) =>
      table.id.equals(id) & table.deletedAt.isNull()))
        .getSingleOrNull();
  }

  // Update a transaction.
  Future<int> updateTransaction(
      TransactionsCompanion transaction,
      ) {
    if (!transaction.id.present) {
      throw ArgumentError('Transaction ID is required.');
    }

    return (update(transactions)
      ..where((table) => table.id.equals(transaction.id.value)))
        .write(transaction);
  }

  // Soft-delete a transaction.
  Future<int> deleteTransaction(String id) {
    final now = DateTime.now();

    return (update(transactions)
      ..where((table) =>
      table.id.equals(id) & table.deletedAt.isNull()))
        .write(
      TransactionsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
    );
  }

  // Pagination for large transaction lists.
  Future<List<Transaction>> getTransactionsPaginated({
    required int limit,
    required int offset,
  }) {
    if (limit <= 0 || offset < 0) {
      throw ArgumentError('Invalid pagination values.');
    }

    return (select(transactions)
      ..where((table) => table.deletedAt.isNull())
      ..orderBy([
            (table) => OrderingTerm.desc(table.transactionDate),
      ])
      ..limit(limit, offset: offset))
        .get();
  }
}
