import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart'; // <--- Nova Importação: CategoryViewModel
import '../../utils/list_extensions.dart'; // <--- Nova Importação: firstWhereOrNull se você criou

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  double? _amount;
  CategoryModel? _selectedCategory; // Pode ser nulo se o orçamento for "geral"

  // Uma lista para armazenar as categorias disponíveis
  List<CategoryModel> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback para garantir que o context esteja pronto para o Provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  void _loadCategories() {
    // Agora acessamos as categorias do CategoryViewModel, que deve ter a lista completa.
    final categoryViewModel = Provider.of<CategoryViewModel>(
      context,
      listen: false,
    );

    setState(() {
      _availableCategories =
          categoryViewModel.categories; // Obter todas as categorias cadastradas
      // Se não houver categoria selecionada e houver categorias disponíveis,
      // você pode pré-selecionar a primeira ou deixar nulo para "Todas as categorias".
      if (_selectedCategory == null && _availableCategories.isNotEmpty) {
        // Opcional: _selectedCategory = _availableCategories.first;
      }
    });
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Certifique-se de que a Box 'budgets' esteja aberta em 'main.dart'.
      final box = Hive.box<BudgetModel>('budgets');

      // Se _selectedCategory for nulo, significa que o orçamento é para 'Todas as categorias'.
      // O BudgetModel.category deve ser anulável (CategoryModel?).
      final budget = BudgetModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _name!,
        amount: _amount!,
        // Se _selectedCategory for null, passa null. Caso contrário, passa o objeto CategoryModel.
        category: _selectedCategory,
      );

      box.add(budget);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Orçamento salvo com sucesso!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Orçamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name, // Para re-popular se estiver editando
                decoration: const InputDecoration(
                  labelText: 'Descrição do Orçamento',
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
                initialValue: _amount?.toString(), // Para re-popular
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
                onSaved:
                    (value) =>
                        _amount = double.tryParse(value!.replaceAll(',', '.')),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CategoryModel>(
                decoration: const InputDecoration(
                  labelText: 'Categoria (Opcional)',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                hint: const Text('Selecione uma categoria'),
                items: [
                  // Opção para "Todas as categorias" (valor nulo)
                  const DropdownMenuItem<CategoryModel>(
                    value: null,
                    child: Text('Todas as categorias'),
                  ),
                  // Mapeia suas categorias disponíveis para DropdownMenuItems
                  ..._availableCategories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Row(
                            // Exibe ícone e nome da categoria
                            children: [
                              Icon(cat.iconData, color: cat.iconColor),
                              const SizedBox(width: 8),
                              Text(cat.name),
                            ],
                          ),
                        ),
                      )
                      .toList(), // Manter o .toList() aqui é ok pois não está em um spread
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width:
                    double
                        .infinity, // Usar double.infinity para ocupar largura total
                child: ElevatedButton.icon(
                  onPressed: _saveBudget,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Orçamento'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ), // Aumentei o padding vertical
                    textStyle: const TextStyle(
                      fontSize: 18,
                    ), // Aumentei o tamanho do texto
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
