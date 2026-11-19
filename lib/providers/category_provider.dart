import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

import '../data/local/database/app_database.dart';
import '../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryProvider(this._repository) {
    loadCategories();
  }

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repository.getAllCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory({required String name, required String type}) async {
    final category = CategoriesCompanion.insert(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      type: type,
      createdAt: DateTime.now(),
    );

    await _repository.addCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    await loadCategories();
  }
}
