// lib/data/models/transaction_model.dart
import 'package:hive/hive.dart';
// import 'category_model.dart'; // Não precisa mais importar CategoryModel diretamente aqui

part 'transaction_model.g.dart';

// Definindo o enum TransactionType (com TypeId próprio e Fields)
@HiveType(
  typeId: 0,
) // IMPORTANT: Use um TypeId diferente de outros modelos e enums!
enum TransactionType {
  @HiveField(0)
  income, // Para entradas
  @HiveField(1)
  expense, // Para saídas
}

// Seu TransactionModel (com TypeId diferente do enum)
@HiveType(
  typeId: 1,
) // IMPORTANT: Use um TypeId diferente de outros modelos e enums!
class TransactionModel extends HiveObject {
  // Adicione 'extends HiveObject' se ainda não tiver
  @HiveField(0)
  final String id; // Recomendo String para ID único (UUID), ou int se você tiver uma lógica para isso

  @HiveField(1)
  final String description;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4) // Agora é o ID da categoria
  final int categoryId; // Armazena apenas o ID da categoria

  @HiveField(5)
  final TransactionType type; // Usando o enum TransactionType

  TransactionModel({
    required this.id, // Se usar String, gere um UUID (ex: uuid package) ou use DateTime.now().millisecondsSinceEpoch.toString()
    required this.description,
    required this.amount,
    required this.date,
    required this.categoryId, // Recebe o ID da categoria
    required this.type,
  });

  // (Opcional, mas útil para edições futuras e manter imutabilidade)
  TransactionModel copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    int? categoryId,
    TransactionType? type,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
    );
  }
}
