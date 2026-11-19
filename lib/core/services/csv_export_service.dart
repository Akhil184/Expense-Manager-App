import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/local/database/app_database.dart';

class CsvExportService {
  Future<void> exportTransactions(List<Transaction> transactions) async {
    final rows = <String>['Title,Amount,Type,Category,Note,Date'];

    for (final transaction in transactions) {
      final row = [
        _escape(transaction.title),
        transaction.amount.toString(),
        _escape(transaction.type),
        _escape(transaction.category),
        _escape(transaction.note ?? ''),
        transaction.transactionDate.toIso8601String(),
      ];

      rows.add(row.join(','));
    }

    final csvContent = rows.join('\n');

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/transactions.csv');

    await file.writeAsString(csvContent);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Expense Manager Transactions',
      ),
    );
  }

  String _escape(String value) {
    return '"${value.replaceAll('"', '""')}"';
  }
}
