// lib/presentation/viewmodels/category_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/category_model.dart';
import '../../utils/list_extensions.dart'; // <--- Adicione esta linha

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
    notifyListeners();
  }

  void addCategory(CategoryModel category) {
    _categoryBox.add(category);
    _loadCategories();
  }

  CategoryModel? getCategoryById(int id) {
    return _categories.firstWhereOrNull((cat) => cat.id == id);
  }

  // Você precisará adicionar o método firstWhereOrNull em uma extensão ou helper,
  // ou usar tryFirstWhere para evitar erros se não encontrar.
  // Exemplo simples (adicione essa extensão em algum lugar, ex: lib/utils/list_extensions.dart):
  /*
  extension ListExtension<T> on List<T> {
    T? firstWhereOrNull(bool Function(T element) test) {
      for (T element in this) {
        if (test(element)) return element;
      }
      return null;
    }
  }
  */
  // Ou use um loop for ou try-catch:
  // CategoryModel? getCategoryById(int id) {
  //   try {
  //     return _categories.firstWhere((cat) => cat.id == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // TODO: Adicionar métodos para editar e deletar categorias
}
