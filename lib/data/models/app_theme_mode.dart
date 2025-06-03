// lib/data/models/app_theme_mode.dart
import 'package:hive/hive.dart';

part 'app_theme_mode.g.dart';

@HiveType(typeId: 6) // Escolha um typeId único e não usado (ex: 6)
enum AppThemeMode {
  @HiveField(0)
  system, // Segue o tema do sistema do celular
  @HiveField(1)
  light, // Tema claro forçado
  @HiveField(2)
  dark, // Tema escuro forçado
}
