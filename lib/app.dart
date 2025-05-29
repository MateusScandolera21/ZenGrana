import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/initial_page.dart';
import 'presentation/viewmodels/transaction_viewmodel.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Zen Grana',
        theme: ThemeData(primarySwatch: Colors.green),
        home: InitialPage(),
      ),
    );
  }
}
