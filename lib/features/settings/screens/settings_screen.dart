import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/csv_export_service.dart';
import '../../../providers/transaction_provider.dart';
import '../widgets/theme_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportCSV(BuildContext context) async {
    final provider = context.read<TransactionProvider>();

    try {
      await provider.loadTransactions();

      if (!context.mounted) return;

      await CsvExportService().exportTransactions(provider.transactions);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ThemeSettings(),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export Transactions'),
            subtitle: const Text('Export all transactions as CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _exportCSV(context),
          ),
        ],
      ),
    );
  }
}
