// lib/presentation/pages/category_register_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';
import '../viewmodels/category_viewmodel.dart';

class CategoryRegisterPage extends StatefulWidget {
  final CategoryModel? category; // Torna nulo para adicionar uma nova

  const CategoryRegisterPage({Key? key, this.category}) : super(key: key);

  @override
  State<CategoryRegisterPage> createState() => _CategoryRegisterPageState();
}

class _CategoryRegisterPageState extends State<CategoryRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  Color _selectedColor = Colors.grey;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Se estiver editando, pré-preenche os campos
    if (widget.category != null) {
      _name = widget.category!.name;
      _selectedColor = widget.category!.iconColor;
    }
  }

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
      final categoryViewModel = Provider.of<CategoryViewModel>(
        context,
        listen: false,
      );

      if (widget.category == null) {
        // Adicionando nova categoria
        final newCategory = CategoryModel(
          id: _uuid.v4(), // ID único para nova categoria
          name: _name!,
          iconCodePoint: Icons.category.codePoint, // Ícone padrão fixo
          iconColorValue: iconColorValue,
        );
        categoryViewModel.addCategory(newCategory);
      } else {
        // Editando categoria existente
        final updatedCategory = widget.category!.copyWith(
          // Usa copyWith para criar nova instância
          name: _name!,
          iconColorValue: iconColorValue,
          // iconCodePoint permanece o mesmo, a menos que você adicione um seletor de ícones
        );
        categoryViewModel.updateCategory(updatedCategory);
      }

      Navigator.pop(context); // Volta para a tela anterior (CategoryListPage)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null ? 'Nova Categoria' : 'Editar Categoria',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _name, // Define o valor inicial para edição
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
