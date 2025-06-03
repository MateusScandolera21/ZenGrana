// lib/src/shared/widgets/custom_scaffold.dart
import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? appBarActions;
  final PreferredSizeWidget? appBarBottom; // Adicionado para suportar TabBar
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const CustomScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.appBarActions,
    this.appBarBottom, // Novo parâmetro
    this.floatingActionButton,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: appBarActions,
        bottom: appBarBottom, // Usando o novo parâmetro
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
