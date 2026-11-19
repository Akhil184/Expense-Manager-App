
import 'package:drift/drift.dart';

import '../database/app_database.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<int> addCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  Future<List<Category>> getAllCategories() {
    return (select(categories)
      ..orderBy([
            (table) => OrderingTerm.asc(table.name),
      ]))
        .get();
  }

  Stream<List<Category>> watchCategories() {
    return select(categories).watch();
  }

  Future<int> deleteCategory(String id) {
    return (delete(categories)
      ..where((table) => table.id.equals(id)))
        .go();
  }
}
