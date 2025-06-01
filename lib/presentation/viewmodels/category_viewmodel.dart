// lib/presentation/viewmodels/category_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/category_model.dart';
import '../../utils/list_extensions.dart';

class CategoryViewModel extends ChangeNotifier {
  late Box<CategoryModel> _categoryBox;
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  CategoryViewModel() {
    _init();
  }

  Future<void> _init() async {
    _categoryBox = await Hive.openBox<CategoryModel>('categories');
    _loadCategories();
  }

  void _loadCategories() {
    _categories = _categoryBox.values.toList();
    // Opcional: Adicione prints de debug para verificar se as categorias estão sendo carregadas
    print(
      'DEBUG: CategoryViewModel carregou ${_categories.length} categorias.',
    );
    // for (var cat in _categories) {
    //   print('DEBUG: Categoria: ${cat.name}, ID: ${cat.id}, Ícone: ${cat.iconCodePoint}, Cor: ${cat.iconColorValue}');
    // }
    notifyListeners();
  }

  void addCategory(CategoryModel category) {
    _categoryBox.put(
      category.id,
      category,
    ); // Usa put(id, value) para controle explícito do ID
    print('DEBUG: Categoria adicionada (ID: ${category.id}): ${category.name}');
    _loadCategories(); // Recarrega a lista e notifica
  }

  void updateCategory(CategoryModel category) {
    _categoryBox.put(category.id, category); // Atualiza usando put
    print('DEBUG: Categoria atualizada (ID: ${category.id}): ${category.name}');
    _loadCategories();
  }

  void deleteCategory(String id) {
    // ID da categoria é int
    _categoryBox.delete(id); // Deleta pela chave (que é o ID)
    print('DEBUG: Categoria deletada (ID: $id)');
    _loadCategories();
  }

  CategoryModel? getCategoryById(String id) {
    return _categories.firstWhereOrNull((cat) => cat.id == id);
  }
}
