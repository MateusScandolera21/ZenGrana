import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../../data/models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../../data/models/category_model.dart';
import 'category_register_page.dart';

class RegisterPage extends StatefulWidget {
  final TransactionModel? transaction;

  const RegisterPage({Key? key, this.transaction}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  String? _title;
  double? _amount;
  bool _isIncome = true;

  CategoryModel? _selectedCategory;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();

    final t = widget.transaction;
    if (t != null) {
      _title = t.description;
      _amount = t.amount;
      _isIncome = t.isIncome;
      _selectedCategory = t.category;
    }
  }

  void _loadCategories() {
    final box = Hive.box<CategoryModel>('categories');
    setState(() {
      _categories = box.values.toList();
    });
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.transaction == null) {
        final newTransaction = TransactionModel(
          id: DateTime.now().microsecondsSinceEpoch,
          description: _title!,
          amount: _amount!,
          isIncome: _isIncome,
          category: _selectedCategory!,
          date: DateTime.now(),
        );

        Provider.of<TransactionViewModel>(
          context,
          listen: false,
        ).addTransaction(newTransaction);
      } else {
        final edited = TransactionModel(
          id: widget.transaction!.id,
          description: _title!,
          amount: _amount!,
          isIncome: _isIncome,
          category: _selectedCategory!,
          date: widget.transaction!.date,
        );

        Provider.of<TransactionViewModel>(
          context,
          listen: false,
        ).editTransaction(edited);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  initialValue: _title,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Informe o título'
                              : null,
                  onSaved: (value) => _title = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _amount?.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Informe o valor';
                    if (double.tryParse(value) == null) return 'Valor inválido';
                    return null;
                  },
                  onSaved: (value) => _amount = double.tryParse(value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CategoryModel>(
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items:
                      _categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat.name),
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
                SwitchListTile(
                  title: const Text('Entrada'),
                  value: _isIncome,
                  onChanged: (val) => setState(() => _isIncome = val),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 300.0,
                  child: ElevatedButton.icon(
                    onPressed: _saveTransaction,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Transação'),
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
      ),
    );
  }
}
