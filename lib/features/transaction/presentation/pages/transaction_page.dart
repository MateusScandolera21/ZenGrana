// lib/features/transaction/presentation/pages/transaction_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../../../../data/models/category_model.dart';
import '../../../category/presentation/pages/category_register_page.dart';
import '../../../category/presentation/viewmodels/category_viewmodel.dart';
// Importe o CustomScaffold (se você quiser usá-lo nesta página também)
import '../../../../core/shared/widgets/custom_scaffold.dart';

class RegisterPage extends StatefulWidget {
  final TransactionModel? transaction;

  const RegisterPage({Key? key, this.transaction}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;

  TransactionType _selectedTransactionType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryViewModel = Provider.of<CategoryViewModel>(
        context,
        listen: false,
      );

      categoryViewModel.addListener(_updateCategories);
      _updateCategories();

      final t = widget.transaction;
      if (t != null) {
        _titleController.text = t.description;
        _amountController.text = t.amount.toString();
        _selectedTransactionType = t.type;
        _selectedDate = t.date;
        // Certifique-se de que getCategoryById retorna nullable e é tratado.
        _selectedCategory = categoryViewModel.getCategoryById(t.categoryId);
      } else {
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      }
    });
  }

  @override
  void dispose() {
    Provider.of<CategoryViewModel>(
      context,
      listen: false,
    ).removeListener(_updateCategories);
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _updateCategories() {
    final categoryViewModel = Provider.of<CategoryViewModel>(
      context,
      listen: false,
    );
    setState(() {
      _categories = categoryViewModel.categories;
      // Lógica para pré-selecionar ou limpar a categoria
      if (_selectedCategory == null && _categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      } else if (_selectedCategory != null &&
          !_categories.any((cat) => cat.id == _selectedCategory!.id)) {
        // Se a categoria selecionada não existe mais, limpa ou seleciona a primeira.
        _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma categoria.')),
        );
        return;
      }

      final transactionViewModel = Provider.of<TransactionViewModel>(
        context,
        listen: false,
      );

      final String transactionId = widget.transaction?.id ?? const Uuid().v4();

      final transaction = TransactionModel(
        id: transactionId,
        description: _titleController.text,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        type: _selectedTransactionType,
        categoryId: _selectedCategory!.id,
        date: _selectedDate,
      );

      if (widget.transaction == null) {
        transactionViewModel.addTransaction(transaction);
      } else {
        transactionViewModel.updateTransaction(transaction);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Você pode decidir se quer usar CustomScaffold aqui para consistência de UI.
    // Se usar, o `Scaffold` envolvente deve ser removido.
    return Scaffold(
      // Ou CustomScaffold, se preferir
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? 'Nova Movimentação'
              : 'Editar Movimentação',
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
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Informe o título'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o valor';
                    }
                    if (double.tryParse(value.replaceAll(',', '.')) == null) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Data'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                _categories.isEmpty
                    ? Column(
                      children: [
                        const Text(
                          'Nenhuma categoria cadastrada. Por favor, cadastre uma categoria primeiro.',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const CategoryRegisterPage(),
                              ),
                            );
                            _updateCategories();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Cadastrar Categoria'),
                        ),
                      ],
                    )
                    : DropdownButtonFormField<CategoryModel>(
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      items:
                          _categories
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
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Selecione uma categoria' : null,
                    ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<TransactionType>(
                        title: const Text('Entrada'),
                        value: TransactionType.income,
                        groupValue: _selectedTransactionType,
                        onChanged: (TransactionType? value) {
                          setState(() {
                            _selectedTransactionType = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<TransactionType>(
                        title: const Text('Saída'),
                        value: TransactionType.expense,
                        groupValue: _selectedTransactionType,
                        onChanged: (TransactionType? value) {
                          setState(() {
                            _selectedTransactionType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveTransaction,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Movimentação'),
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
