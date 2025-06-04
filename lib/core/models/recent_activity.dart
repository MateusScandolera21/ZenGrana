// lib/src/core/models/recent_activity.dart
import 'package:hive/hive.dart';

part 'recent_activity.g.dart'; // Gerado pelo Hive

@HiveType(typeId: 7) // Escolha um typeId único para esta classe
class RecentActivity extends HiveObject {
  @HiveField(0)
  final String id; // ID único da atividade (ex: UUID)

  @HiveField(1)
  final String type; // Tipo de atividade (e.g., 'Meta', 'Transação', 'Categoria', 'Orçamento')

  @HiveField(2)
  final String description; // Descrição breve (e.g., 'Meta "Viagem" adicionada', 'Transação "Compras"')

  @HiveField(3)
  final DateTime timestamp; // Quando a atividade ocorreu

  RecentActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });
}
