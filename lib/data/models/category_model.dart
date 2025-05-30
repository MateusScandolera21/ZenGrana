import 'package:flutter/material.dart'; // Importe para usar IconData, se quiser mapear diretamente
import 'package:hive/hive.dart';

part 'category_model.g.dart';

// Certifique-se que o TypeId seja único e não usado por outros modelos
@HiveType(typeId: 4) // Exemplo de TypeId. Verifique se não colide.
class CategoryModel extends HiveObject {
  @HiveField(0)
  final int id; // Usado para identificar a categoria (por exemplo, ao filtrar)

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCodePoint; // <-- Adicione este campo para o ícone
  // Se quiser cor por categoria
  @HiveField(3)
  final int iconColorValue; // <-- Adicione este campo para a cor (valor int do Color)

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.iconColorValue, // Adicione no construtor
  });

  // Getter para converter iconCodePoint e iconColorValue em IconData e Color
  IconData get iconData => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get iconColor => Color(iconColorValue); // Convertendo int para Color

  // Métodos de cópia e comparação (opcional, mas bom para imutabilidade e testes)
  CategoryModel copyWith({
    int? id,
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
