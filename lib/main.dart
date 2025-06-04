// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart'; // Mantém para MultiProvider no MyApp

// Importações dos seus modelos
import 'data/models/category_model.dart';
import 'data/models/transaction_model.dart';
import 'data/models/budget_model.dart';
import 'data/models/goals_model.dart';
import 'data/models/app_theme_mode.dart';
import 'core/models/recent_activity.dart'; // Mantenha o modelo se for registrar o adapter aqui, mas o serviço já faz isso.

// Importações dos seus serviços e viewmodels
import 'core/services/recent_activity_service.dart';
import 'features/transaction/presentation/viewmodels/transaction_viewmodel.dart';

import 'app.dart'; // Ou 'package:your_app_name/app.dart'; se 'app.dart' está em 'lib/'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // --- REGISTRO DOS ADAPTERS ---
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(GoalsModelAdapter());
  Hive.registerAdapter(AppThemeModeAdapter());
  Hive.registerAdapter(RecentActivityAdapter());
  // --- FIM DO REGISTRO DOS ADAPTERS ---

  // --- ABERTURA DAS CAIXAS DO HIVE ---
  // Use o serviço para abrir a caixa de atividades recentes
  await RecentActivityService.init(); // <--- CHAME ISSO AQUI!

  // Abra as outras caixas diretamente
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<BudgetModel>('budgets');
  await Hive.openBox<GoalsModel>('goals');
  await Hive.openBox<RecentActivity>('recentActivities');

  runApp(
    // Adicione 'const' se MyApp for um widget constante
    MyApp(), // Adicionado 'const'
  );
}
