// lib/presentation/pages/transaction_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/category_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../../../category/presentation/viewmodels/category_viewmodel.dart';
import '../widgets/transaction_card.dart';
import 'transaction_page.dart'; // Provavelmente a página de registro/edição de transações
// Importe o CustomScaffold
import '../../../../core/shared/widgets/custom_scaffold.dart'; // Ajuste o caminho conforme sua estrutura

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
      Provider.of<TransactionViewModel>(
        context,
        listen: false,
      ).applyDateFilter(_selectedStartDate, _selectedEndDate);
    }
  }

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
                ListTile(
                  leading: const Icon(Icons.clear),
                  title: const Text('Todas as Categorias'),
                  onTap: () {
                    Navigator.of(context).pop(null);
                  },
                ),
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
      Provider.of<TransactionViewModel>(
        context,
        listen: false,
      ).applyCategoryFilter(_selectedCategory?.id);
    }
  }

  // Função para navegar para a página de registro de transação
  void _navigateToTransactionRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterPage(),
      ), // Assumindo TransactionPage é a tela de registro
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionViewModel = Provider.of<TransactionViewModel>(context);
    final categoryViewModel = Provider.of<CategoryViewModel>(context);

    final List<TransactionModel> transactions =
        transactionViewModel.filteredTransactions;

    Widget _buildTransactionList(TransactionType? type) {
      final List<TransactionModel> filteredByType =
          transactions.where((t) {
            if (type == null) return true;
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
                onPressed:
                    _navigateToTransactionRegisterPage, // Usa a função auxiliar
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

    return CustomScaffold(
      title: 'Movimentações', // Título para o CustomScaffold
      appBarBottom: TabBar(
        // Passa a TabBar para o appBarBottom
        controller: _tabController,
        tabs: const [
          Tab(text: 'Todos'),
          Tab(text: 'Entradas'),
          Tab(text: 'Saídas'),
        ],
      ),
      appBarActions: [
        IconButton(
          icon: Icon(
            _selectedStartDate != null ? Icons.date_range : Icons.filter_alt,
          ),
          tooltip: 'Filtrar por Data',
          onPressed: () => _selectDateRange(context),
        ),
        IconButton(
          icon: Icon(
            _selectedCategory != null ? Icons.category : Icons.filter_list,
          ),
          tooltip: 'Filtrar por Categoria',
          onPressed: () => _selectCategoryFilter(context),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _navigateToTransactionRegisterPage(),
          tooltip: 'Adicionar nova transação',
        ),
        // Não adicionamos o botão de '+' aqui, ele fica no FAB
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(null),
          _buildTransactionList(TransactionType.income),
          _buildTransactionList(TransactionType.expense),
        ],
      ),
    );
  }
}
