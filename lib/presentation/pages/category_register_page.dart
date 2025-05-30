// lib/presentation/pages/category_register_page.dart
import 'package:flutter/material.dart';
// import 'package:hive/hive.dart'; // Esta linha não é mais necessária aqui
import 'package:provider/provider.dart'; // <--- Adicione esta linha
import '../../data/models/category_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../viewmodels/category_viewmodel.dart'; // <--- Adicione esta linha

class CategoryRegisterPage extends StatefulWidget {
  const CategoryRegisterPage({Key? key}) : super(key: key);

  @override
  State<CategoryRegisterPage> createState() => _CategoryRegisterPageState();
}

class _CategoryRegisterPageState extends State<CategoryRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  Color _selectedColor = Colors.grey;

  // Removido o código do icon picker, como nas suas últimas versões

  _pickColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione uma Cor'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final int iconColorValue = _selectedColor.value;

      // Obtenha a instância do CategoryViewModel
      final categoryViewModel = Provider.of<CategoryViewModel>(
        context,
        listen: false,
      ); // <--- AQUI!

      final category = CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _name!,
        iconCodePoint: Icons.category.codePoint, // Ícone padrão fixo
        iconColorValue: iconColorValue,
      );

      // Chame o método addCategory do ViewModel!
      categoryViewModel.addCategory(category); // <--- AQUI!

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              ElevatedButton.icon(
                onPressed: _pickColor,
                icon: Icon(Icons.colorize, color: _selectedColor),
                label: const Text('Selecionar Cor'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  child: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
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
