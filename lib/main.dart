import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/transaction_model.dart';
import 'data/models/category_model.dart';
import 'data/models/budget_model.dart';
import 'app.dart'; // <- Seu MyApp real está aqui

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());

  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<BudgetModel>('budgets');

  runApp(MyApp()); // <- Esse agora é o MyApp com seu HomePage real
}
