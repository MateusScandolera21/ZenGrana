// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'presentation/pages/initial_page.dart';
import 'features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'features/category/presentation/viewmodels/category_viewmodel.dart';
import 'features/budget/presentation/viewmodels/budget_viewmodel.dart';
import 'features/settings/presentation/viewmodels/settings_viewmodel.dart'; // <--- NOVO IMPORT DO SETTINGS VIEWMODEL

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => BudgetViewModel()),
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(),
        ), // <--- NOVO PROVIDER DO SETTINGS
        // ... outros ViewModels
      ],
      child: Consumer<SettingsViewModel>(
        // <--- Consumer para observar o SettingsViewModel
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Zen Grana',
            theme: ThemeData(
              primarySwatch: Colors.green,
              brightness: Brightness.light, // Tema claro padrão
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark, // Tema escuro padrão
              primarySwatch: Colors.green,
            ),
            themeMode:
                settingsViewModel
                    .flutterThemeMode, // <--- AQUI A MÁGICA ACONTECE!
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', ''), Locale('pt', 'BR')],
            home: InitialPage(),
          );
        },
      ),
    );
  }
}
