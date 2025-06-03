// lib/presentation/pages/budget_page.dart
import 'package:flutter/material.dart';
// import 'package:hive/hive.dart'; // Remova este import, pois o ViewModel lidará com o Hive
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Para gerar IDs únicos
import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
// import '../viewmodels/transaction_viewmodel.dart'; // Este import não é necessário aqui
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/budget_viewmodel.dart'; // <--- Nova Importação: BudgetViewModel

// import '../../utils/list_extensions.dart'; // <--- Mantenha se você realmente tem esse arquivo e usa firstWhereOrNull

class BudgetPage extends StatefulWidget {
  final BudgetModel? budget; // Adicionado para permitir edição de orçamentos

  // Construtor atualizado para permitir a edição
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
  DateTime _startDate = DateTime.now(); // Data de início do orçamento
  DateTime _endDate = DateTime.now().add(
    const Duration(days: 30),
  ); // Data de fim (ex: 30 dias depois)

  List<CategoryModel> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories(); // Carrega as categorias

      // Preencher campos se estiver editando um orçamento existente
      if (widget.budget != null) {
        _nameController.text = widget.budget!.name;
        _amountController.text = widget.budget!.amount.toString();
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
        // Se a categoriaId for vazia ou não encontrada, _selectedCategory permanecerá nulo
        // (o que é o caso para orçamentos "gerais" ou se a categoria foi deletada)
      } else {
        // Para novos orçamentos, pré-seleciona a primeira categoria se houver
        if (_availableCategories.isNotEmpty) {
          _selectedCategory = _availableCategories.first;
        }
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
      // Se não houver categoria selecionada e houver categorias disponíveis (e não estiver editando),
      // você pode pré-selecionar a primeira.
      if (_selectedCategory == null &&
          _availableCategories.isNotEmpty &&
          widget.budget == null) {
        _selectedCategory = _availableCategories.first;
      }
    });
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate =
        isStartDate
            ? DateTime(2000)
            : _startDate; // End date cannot be before start date
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
          // Se a data de início for depois da data de fim, ajuste a data de fim
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
          // Se a data de fim for antes da data de início, ajuste a data de início
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 30));
          }
        }
      });
    }
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      // _formKey.currentState!.save(); // Não é mais necessário com TextEditingController

      final budgetViewModel = Provider.of<BudgetViewModel>(
        context,
        listen: false,
      );

      // Gerar um novo ID se for um novo orçamento, ou usar o ID existente para edição
      final String budgetId = widget.budget?.id ?? _uuid.v4();

      // DECISÃO IMPORTANTE: Como lidar com orçamentos "gerais" (sem categoria específica)?
      // Opção 1: Definir categoryId como uma String vazia ou um ID especial (ex: 'general_budget_id')
      // Opção 2: Exigir que uma categoria seja sempre selecionada para um orçamento
      // Vamos usar String vazia para indicar "todas as categorias"
      final String selectedCategoryId =
          _selectedCategory?.id ?? ''; // String vazia para "geral"

      final budget = BudgetModel(
        id: budgetId,
        name: _nameController.text, // Usar _nameController.text
        amount: double.parse(
          _amountController.text.replaceAll(',', '.'),
        ), // Usar _amountController.text
        categoryId:
            selectedCategoryId, // <--- CORRIGIDO: Passando categoryId (String)
        startDate: _startDate,
        endDate: _endDate,
      );

      if (widget.budget == null) {
        budgetViewModel.addBudget(budget);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orçamento salvo com sucesso!')),
        );
      } else {
        budgetViewModel.updateBudget(budget);
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
            // Adicionado para evitar overflow com teclado
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController, // Usar controller
                  decoration: const InputDecoration(
                    labelText: 'Descrição do Orçamento',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Informe a descrição'
                              : null,
                  // onSaved não é mais necessário com TextEditingController
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController, // Usar controller
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
                  // onSaved não é mais necessário com TextEditingController
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Data de Início'),
                  subtitle: Text(
                    // Formate a data para exibição
                    '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, isStartDate: true),
                ),
                ListTile(
                  title: const Text('Data de Fim'),
                  subtitle: Text(
                    // Formate a data para exibição
                    '${_endDate.day}/${_endDate.month}/${_endDate.year}',
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
                      // Permite CategoryModel ser null
                      decoration: const InputDecoration(
                        labelText: 'Categoria (Opcional)',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      hint: const Text('Selecione uma categoria'),
                      items: [
                        // Opção para "Todas as categorias" (valor nulo)
                        const DropdownMenuItem<CategoryModel?>(
                          value: null,
                          child: Text('Todas as categorias'),
                        ),
                        // Mapeia suas categorias disponíveis para DropdownMenuItems
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
                    label: const Text('Salvar Orçamento'),
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
