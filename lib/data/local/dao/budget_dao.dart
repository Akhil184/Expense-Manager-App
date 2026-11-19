import 'package:drift/drift.dart';

import '../database/app_database.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  // Add budget
  Future<int> addBudget(BudgetsCompanion budget) {
    return into(budgets).insert(budget);
  }

  // Get all budgets
  Future<List<Budget>> getAllBudgets() {
    return (select(budgets)..orderBy([
          (table) => OrderingTerm.desc(table.year),
          (table) => OrderingTerm.desc(table.month),
        ]))
        .get();
  }

  // Watch budgets
  Stream<List<Budget>> watchBudgets() {
    return select(budgets).watch();
  }

  // Get budget by category, month and year
  Future<Budget?> getBudgetByCategory(String category, int month, int year) {
    return (select(budgets)..where(
          (table) =>
              table.category.equals(category) &
              table.month.equals(month) &
              table.year.equals(year),
        ))
        .getSingleOrNull();
  }

  // Update budget
  Future<int> updateBudget(BudgetsCompanion budget) {
    return (update(
      budgets,
    )..where((table) => table.id.equals(budget.id.value))).write(budget);
  }

  // Delete budget
  Future<int> deleteBudget(String id) {
    return (delete(budgets)..where((table) => table.id.equals(id))).go();
  }
}
