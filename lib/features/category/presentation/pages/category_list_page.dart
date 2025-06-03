// lib/presentation/pages/category_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/category_model.dart';
import '../viewmodels/category_viewmodel.dart';
import 'category_register_page.dart'; // Para adicionar/editar categorias
// Importe o CustomScaffold
import '../../../../core/shared/widgets/custom_scaffold.dart'; // Ajuste o caminho conforme sua estrutura

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({Key? key}) : super(key: key);

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  // Função para navegar para a tela de registro de categoria
  void _navigateToAddCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryRegisterPage()),
    );
  }

  // Função para navegar para a tela de edição de categoria
  void _navigateToEditCategory(CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryRegisterPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Minhas Categorias', // Título para o CustomScaffold
      // Botão de adicionar agora na AppBar
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _navigateToAddCategory, // Chamando a função de navegação
          tooltip:
              'Adicionar nova categoria', // Dica de ferramenta para o botão
        ),
      ],
      body: Consumer<CategoryViewModel>(
        builder: (context, categoryViewModel, child) {
          final categories = categoryViewModel.categories;

          if (categories.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma categoria cadastrada. Toque no "+" para adicionar.',
                textAlign: TextAlign.center, // Centraliza o texto
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ), // Estilo para padronizar
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
                  final CategoryModel deletedCategory = category;
                  categoryViewModel.deleteCategory(category.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Categoria "${deletedCategory.name}" excluída.',
                      ),
                      action: SnackBarAction(
                        label: 'Desfazer',
                        onPressed: () {
                          // Note: A re-inserção precisa ser tratada pelo ViewModel para manter a ordem se for crucial.
                          // Aqui, simplesmente adicionamos de volta, o que pode mudar a posição.
                          categoryViewModel.addCategory(deletedCategory);
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
                    onPressed:
                        () => _navigateToEditCategory(
                          category,
                        ), // Chama a função auxiliar
                  ),
                  onTap:
                      () => _navigateToEditCategory(
                        category,
                      ), // Também pode navegar para edição ao tocar
                ),
              );
            },
          );
        },
      ),
      // Removemos o FloatingActionButton para não haver botões duplicados
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _navigateToAddCategory,
      //   tooltip: 'Adicionar nova categoria',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
