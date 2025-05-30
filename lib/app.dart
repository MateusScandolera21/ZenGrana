// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/pages/initial_page.dart';
import 'presentation/viewmodels/transaction_viewmodel.dart';
import 'presentation/viewmodels/category_viewmodel.dart'; // <-- NOVO IMPORT
// import 'presentation/viewmodels/settings_viewmodel.dart'; // <-- Importe quando criar

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Para controlar o tema globalmente, você precisaria de um SettingsViewModel.
    // Exemplo (descomente e adapte quando tiver o SettingsViewModel):
    // final settingsViewModel = Provider.of<SettingsViewModel>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
        ChangeNotifierProvider(
          create: (_) => CategoryViewModel(),
        ), // <-- NOVO PROVIDER
        // ChangeNotifierProvider(create: (_) => SettingsViewModel()), // <-- Adicione quando criar o SettingsViewModel
        // Adicione outros ViewModels que você criar aqui (BudgetViewModel, GoalsViewModel, etc.)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Zen Grana',
        theme: ThemeData(
          primarySwatch: Colors.green, // Seu tema principal
          // ... outras configurações de tema claro (brightness: Brightness.light)
        ),
        darkTheme: ThemeData(
          // Exemplo de tema escuro. Personalize as cores aqui.
          brightness: Brightness.dark,
          primarySwatch: Colors.green, // Pode ser outra cor para o tema escuro
          // ... outras configurações do tema escuro
        ),
        // themeMode: settingsViewModel.currentThemeMode, // Usaria o valor do SettingsViewModel
        themeMode:
            ThemeMode
                .system, // Por enquanto, usa o tema do sistema (ou você pode definir Light/Dark aqui)
        home: InitialPage(),
      ),
    );
  }
}
