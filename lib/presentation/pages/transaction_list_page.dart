// lib/presentation/pages/transaction_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../viewmodels/transaction_viewmodel.dart'; // Seu ViewModel de transações
// Importe seu ViewModel de categorias se você tiver um separado, ou acesse as categorias pelo TransactionViewModel
import '../viewmodels/category_viewmodel.dart'; // Assumindo que você terá um CategoryViewModel
import '../widgets/transaction_card.dart'; // O widget do card que acabamos de criar
import 'transaction_page.dart'; // A tela de cadastro de transação

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({Key? key}) : super(key: key);

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Função para abrir o seletor de data
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDateRange:
          _selectedStartDate != null && _selectedEndDate != null
              ? DateTimeRange(
                start: _selectedStartDate!,
                end: _selectedEndDate!,
              )
              : null,
    );
    if (picked != null &&
        (picked.start != _selectedStartDate ||
            picked.end != _selectedEndDate)) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      // Notificar o ViewModel para aplicar o filtro de data
      Provider.of<TransactionViewModel>(
        context,
        listen: false,
      ).applyDateFilter(_selectedStartDate, _selectedEndDate);
    }
  }

  // Função para selecionar a categoria (para o filtro)
  Future<void> _selectCategoryFilter(BuildContext context) async {
    final categoryViewModel = Provider.of<CategoryViewModel>(
      context,
      listen: false,
    );
    final List<CategoryModel> categories = categoryViewModel.categories;

    final CategoryModel? selected = await showDialog<CategoryModel>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar por Categoria'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Opção para remover filtro
                ListTile(
                  leading: const Icon(Icons.clear),
                  title: const Text('Todas as Categorias'),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pop(null); // Retorna nulo para remover o filtro
                  },
                ),
                // Lista de categorias
                ...categories
                    .map(
                      (category) => ListTile(
                        leading: Icon(category.iconData),
                        title: Text(category.name),
                        onTap: () {
                          Navigator.of(context).pop(category);
                        },
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        );
      },
    );

    if (selected != _selectedCategory) {
      setState(() {
        _selectedCategory = selected;
      });
      // Notificar o ViewModel para aplicar o filtro de categoria
      Provider.of<TransactionViewModel>(
        context,
        listen: false,
      ).applyCategoryFilter(_selectedCategory?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionViewModel = Provider.of<TransactionViewModel>(context);
    final categoryViewModel = Provider.of<CategoryViewModel>(
      context,
    ); // Para buscar nomes/ícones de categorias

    // Lista de transações filtradas pelo ViewModel (data, tipo e categoria)
    final List<TransactionModel> transactions =
        transactionViewModel.filteredTransactions;

    // Função auxiliar para construir as listas de transações por tipo
    Widget _buildTransactionList(TransactionType? type) {
      final List<TransactionModel> filteredByType =
          transactions.where((t) {
            if (type == null) return true; // Para a aba "Todos"
            return t.type == type;
          }).toList();

      if (filteredByType.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.money_off, size: 50, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                type == null
                    ? 'Nenhuma movimentação registrada.'
                    : (type == TransactionType.income
                        ? 'Nenhuma entrada registrada.'
                        : 'Nenhuma saída registrada.'),
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Transação'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: filteredByType.length,
        itemBuilder: (context, index) {
          final transaction = filteredByType[index];
          final category = categoryViewModel.getCategoryById(
            transaction.categoryId,
          );
          return TransactionCard(transaction: transaction, category: category);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimentações'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Entradas'),
            Tab(text: 'Saídas'),
          ],
        ),
        actions: [
          // Botão de filtro por data
          IconButton(
            icon: Icon(
              _selectedStartDate != null ? Icons.date_range : Icons.filter_alt,
            ),
            tooltip: 'Filtrar por Data',
            onPressed: () => _selectDateRange(context),
          ),
          // Botão de filtro por categoria
          IconButton(
            icon: Icon(
              _selectedCategory != null ? Icons.category : Icons.filter_list,
            ),
            tooltip: 'Filtrar por Categoria',
            onPressed: () => _selectCategoryFilter(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(null), // Aba "Todos"
          _buildTransactionList(TransactionType.income), // Aba "Entradas"
          _buildTransactionList(TransactionType.expense), // Aba "Saídas"
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega para a tela de cadastro de transação
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegisterPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
