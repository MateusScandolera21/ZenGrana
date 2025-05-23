import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../viewmodels/transaction_viewmodel.dart';

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
    // No initState, você pode carregar as categorias.
    // Usamos WidgetsBinding.instance.addPostFrameCallback para garantir que o context esteja pronto.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  void _loadCategories() {
    // Acessar as categorias do TransactionViewModel ou de um CategoryViewModel
    // Aqui presumo que as categorias estão no TransactionViewModel,
    // se você tiver um CategoryViewModel, use-o.
    final transactionViewModel = Provider.of<TransactionViewModel>(
      context,
      listen: false,
    );

    // Pegar todas as categorias únicas das transações existentes
    // ou de uma lista de categorias pré-cadastradas no seu ViewModel
    setState(() {
      _availableCategories =
          transactionViewModel.transactions
              .map((t) => t.category)
              .toSet()
              .toList();
    });
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // **ATENÇÃO:** Garanta que a Box 'budgets' esteja aberta antes de usar.
      // Idealmente, isso é feito no 'main.dart' da sua aplicação.
      final box = Hive.box<BudgetModel>('budgets');

      // Se _selectedCategory for opcional, o campo 'category' no BudgetModel
      // também deve ser anulável (CategoryModel?). Se não for,
      // você precisará garantir que uma categoria seja selecionada.
      final budget = BudgetModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _name!,
        amount: _amount!,
        category: _selectedCategory, // Removido '!' para permitir nulo
      );

      box.add(budget);

      // Feedback para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Orçamento salvo com sucesso!')),
      );

      // Volta para a tela anterior
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
                decoration: const InputDecoration(
                  labelText: 'Valor do Orçamento (R\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                  labelText: 'Categoria ( Opcional )',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                hint: const Text('Selecione uma categoria'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todas as categorias'),
                  ),
                  ..._availableCategories
                      .map(
                        (cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat.name)),
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
                width: 300.0,
                child: ElevatedButton.icon(
                  onPressed: _saveBudget,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Orçamento'),
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
