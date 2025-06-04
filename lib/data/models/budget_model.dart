// lib/data/models/budget_model.dart
import 'package:hive/hive.dart';

part 'budget_model.g.dart'; // O arquivo gerado pelo build_runner

@HiveType(
  typeId: 5,
) // Use um typeId único. Já usamos 1, 2, 4, então 5 é seguro.
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final String categoryId; // ID da categoria associada (String)
  @HiveField(4)
  final DateTime startDate;
  @HiveField(5)
  final DateTime endDate;

  BudgetModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.startDate,
    required this.endDate,
  });
}
