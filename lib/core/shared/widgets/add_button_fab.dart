import 'package:flutter/material.dart';

class AddButtonFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const AddButtonFAB({
    Key? key,
    required this.onPressed,
    this.tooltip = 'Adicionar',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: const Icon(Icons.add),
    );
  }
}
