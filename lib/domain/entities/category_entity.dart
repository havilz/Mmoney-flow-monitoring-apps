class CategoryEntity {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final String type; // INCOME, EXPENSE, or BOTH

  CategoryEntity({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}
