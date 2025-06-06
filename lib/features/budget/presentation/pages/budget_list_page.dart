// lib/presentation/pages/budget_list_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Mantenha este, pois é usado para Consumers
import '../../../../data/models/budget_model.dart';
import '../../../../data/models/category_model.dart';
import '../viewmodels/budget_viewmodel.dart';
import '../../../category/presentation/viewmodels/category_viewmodel.dart';
import '../../../transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'budget_page.dart';
import '../../../../core/shared/widgets/custom_scaffold.dart';

class BudgetListPage extends StatelessWidget {
  const BudgetListPage({Key? key}) : super(key: key);

  void _confirmDeleteBudget(
    BuildContext context,
    BudgetViewModel budgetViewModel,
    BudgetModel budget,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja excluir o orçamento "${budget.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Chama o método deleteBudget do ViewModel
                budgetViewModel.deleteBudget(budget.id);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orçamento excluído!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToBudgetRegisterPage(
    BuildContext context, {
    BudgetModel? budget,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => BudgetPage(budget: budget)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Removemos o MultiProvider redundante aqui.
    // Os ViewModels já devem ser fornecidos mais acima na árvore de widgets (ex: main.dart).
    return CustomScaffold(
      title: 'Meus Orçamentos',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _navigateToBudgetRegisterPage(context),
          tooltip: 'Novo orçamento',
        ),
      ],
      body: Consumer3<BudgetViewModel, CategoryViewModel, TransactionViewModel>(
        builder: (
          context,
          budgetViewModel,
          categoryViewModel,
          transactionViewModel,
          child,
        ) {
          if (budgetViewModel.budgets.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum orçamento cadastrado ainda.\nClique no "+" para adicionar um novo!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: budgetViewModel.budgets.length,
            itemBuilder: (context, index) {
              final budget = budgetViewModel.budgets[index];
              final category = categoryViewModel.getCategoryById(
                budget.categoryId,
              );
              final spentAmount = transactionViewModel
                  .calculateSpentAmountForBudget(
                    budget,
                    categoryViewModel.categories,
                  );
              final remainingAmount = budget.amount - spentAmount;
              final isOverBudget = remainingAmount < 0;

              final currencyFormat = NumberFormat.currency(
                locale: 'pt_BR',
                symbol: 'R\$',
              );
              final dateFormat = DateFormat('dd/MM/yyyy');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              budget.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
                                  _navigateToBudgetRegisterPage(
                                    context,
                                    budget: budget, // Passando o orçamento
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _confirmDeleteBudget(
                                    context,
                                    budgetViewModel,
                                    budget,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                        // ... (Resto do seu código BudgetListPage)
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category != null && budget.categoryId.isNotEmpty
                            ? 'Categoria: ${category.name}'
                            : 'Categoria: Todas as categorias',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        'Período: ${dateFormat.format(budget.startDate)} - ${dateFormat.format(budget.endDate)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Orçamento Total: ${currencyFormat.format(budget.amount)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Gasto: ${currencyFormat.format(spentAmount)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Restante: ${currencyFormat.format(remainingAmount)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isOverBudget
                                          ? Colors.red
                                          : Colors.green[700],
                                ),
                              ),
                              if (isOverBudget)
                                const Text(
                                  'Estourou o orçamento!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value:
                            budget.amount > 0 ? spentAmount / budget.amount : 0,
                        backgroundColor: Colors.grey[300],
                        color: isOverBudget ? Colors.red : Colors.green,
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
