import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/category_provider.dart';
import 'add_category_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  Future<void> _deleteCategory(
    BuildContext context,
    String id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<CategoryProvider>().deleteCategory(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.categories.isEmpty) {
            return const Center(child: Text('No categories added yet'));
          }

          return ListView.builder(
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    category.type == 'income'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                  ),
                ),
                title: Text(category.name),
                subtitle: Text(category.type.toUpperCase()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () =>
                      _deleteCategory(context, category.id, category.name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
