import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryRepository repository;

  List<CategoryEntity> _categories = [];
  bool _isLoading = false;

  CategoryProvider(this.repository);

  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await repository.getAllCategories();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(CategoryEntity category) async {
    await repository.insertCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(CategoryEntity category) async {
    await repository.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await repository.deleteCategory(id);
    await loadCategories();
  }
}
