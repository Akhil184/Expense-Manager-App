import '../local/database/app_database.dart';
import '../local/dao/savings_goal_dao.dart';

class SavingsGoalRepository {
  final SavingsGoalDao _savingsGoalDao;

  SavingsGoalRepository(this._savingsGoalDao);

  // Add savings goal
  Future<int> addSavingsGoal(SavingsGoalsCompanion goal) {
    return _savingsGoalDao.addSavingsGoal(goal);
  }

  // Get all savings goals
  Future<List<SavingsGoal>> getAllSavingsGoals() {
    return _savingsGoalDao.getAllSavingsGoals();
  }

  // Watch savings goals
  Stream<List<SavingsGoal>> watchSavingsGoals() {
    return _savingsGoalDao.watchSavingsGoals();
  }

  // Get goal by ID
  Future<SavingsGoal?> getSavingsGoalById(String id) {
    return _savingsGoalDao.getSavingsGoalById(id);
  }

  // Update savings goal
  Future<bool> updateSavingsGoal(SavingsGoalsCompanion goal) {
    return _savingsGoalDao.updateSavingsGoal(goal);
  }

  // Update saved amount
  Future<int> updateCurrentAmount(String id, double amount) {
    return _savingsGoalDao.updateCurrentAmount(id, amount);
  }

  // Delete savings goal
  Future<int> deleteSavingsGoal(String id) {
    return _savingsGoalDao.deleteSavingsGoal(id);
  }
}
