// lib/features/transaction/presentation/pages/transaction_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/category_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../../../category/presentation/viewmodels/category_viewmodel.dart';
import '../widgets/transaction_card.dart';
import 'transaction_page.dart';
import '../../../../core/shared/widgets/custom_scaffold.dart';

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
    // Opcional: ouvir mudanças nas transações para re-aplicar filtros se necessário
    // mas o ViewModel já notifica.
    // Provider.of<TransactionViewModel>(context, listen: false).addListener(_refreshFilters);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Opcional: remover listener se adicionado acima
    // Provider.of<TransactionViewModel>(context, listen: false).removeListener(_refreshFilters);
    super.dispose();
  }

  // void _refreshFilters() {
  //   // Re-aplica os filtros atuais (útil se as transações mudarem fora desta tela)
  //   Provider.of<TransactionViewModel>(context, listen: false).applyFilters(
  //     startDate: _selectedStartDate,
  //     endDate: _selectedEndDate,
  //     categoryId: _selectedCategory?.id,
  //     type: _tabController.index == 0 ? null : (_tabController.index == 1 ? TransactionType.income : TransactionType.expense),
  //   );
  // }

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
      locale: const Locale('pt', 'BR'), // Adicionado para localização
    );
    if (picked != null &&
        (picked.start != _selectedStartDate ||
            picked.end != _selectedEndDate)) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      // Aplica o filtro de data e mantém o filtro de categoria e tipo existentes
      Provider.of<TransactionViewModel>(context, listen: false).applyFilters(
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        categoryId: _selectedCategory?.id,
        type: _getCurrentTransactionTypeFilter(),
      );
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
                        leading: Icon(
                          category.iconData,
                          color: category.iconColor,
                        ), // Mostra a cor do ícone
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
      // Aplica o filtro de categoria e mantém o filtro de data e tipo existentes
      Provider.of<TransactionViewModel>(context, listen: false).applyFilters(
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        categoryId: _selectedCategory?.id,
        type: _getCurrentTransactionTypeFilter(),
      );
    }
  }

  // Função auxiliar para obter o tipo de transação com base na aba selecionada
  TransactionType? _getCurrentTransactionTypeFilter() {
    switch (_tabController.index) {
      case 0:
        return null; // Todos
      case 1:
        return TransactionType.income; // Entradas
      case 2:
        return TransactionType.expense; // Saídas
      default:
        return null;
    }
  }

  // Função para navegar para a página de registro de transação
  void _navigateToTransactionRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => const RegisterPage(), // Usar const para construtor constante
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionViewModel = Provider.of<TransactionViewModel>(context);
    final categoryViewModel = Provider.of<CategoryViewModel>(context);

    // Adicione um listener para a TabController para aplicar filtros quando a aba muda
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Aplica o filtro de tipo da transação atual (com base na aba)
        // e mantém os filtros de data e categoria
        transactionViewModel.applyFilters(
          startDate: _selectedStartDate,
          endDate: _selectedEndDate,
          categoryId: _selectedCategory?.id,
          type: _getCurrentTransactionTypeFilter(),
        );
      }
    });

    // Não é necessário obter transações aqui novamente, pois o ViewModel já filtra e notifica
    final List<TransactionModel> transactionsToShow =
        transactionViewModel.filteredTransactions;

    Widget _buildTransactionList(TransactionType? type) {
      // Já estamos usando filteredTransactions do ViewModel, então não precisamos filtrar aqui novamente
      // A lógica de filtragem por tipo já é feita no applyFilters do ViewModel
      final List<TransactionModel> transactionsForTab =
          transactionsToShow.where((t) {
            if (type == null) return true; // Para a aba "Todos"
            return t.type == type;
          }).toList();

      if (transactionsForTab.isEmpty) {
        String message;
        if (_selectedStartDate != null || _selectedEndDate != null) {
          message = 'Nenhuma movimentação no período selecionado.';
        } else if (_selectedCategory != null) {
          message = 'Nenhuma movimentação para esta categoria.';
        } else {
          message =
              type == null
                  ? 'Nenhuma movimentação registrada.'
                  : (type == TransactionType.income
                      ? 'Nenhuma entrada registrada.'
                      : 'Nenhuma saída registrada.');
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.money_off, size: 50, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _navigateToTransactionRegisterPage,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Transação'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: transactionsForTab.length,
        itemBuilder: (context, index) {
          final transaction = transactionsForTab[index];
          // Garante que a categoria seja buscada com o ID correto
          final category = categoryViewModel.getCategoryById(
            transaction.categoryId,
          );
          return TransactionCard(transaction: transaction, category: category);
        },
      );
    }

    return CustomScaffold(
      title: 'Movimentações',
      appBarBottom: TabBar(
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
            color:
                _selectedStartDate != null
                    ? Theme.of(context).colorScheme.secondary
                    : null, // Indicador visual
          ),
          tooltip: 'Filtrar por Data',
          onPressed: () => _selectDateRange(context),
        ),
        IconButton(
          icon: Icon(
            _selectedCategory != null ? Icons.category : Icons.filter_list,
            color:
                _selectedCategory != null
                    ? Theme.of(context).colorScheme.secondary
                    : null, // Indicador visual
          ),
          tooltip: 'Filtrar por Categoria',
          onPressed: () => _selectCategoryFilter(context),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _navigateToTransactionRegisterPage(),
          tooltip: 'Adicionar nova transação',
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(null), // Aba "Todos"
          _buildTransactionList(TransactionType.income), // Aba "Entradas"
          _buildTransactionList(TransactionType.expense), // Aba "Saídas"
        ],
      ),
    );
  }
}
