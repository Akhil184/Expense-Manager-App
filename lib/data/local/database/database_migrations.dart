import 'package:drift/drift.dart';

import 'app_database.dart';

class DatabaseMigrations {
  static MigrationStrategy get strategy {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(
            migrator.database.allSchemaEntities
                .whereType<TableInfo>()
                .firstWhere((table) => table.actualTableName == 'budgets'),
          );
        }
      },
    );
  }
}
