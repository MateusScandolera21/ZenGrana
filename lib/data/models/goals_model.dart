// lib/data/models/goals_model.dart

import 'package:hive/hive.dart';

part 'goals_model.g.dart'; // Certifique-se de ter rodado 'flutter pub run build_runner build'

@HiveType(typeId: 3) // Use um typeId único para GoalsModel
class GoalsModel extends HiveObject {
  // Se você quer usar .save() e .delete() diretamente
  @HiveField(0)
  late String id; // <--- MUDANÇA AQUI: DE int PARA String

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double targetAmount;

  @HiveField(3)
  late double currentAmount;

  @HiveField(4)
  late DateTime dueDate;

  @HiveField(5)
  late bool isCompleted;

  @HiveField(6)
  late DateTime? completionDate;

  GoalsModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.dueDate,
    this.isCompleted = false,
    this.completionDate,
  });

  // Remova o construtor .fromMap se você não precisar mais dele,
  // já que agora você vai trabalhar com GoalsModel diretamente.
  // Se ainda precisar dele por algum motivo, ajuste-o para aceitar Map<String, dynamic>
  // e fazer a conversão de tipos corretamente.
  // factory GoalsModel.fromMap(Map<String, dynamic> map) {
  //   return GoalsModel(
  //     id: map['id'] as String, // Ajuste para String
  //     name: map['name'] as String,
  //     targetAmount: map['targetAmount'] as double,
  //     currentAmount: map['currentAmount'] as double,
  //     dueDate: DateTime.parse(map['dueDate'] as String),
  //     isCompleted: map['isCompleted'] as bool,
  //     completionDate: map['completionDate'] != null
  //         ? DateTime.parse(map['completionDate'] as String)
  //         : null,
  //   );
  // }
}
