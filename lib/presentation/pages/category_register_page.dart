import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/category_model.dart';

class CategoryRegisterPage extends StatefulWidget {
  const CategoryRegisterPage({Key? key}) : super(key: key);

  @override
  State<CategoryRegisterPage> createState() => _CategoryRegisterPageState();
}

class _CategoryRegisterPageState extends State<CategoryRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final box = Hive.box<CategoryModel>('categories');
      final category = CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _name!,
      );
      box.add(category);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Categoria')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nome da Categoria',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe um nome'
                            : null,
                onSaved: (value) => _name = value,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300.0,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
