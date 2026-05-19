import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.type,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'icon': icon, 'color': color, 'type': type};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      type: map['type'],
    );
  }
}
