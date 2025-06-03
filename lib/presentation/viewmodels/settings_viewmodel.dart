// lib/presentation/viewmodels/settings_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/app_theme_mode.dart'; // Importa o enum que acabamos de criar

class SettingsViewModel extends ChangeNotifier {
  late Box<AppThemeMode> _settingsBox;
  AppThemeMode _currentThemeMode = AppThemeMode.system; // Valor inicial padrão

  AppThemeMode get currentThemeMode => _currentThemeMode;

  SettingsViewModel() {
    _init();
  }

  Future<void> _init() async {
    try {
      _settingsBox = await Hive.openBox<AppThemeMode>('settings');
      // Tenta carregar a preferência salva, senão usa o padrão (system)
      _currentThemeMode =
          _settingsBox.get('themeMode', defaultValue: AppThemeMode.system)!;
      print('DEBUG: SettingsViewModel - Tema carregado: $_currentThemeMode');
    } catch (e) {
      print('ERRO: SettingsViewModel - Falha ao carregar tema: $e');
      _currentThemeMode =
          AppThemeMode.system; // Garante um valor padrão em caso de erro
    }
    notifyListeners(); // Notifica a UI sobre o tema inicial
  }

  /// Define o novo modo de tema e salva a preferência.
  Future<void> setThemeMode(AppThemeMode newMode) async {
    if (_currentThemeMode == newMode)
      return; // Evita atualizações desnecessárias

    _currentThemeMode = newMode;
    await _settingsBox.put('themeMode', newMode); // Salva no Hive
    print('DEBUG: SettingsViewModel - Tema alterado para: $_currentThemeMode');
    notifyListeners(); // Notifica a UI para reconstruir
  }

  /// Converte o AppThemeMode para o ThemeMode do Flutter.
  ThemeMode get flutterThemeMode {
    switch (_currentThemeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
