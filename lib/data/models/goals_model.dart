// lib/src/modules/data/models/goals_model.dart
import 'package:hive/hive.dart';

part 'goals_model.g.dart'; // Importante para o Hive Generator

@HiveType(typeId: 3) // Escolha um typeId que ainda não esteja em uso
class GoalsModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount; // Renomeado de 'amount' para 'targetAmount'

  @HiveField(3)
  double currentAmount; // Novo campo para o progresso atual

  @HiveField(4)
  DateTime dueDate; // Novo campo para a data de vencimento

  @HiveField(5)
  bool isCompleted; // Novo campo para o status de conclusão

  @HiveField(6)
  DateTime? completionDate; // Novo campo para a data de conclusão (opcional)

  GoalsModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0, // Valor padrão para uma nova meta
    required this.dueDate,
    this.isCompleted = false, // Valor padrão
    this.completionDate,
  });

  // Método para converter para Map (útil para retornar para GoalsListPage)
  Map<String, dynamic> toMap() {
    return {
      'id':
          id.toString(), // Convertendo para String para manter consistência com o Map da GoalsListPage
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'dueDate': dueDate,
      'isCompleted': isCompleted,
      'completionDate': completionDate,
    };
  }

  // Método estático para criar GoalsModel a partir de um Map (útil para edição)
  static GoalsModel fromMap(Map<String, dynamic> map) {
    return GoalsModel(
      id:
          int.tryParse(map['id'] ?? '') ??
          DateTime.now().millisecondsSinceEpoch, // Garante que o ID seja int
      name: map['name'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'] ?? 0.0,
      dueDate:
          map['dueDate'] is String
              ? DateTime.parse(map['dueDate'])
              : map['dueDate'],
      isCompleted: map['isCompleted'] ?? false,
      completionDate:
          map['completionDate'] is String
              ? DateTime.parse(map['completionDate'])
              : map['completionDate'],
    );
  }
}
