// lib/presentation/pages/category_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import '../viewmodels/category_viewmodel.dart';
import 'category_register_page.dart'; // Para adicionar/editar categorias

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({Key? key}) : super(key: key);

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Categorias')),
      body: Consumer<CategoryViewModel>(
        builder: (context, categoryViewModel, child) {
          final categories = categoryViewModel.categories;

          if (categories.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma categoria cadastrada. Toque no "+" para adicionar.',
              ),
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Dismissible(
                key: ValueKey(category.id), // Chave única para o Dismissible
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction:
                    DismissDirection
                        .endToStart, // Deslizar da direita para a esquerda
                onDismissed: (direction) {
                  // Salva a categoria temporariamente para possibilitar desfazer
                  final CategoryModel deletedCategory = category;
                  final int deletedIndex = index;

                  // Remove a categoria do ViewModel
                  categoryViewModel.deleteCategory(category.id);

                  // Exibe um SnackBar para confirmar a exclusão e oferecer desfazer
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Categoria "${deletedCategory.name}" excluída.',
                      ),
                      action: SnackBarAction(
                        label: 'Desfazer',
                        onPressed: () {
                          // Adiciona a categoria de volta
                          categoryViewModel.addCategory(deletedCategory);
                          // Nota: O addCategory() irá apenas adicionar. Se você quer re-inserir na mesma posição,
                          // o ViewModel precisaria de um método para isso, ou usar uma estratégia de lista temporária.
                          // Para simplicidade, addCategory() a colocará no final ou onde o Hive organizar.
                        },
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category.iconColor.withOpacity(
                      0.2,
                    ), // Usa a cor da categoria
                    child: Icon(
                      category.iconData, // Usa o ícone da categoria
                      color: category.iconColor,
                    ),
                  ),
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navega para a tela de registro/edição com a categoria existente
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  CategoryRegisterPage(category: category),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    // Também pode navegar para edição ao tocar na lista
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CategoryRegisterPage(category: category),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega para a tela de registro para adicionar uma nova categoria
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategoryRegisterPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
