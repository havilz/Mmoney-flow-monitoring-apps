import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/category_provider.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        itemCount: categoryProvider.categories.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final category = categoryProvider.categories[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(int.parse(category.color)).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_rounded,
                color: Color(int.parse(category.color)),
              ),
            ),
            title: Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              category.type,
              style: TextStyle(
                color: isDarkMode ? Colors.white60 : Colors.black54,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () =>
                  _showAddCategoryDialog(context, category: category),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        label: const Text('Add Category'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddCategoryDialog(
    BuildContext context, {
    CategoryEntity? category,
  }) {
    final nameController = TextEditingController(text: category?.name);
    String type = category?.type ?? 'EXPENSE';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEdit = category != null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final labelStyle = TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.bold,
            );

            return AlertDialog(
              title: Text(
                isEdit ? 'Edit Category' : 'New Category',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: labelStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    isExpanded: true,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: labelStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey[50],
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'EXPENSE',
                        child: Text('Expense'),
                      ),
                      DropdownMenuItem(value: 'INCOME', child: Text('Income')),
                    ],
                    onChanged: (val) => setState(() => type = val!),
                  ),
                ],
              ),
              actions: [
                if (isEdit)
                  TextButton(
                    onPressed: () {
                      _showDeleteConfirmation(context, category);
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final updatedCategory = CategoryEntity(
                        id: category?.id,
                        name: nameController.text,
                        icon: 'category',
                        color: type == 'EXPENSE' ? '0xFFEF4444' : '0xFF10B981',
                        type: type,
                      );

                      if (isEdit) {
                        context.read<CategoryProvider>().updateCategory(
                          updatedCategory,
                        );
                      } else {
                        context.read<CategoryProvider>().addCategory(
                          updatedCategory,
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isEdit ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, CategoryEntity category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? Transactions using this category might be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(category.id!);
              Navigator.pop(context); // Close confirm
              Navigator.pop(context); // Close edit dialog
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
