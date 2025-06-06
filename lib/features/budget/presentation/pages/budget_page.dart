// lib/presentation/pages/budget_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Para gerar IDs únicos
import '../../../../data/models/budget_model.dart';
import '../../../../data/models/category_model.dart';
import '../../../category/presentation/viewmodels/category_viewmodel.dart';
import '../viewmodels/budget_viewmodel.dart';

class BudgetPage extends StatefulWidget {
  final BudgetModel? budget; // Adicionado para permitir edição de orçamentos

  const BudgetPage({Key? key, this.budget}) : super(key: key);

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final Uuid _uuid = Uuid(); // Para gerar IDs únicos

  late TextEditingController _nameController;
  late TextEditingController _amountController;
  CategoryModel? _selectedCategory; // Pode ser nulo se o orçamento for "geral"
  late DateTime
  _startDate; // Definido como late para inicialização no initState
  late DateTime _endDate; // Definido como late para inicialização no initState

  List<CategoryModel> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();

    // Inicialização padrão para novas orçamentos
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 30));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories(); // Carrega as categorias

      // Preencher campos se estiver editando um orçamento existente
      if (widget.budget != null) {
        _nameController.text = widget.budget!.name;
        _amountController.text = widget.budget!.amount.toStringAsFixed(
          2,
        ); // Formata para 2 casas decimais
        _startDate = widget.budget!.startDate;
        _endDate = widget.budget!.endDate;

        // Tentar encontrar a categoria selecionada
        final categoryViewModel = Provider.of<CategoryViewModel>(
          context,
          listen: false,
        );
        _selectedCategory = categoryViewModel.getCategoryById(
          widget.budget!.categoryId,
        );
        // Se a categoryId for vazia ou não encontrada, _selectedCategory permanecerá nulo
        // (o que é o caso para orçamentos "gerais" ou se a categoria foi deletada)
      } else {
        // Para novos orçamentos, pré-seleciona a primeira categoria se houver
        // Isso só ocorre se _availableCategories já estiver carregado.
        // É melhor fazer essa pré-seleção após _loadCategories garantir que a lista não esteja vazia.
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _loadCategories() {
    final categoryViewModel = Provider.of<CategoryViewModel>(
      context,
      listen: false,
    );
    setState(() {
      _availableCategories = categoryViewModel.categories;
      // Para novos orçamentos: se não há categoria selecionada e temos categorias disponíveis,
      // e não estamos editando, pré-selecione a primeira.
      if (widget.budget == null &&
          _selectedCategory == null &&
          _availableCategories.isNotEmpty) {
        _selectedCategory = _availableCategories.first;
      }
    });
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = DateTime(2000); // Allow selection far back for start date
    final lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ajuste a data de fim se a data de início se tornar posterior
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
          // Ajuste a data de início se a data de fim se tornar anterior
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 30));
          }
        }
      });
    }
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final budgetViewModel = Provider.of<BudgetViewModel>(
        context,
        listen: false,
      );

      final String budgetId = widget.budget?.id ?? _uuid.v4();
      final String selectedCategoryId = _selectedCategory?.id ?? '';

      final budget = BudgetModel(
        id: budgetId,
        name: _nameController.text,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        categoryId: selectedCategoryId,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (widget.budget == null) {
        budgetViewModel.addBudget(budget);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orçamento salvo com sucesso!')),
        );
      } else {
        budgetViewModel.updateBudget(
          budget,
        ); // O ViewModel atualizará o item existente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orçamento atualizado com sucesso!')),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.budget == null ? 'Novo Orçamento' : 'Editar Orçamento',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição do Orçamento',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Informe a descrição'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Valor do Orçamento (R\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o valor do orçamento';
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
                ListTile(
                  title: const Text('Data de Início'),
                  subtitle: Text(
                    '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, isStartDate: true),
                ),
                ListTile(
                  title: const Text('Data de Fim'),
                  subtitle: Text(
                    '${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, isStartDate: false),
                ),
                const SizedBox(height: 16),
                _availableCategories.isEmpty
                    ? const Text(
                      'Nenhuma categoria cadastrada. Por favor, cadastre uma categoria para criar orçamentos.',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    )
                    : DropdownButtonFormField<CategoryModel?>(
                      decoration: const InputDecoration(
                        labelText: 'Categoria (Opcional)',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      hint: const Text('Selecione uma categoria'),
                      items: [
                        const DropdownMenuItem<CategoryModel?>(
                          value: null,
                          child: Text('Todas as categorias'),
                        ),
                        ..._availableCategories
                            .map(
                              (cat) => DropdownMenuItem<CategoryModel>(
                                value: cat,
                                child: Row(
                                  children: [
                                    Icon(cat.iconData, color: cat.iconColor),
                                    const SizedBox(width: 8),
                                    Text(cat.name),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveBudget,
                    icon: const Icon(Icons.save),
                    label: Text(
                      widget.budget == null
                          ? 'Salvar Orçamento'
                          : 'Atualizar Orçamento',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
