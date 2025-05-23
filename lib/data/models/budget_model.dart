import 'package:controle_financeiro/data/models/category_model.dart';
import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  CategoryModel? category;

  BudgetModel({
    required this.id,
    required this.name,
    required this.amount,
    this.category,
  });
}
