import 'package:drift/drift.dart';

import '../database/app_database.dart';

part 'savings_goal_dao.g.dart';

@DriftAccessor(tables: [SavingsGoals])
class SavingsGoalDao extends DatabaseAccessor<AppDatabase>
    with _$SavingsGoalDaoMixin {
  SavingsGoalDao(super.db);

  // Add savings goal
  Future<int> addSavingsGoal(SavingsGoalsCompanion goal) {
    return into(savingsGoals).insert(goal);
  }

  // Get all savings goals
  Future<List<SavingsGoal>> getAllSavingsGoals() {
    return (select(
      savingsGoals,
    )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get();
  }

  // Watch savings goals
  Stream<List<SavingsGoal>> watchSavingsGoals() {
    return (select(
      savingsGoals,
    )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).watch();
  }

  // Get goal by ID
  Future<SavingsGoal?> getSavingsGoalById(String id) {
    return (select(
      savingsGoals,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  // Update savings goal
  Future<bool> updateSavingsGoal(SavingsGoalsCompanion goal) {
    return update(savingsGoals).replace(goal);
  }

  // Update saved amount
  Future<int> updateCurrentAmount(String id, double amount) {
    return (update(savingsGoals)..where((table) => table.id.equals(id))).write(
      SavingsGoalsCompanion(
        currentAmount: Value(amount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Delete savings goal
  Future<int> deleteSavingsGoal(String id) {
    return (delete(savingsGoals)..where((table) => table.id.equals(id))).go();
  }
}
