import 'package:drift/drift.dart';

import '../dao/category_dao.dart';
import '../dao/budget_dao.dart';
import '../dao/transaction_dao.dart';
import '../dao/recurring_transaction_dao.dart';
import 'database_helper.dart';

part 'app_database.g.dart';

// Transactions Table
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Budgets Table
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Categories Table
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Recurring Transactions Table
class RecurringTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();

  TextColumn get frequency => text()();

  DateTimeColumn get nextDueDate => dateTime()();
  DateTimeColumn get lastGeneratedDate => dateTime().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Database
@DriftDatabase(
  tables: [Transactions, Budgets, Categories, RecurringTransactions],
  daos: [TransactionDao, BudgetDao, CategoryDao,RecurringTransactionDao,],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(DatabaseHelper.openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(budgets);
      }

      if (from < 3) {
        await m.createTable(categories);
      }

      if (from < 4) {
        await m.createTable(recurringTransactions);
      }
    },
  );
}
