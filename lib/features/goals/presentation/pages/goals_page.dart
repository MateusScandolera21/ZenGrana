// lib/src/modules/goals/presenter/pages/goals_page.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Mude para hive_flutter para ter acesso a Box e HiveObject
import 'package:intl/intl.dart'; // Adicione para formatação de data
import 'package:uuid/uuid.dart'; // Importe para gerar IDs únicos

import '../../../../data/models/goals_model.dart';

class GoalsPage extends StatefulWidget {
  // O parâmetro 'goal' agora é opcional e do tipo GoalsModel
  final GoalsModel? goal;

  const GoalsPage({Key? key, this.goal}) : super(key: key);

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late TextEditingController _dueDateController;

  GoalsModel? _currentGoal; // A meta sendo editada/criada
  DateTime? _selectedDueDate; // Data selecionada no date picker

  // Gerador de UUID para novos IDs
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      // Modo de edição: use a meta passada diretamente
      _currentGoal = widget.goal;
      _nameController = TextEditingController(text: _currentGoal!.name);
      _targetAmountController = TextEditingController(
        text: _currentGoal!.targetAmount.toStringAsFixed(2),
      );
      _currentAmountController = TextEditingController(
        text: _currentGoal!.currentAmount.toStringAsFixed(2),
      );
      _selectedDueDate = _currentGoal!.dueDate;
      _dueDateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_selectedDueDate!),
      );
    } else {
      // Para uma nova meta: inicializa vazio ou com valores padrão
      _nameController = TextEditingController();
      _targetAmountController = TextEditingController();
      _currentAmountController = TextEditingController(
        text: '0.00',
      ); // Nova meta começa com 0.00
      _dueDateController = TextEditingController();
      _selectedDueDate = null; // Nenhuma data selecionada inicialmente
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365 * 5),
      ), // Permite datas passadas se necessário, ou ajuste
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Obtenha a box de metas (ela deve estar aberta no main.dart)
      final box = Hive.box<GoalsModel>('goals'); // Use o nome da box 'goals'

      // Prepare os valores do formulário
      final String name = _nameController.text;
      final double targetAmount = double.parse(
        _targetAmountController.text.replaceAll(',', '.'),
      );
      final double currentAmount = double.parse(
        _currentAmountController.text.replaceAll(',', '.'),
      );
      final DateTime dueDate =
          _selectedDueDate!; // O validador já garante que não é nulo

      GoalsModel goalToReturn;

      if (_currentGoal != null) {
        // MODO DE EDIÇÃO
        _currentGoal!.name = name;
        _currentGoal!.targetAmount = targetAmount;
        _currentGoal!.currentAmount = currentAmount;
        _currentGoal!.dueDate = dueDate;
        // isCompleted e completionDate são mantidos do objeto existente ou atualizados na GoalsListPage

        // Salva as alterações na box (se for um HiveObject, save() funciona)
        // Se não for um HiveObject, ou se você usa o ID como chave, use put()
        await box.put(
          _currentGoal!.id,
          _currentGoal!,
        ); // Assumindo que 'id' é a chave no Hive
        goalToReturn = _currentGoal!;
      } else {
        // MODO DE CADASTRO
        goalToReturn = GoalsModel(
          id: _uuid.v4(), // Gera um ID único com UUID
          name: name,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          dueDate: dueDate,
          isCompleted: false, // Nova meta não está completa por padrão
          completionDate: null,
        );
        // Adiciona a nova meta à box (put com o ID como chave)
        await box.put(
          goalToReturn.id,
          goalToReturn,
        ); // Se usar add(), Hive atribui um índice inteiro
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.goal != null
                ? 'Meta atualizada com sucesso!'
                : 'Meta salva com sucesso!',
          ),
        ),
      );

      // RETORNA A META SALVA/EDITADA PARA A TELA ANTERIOR (GoalsListPage)
      Navigator.pop(context, goalToReturn); // Retorna o objeto GoalsModel
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal != null ? 'Editar Meta' : 'Nova Meta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Descrição da Meta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe a descrição'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Valor Total da Meta (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentAmountController,
                decoration: const InputDecoration(
                  labelText: 'Valor Atual Economizado (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wallet),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor atual';
                  }
                  final parsedValue = double.tryParse(
                    value.replaceAll(',', '.'),
                  );
                  if (parsedValue == null || parsedValue < 0) {
                    return 'Valor inválido. Use números e seja zero ou maior';
                  }
                  final target = double.tryParse(
                    _targetAmountController.text.replaceAll(',', '.'),
                  );
                  if (target != null && parsedValue > target) {
                    return 'O valor atual não pode ser maior que o valor da meta.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDueDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dueDateController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Vencimento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a data de vencimento';
                      }
                      if (_selectedDueDate == null) {
                        return 'Data inválida';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveGoal,
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.goal != null ? 'Atualizar Meta' : 'Salvar Meta',
                  ),
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
