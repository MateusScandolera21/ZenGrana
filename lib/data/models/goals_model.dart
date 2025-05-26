import 'package:hive/hive.dart';

part 'goals_model.g.dart';

@HiveType(typeId: 3)
class GoalsModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  GoalsModel({required this.id, required this.name, required this.amount});
}
