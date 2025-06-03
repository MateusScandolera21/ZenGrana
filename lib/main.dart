// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart'; // Mantém para MultiProvider no MyApp, se aplicável
import 'data/models/category_model.dart';
import 'data/models/transaction_model.dart'; // Contém TransactionModel e TransactionType
import 'presentation/viewmodels/transaction_viewmodel.dart'; // Se você estiver usando Provider
import 'data/models/budget_model.dart';
import 'data/models/goals_model.dart';
import 'data/models/app_theme_mode.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // --- REGISTRO DOS ADAPTERS ---
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(
    TransactionTypeAdapter(),
  ); // <--- ADICIONE ESTA LINHA OBRIGATÓRIA!
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(GoalsModelAdapter());
  Hive.registerAdapter(AppThemeModeAdapter());
  // --- FIM DO REGISTRO DOS ADAPTERS ---

  // Abrir as caixas do Hive
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<BudgetModel>('budgets');
  await Hive.openBox<GoalsModel>('goals');

  runApp(
    MyApp(),
  ); // Seu MyApp, que deve conter os MultiProviders para os ViewModels
}
