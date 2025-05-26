import 'package:controle_financeiro/presentation/pages/budget_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import 'transaction_page.dart';
// Importe as páginas de Metas e Orçamento que você vai criar
import '../pages/goals_page.dart'; // Exemplo
// import '../pages/budget_page.dart'; // Exemplo
import '../pages/category_register_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _selectedDate;
  CategoryModel? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TransactionViewModel>(context);
    final all = viewModel.transactions;

    // Filtro
    final filtered =
        all.where((t) {
          final matchesDate =
              _selectedDate == null
                  ? true
                  : (t.date.day == _selectedDate!.day &&
                      t.date.month == _selectedDate!.month &&
                      t.date.year == _selectedDate!.year);

          final matchesCategory =
              _selectedCategory == null
                  ? true
                  : t.category == _selectedCategory;

          return matchesDate && matchesCategory;
        }).toList();

    final income = filtered.where((t) => t.isIncome).toList();
    final outcome = filtered.where((t) => !t.isIncome).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Controle Financeiro"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Todos'),
              Tab(text: 'Entradas'),
              Tab(text: 'Saídas'),
            ],
          ),
        ),
        // Adicione o Drawer aqui
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Cabeçalho do Drawer (opcional, mas recomendado)
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 30,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Menu Financeiro',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
              ),
              // Opção para Cadastrar Metas
              ListTile(
                leading: const Icon(Icons.track_changes),
                title: const Text('Cadastrar Metas'),
                onTap: () {
                  // Fechar o drawer
                  Navigator.pop(context);
                  // Navegar para a página de Metas
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GoalsPage()),
                  ); // Exemplo
                  // TODO: Implementar a navegação para a página de Metas
                },
              ),
              // Opção para Cadastrar Orçamento/Limite de Gasto
              ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('Cadastrar Orçamento'),
                onTap: () {
                  // Fechar o drawer
                  Navigator.pop(context);
                  // Navegar para a página de Orçamento
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BudgetPage()),
                  ); // Exemplo
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Cadastrar Transações'),
                onTap: () {
                  Navigator.pop(context);
                  // Navega para a tela de movimentações
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Cadastrar Categorias'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CategoryRegisterPage()),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            buildFilters(context),
            Expanded(
              child: TabBarView(
                children: [
                  buildTransactionList(filtered, context),
                  buildTransactionList(income, context),
                  buildTransactionList(outcome, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilters(BuildContext context) {
    final categoriesBox =
        Provider.of<TransactionViewModel>(
          context,
        ).transactions.map((t) => t.category).toSet().toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _selectedDate == null
                  ? 'Filtrar por data'
                  : DateFormat('dd/MM/yyyy').format(_selectedDate!),
            ),
          ),
          DropdownButton<CategoryModel?>(
            value: _selectedCategory,
            hint: const Text('Filtrar por categoria'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Todas categorias'),
              ),
              ...categoriesBox.map((c) {
                return DropdownMenuItem(value: c, child: Text(c.name));
              }).toList(),
            ],
            onChanged: (value) {
              setState(() => _selectedCategory = value);
            },
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedDate = null;
                _selectedCategory = null;
              });
            },
            icon: const Icon(Icons.clear),
            label: const Text("Limpar filtros"),
          ),
        ],
      ),
    );
  }

  Widget buildTransactionList(
    List<TransactionModel> transactions,
    BuildContext context,
  ) {
    final total = transactions.fold<double>(
      0,
      (sum, t) => t.isIncome ? sum + t.amount : sum - t.amount,
    );

    return Column(
      children: [
        const Divider(),
        Expanded(
          child:
              transactions.isEmpty
                  ? const Center(
                    child: Text(
                      'Para cadastrar uma movimentação, utilize o menu  Movimentações',
                    ),
                  )
                  : ListView.builder(
                    itemCount: transactions.length + 2,
                    itemBuilder: (context, index) {
                      if (index < transactions.length) {
                        final t = transactions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  t.isIncome
                                      ? Colors.green[100]
                                      : Colors.red[100],
                              child: Icon(
                                t.isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: t.isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              t.description,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${t.date.day}/${t.date.month}/${t.date.year} • ${t.category.name}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'R\$ ${t.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color:
                                        t.isIncome ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => RegisterPage(
                                                  transaction: t,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (ctx) => AlertDialog(
                                                title: const Text(
                                                  "Confirmação",
                                                ),
                                                content: const Text(
                                                  "Deseja realmente excluir esta movimentação?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          ctx,
                                                          false,
                                                        ),
                                                    child: const Text(
                                                      "Cancelar",
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          ctx,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      "Excluir",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );

                                        if (confirm == true) {
                                          Provider.of<TransactionViewModel>(
                                            context,
                                            listen: false,
                                          ).deleteTransaction(index);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (index == transactions.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'R\$ ${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: total >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox(height: 100);
                    },
                  ),
        ),
      ],
    );
  }
}
