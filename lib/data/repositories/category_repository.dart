
import '../local/database/app_database.dart';
import '../local/dao/category_dao.dart';

class CategoryRepository {
  final CategoryDao _categoryDao;

  CategoryRepository(this._categoryDao);

  Future<int> addCategory(CategoriesCompanion category) {
    return _categoryDao.addCategory(category);
  }

  Future<List<Category>> getAllCategories() {
    return _categoryDao.getAllCategories();
  }

  Stream<List<Category>> watchCategories() {
    return _categoryDao.watchCategories();
  }

  Future<int> deleteCategory(String id) {
    return _categoryDao.deleteCategory(id);
  }
}
