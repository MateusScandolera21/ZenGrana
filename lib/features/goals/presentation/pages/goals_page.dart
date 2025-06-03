// lib/src/modules/goals/presenter/pages/goals_page.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart'; // Adicione para formatação de data
import '../../../../data/models/goals_model.dart';
// import '../viewmodels/transaction_viewmodel.dart'; // Provavelmente não é necessário aqui, a menos que você a use para algo específico

class GoalsPage extends StatefulWidget {
  // O parâmetro 'goal' agora é opcional e do tipo Map<String, dynamic>
  // Isso permite que a mesma tela seja usada para ADICIONAR (goal é nulo)
  // e EDITAR (goal é a meta a ser editada).
  final Map<String, dynamic>? goal;

  const GoalsPage({Key? key, this.goal}) : super(key: key);

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late TextEditingController _dueDateController; // Para a data de vencimento

  // Variáveis para armazenar os valores do formulário
  GoalsModel? _currentGoal; // A meta sendo editada/criada
  DateTime? _selectedDueDate; // Data selecionada no date picker

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados da meta se estiver em modo de edição
    if (widget.goal != null) {
      _currentGoal = GoalsModel.fromMap(
        widget.goal!,
      ); // Converte o Map de volta para GoalsModel
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
      // Para uma nova meta, inicializa vazio ou com valores padrão
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
    // Descarte os controladores para liberar recursos
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  // Função para abrir o seletor de data
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate:
          DateTime.now(), // Metas não podem ter data de vencimento no passado
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

      final box = Hive.box<GoalsModel>('goals');

      // Crie ou atualize a meta com os dados do formulário
      GoalsModel goalToSave;
      if (_currentGoal != null) {
        // Modo de edição
        _currentGoal!.name = _nameController.text;
        _currentGoal!.targetAmount = double.parse(
          _targetAmountController.text.replaceAll(',', '.'),
        );
        _currentGoal!.currentAmount = double.parse(
          _currentAmountController.text.replaceAll(',', '.'),
        );
        _currentGoal!.dueDate = _selectedDueDate!; // Usa a data selecionada
        goalToSave = _currentGoal!;
        await goalToSave.save(); // Salva as alterações no Hive
      } else {
        // Modo de cadastro
        goalToSave = GoalsModel(
          id: DateTime.now().millisecondsSinceEpoch, // Novo ID para nova meta
          name: _nameController.text,
          targetAmount: double.parse(
            _targetAmountController.text.replaceAll(',', '.'),
          ),
          currentAmount: double.parse(
            _currentAmountController.text.replaceAll(',', '.'),
          ),
          dueDate: _selectedDueDate!, // Usa a data selecionada
          isCompleted: false, // Nova meta não está completa
          completionDate: null,
        );
        await box.add(goalToSave); // Adiciona a nova meta ao Hive
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.goal != null
                ? 'Meta atualizada!'
                : 'Meta salva com sucesso!',
          ),
        ),
      );

      // RETORNA A META SALVA/EDITADA PARA A TELA ANTERIOR (GoalsListPage)
      Navigator.pop(context, goalToSave.toMap());
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
            // Use ListView para evitar overflow em teclados
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
                // onSaved não é mais necessário com controllers, pois o valor é lido diretamente
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
                // onSaved não é mais necessário com controllers
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
                    // Pode ser zero
                    return 'Valor inválido. Use números e seja zero ou maior';
                  }
                  // Opcional: verificar se currentAmount não é maior que targetAmount
                  final target = double.tryParse(
                    _targetAmountController.text.replaceAll(',', '.'),
                  );
                  if (target != null && parsedValue > target) {
                    return 'O valor atual não pode ser maior que o valor da meta.';
                  }
                  return null;
                },
                // onSaved não é mais necessário com controllers
              ),
              const SizedBox(height: 16),
              GestureDetector(
                // Permite tocar no campo de texto para abrir o seletor
                onTap: () => _selectDueDate(context),
                child: AbsorbPointer(
                  // Impede que o teclado apareça
                  child: TextFormField(
                    controller: _dueDateController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Vencimento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down,
                      ), // Indicador visual de dropdown
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a data de vencimento';
                      }
                      if (_selectedDueDate == null) {
                        return 'Data inválida'; // Caso o usuário digite e não selecione
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, // Preenche a largura disponível
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
