import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/database_helper.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper dbHelper;

  CategoryRepositoryImpl(this.dbHelper);

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  @override
  Future<int> insertCategory(CategoryEntity category) async {
    final db = await dbHelper.database;
    final model = CategoryModel(
      name: category.name,
      icon: category.icon,
      color: category.color,
      type: category.type,
    );
    return await db.insert('categories', model.toMap());
  }

  @override
  Future<int> updateCategory(CategoryEntity category) async {
    final db = await dbHelper.database;
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      type: category.type,
    );
    return await db.update(
      'categories',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<int> deleteCategory(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
