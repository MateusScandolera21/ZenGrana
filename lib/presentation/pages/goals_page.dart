import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../data/models/goals_model.dart';
import '../viewmodels/transaction_viewmodel.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  double? _amount;

  @override
  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final box = Hive.box<GoalsModel>('goals');

      final goal = GoalsModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _name!,
        amount: _amount!,
      );

      box.add(goal);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Meta salva com sucesso!')));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Meta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descrição da Meta',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe a descrição'
                            : null,
                onSaved: (value) => _name = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Valor da Meta (R\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor da meta';
                  }
                  final parsedValue = double.tryParse(
                    value.replaceAll(',', '.'),
                  );
                  if (parsedValue == null || parsedValue <= 0) {
                    return 'Valor inválido. Use números e seja maior que zero';
                  }
                  return null;
                },
                onSaved:
                    (value) =>
                        _amount = double.tryParse(value!.replaceAll(',', '.')),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 300.0,
                child: ElevatedButton.icon(
                  onPressed: _saveGoal,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Meta'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
