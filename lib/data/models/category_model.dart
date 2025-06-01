// lib/data/models/category_model.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 4)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int iconCodePoint;
  @HiveField(3)
  final int iconColorValue;

  IconData get iconData => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get iconColor => Color(iconColorValue);

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.iconColorValue,
  });

  // Adiciona o método copyWith
  CategoryModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? iconColorValue,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconColorValue: iconColorValue ?? this.iconColorValue,
    );
  }
}
