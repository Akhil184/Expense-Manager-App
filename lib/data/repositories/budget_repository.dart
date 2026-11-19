
import '../local/database/app_database.dart';
import '../local/dao/budget_dao.dart';

class BudgetRepository {
  final BudgetDao _budgetDao;

  BudgetRepository(this._budgetDao);

  // Add budget
  Future<int> addBudget(BudgetsCompanion budget) {
    return _budgetDao.addBudget(budget);
  }

  // Get all budgets
  Future<List<Budget>> getAllBudgets() {
    return _budgetDao.getAllBudgets();
  }

  // Watch budgets
  Stream<List<Budget>> watchBudgets() {
    return _budgetDao.watchBudgets();
  }

  // Get budget by category, month and year
  Future<Budget?> getBudgetByCategory(
      String category,
      int month,
      int year,
      ) {
    return _budgetDao.getBudgetByCategory(
      category,
      month,
      year,
    );
  }

  // Update budget
  Future<int> updateBudget(BudgetsCompanion budget) {
    return _budgetDao.updateBudget(budget);
  }

  // Delete budget
  Future<int> deleteBudget(String id) {
    return _budgetDao.deleteBudget(id);
  }
}
