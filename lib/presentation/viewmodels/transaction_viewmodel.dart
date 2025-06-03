// lib/presentation/viewmodels/transaction_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart'; // Mantenha, pois pode ser útil para exibição ou lógica
import '../../data/models/budget_model.dart'; // <--- NOVO IMPORT para o método de cálculo de orçamento

class TransactionViewModel extends ChangeNotifier {
  List<TransactionModel> _allTransactions =
      []; // Todas as transações carregadas
  List<TransactionModel> _filteredTransactions =
      []; // Transações após a aplicação de filtros

  // Construtor: carrega as transações ao inicializar o ViewModel
  TransactionViewModel() {
    _loadTransactions();
  }

  // Getter para as transações filtradas que a UI irá observar
  List<TransactionModel> get filteredTransactions => _filteredTransactions;

  // Getter para todas as transações (útil para cálculos totais ou outros ViewModels)
  List<TransactionModel> get allTransactions => _allTransactions;

  // Carrega transações do Hive
  Future<void> _loadTransactions() async {
    try {
      final box = await Hive.openBox<TransactionModel>('transactions');
      _allTransactions = box.values.toList();
      _filteredTransactions = List.from(
        _allTransactions,
      ); // Inicialmente, todas as transações são filtradas
      print('DEBUG: Transações carregadas: ${_allTransactions.length}');
    } catch (e) {
      print('ERRO: Falha ao carregar transações do Hive: $e');
    }
    notifyListeners(); // Notifica a UI sobre a mudança
  }

  // Adiciona uma nova transação
  Future<void> addTransaction(TransactionModel transaction) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.put(transaction.id, transaction); // Usa ID String como chave
    print(
      'DEBUG: Transação adicionada (ID: ${transaction.id}): ${transaction.description}',
    );
    await _loadTransactions(); // Recarrega para atualizar as listas
  }

  // Atualiza uma transação existente
  Future<void> updateTransaction(TransactionModel transaction) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.put(transaction.id, transaction); // Atualiza pela chave
    print(
      'DEBUG: Transação atualizada (ID: ${transaction.id}): ${transaction.description}',
    );
    await _loadTransactions(); // Recarrega para atualizar as listas
  }

  // Deleta uma transação pelo ID (agora String)
  Future<void> deleteTransaction(String id) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.delete(id); // Deleta diretamente pela chave
    print('DEBUG: Transação deletada (ID: $id)');
    await _loadTransactions(); // Recarrega para atualizar as listas
  }

  // Método unificado para aplicar todos os filtros
  void applyFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId, // <--- MUDOU PARA STRING
    TransactionType?
    type, // Adicionei a opção de filtrar por tipo (receita/despesa)
  }) {
    List<TransactionModel> currentFiltered = List.from(_allTransactions);

    // Filtro por data
    if (startDate != null || endDate != null) {
      currentFiltered =
          currentFiltered.where((transaction) {
            final transactionDate = DateTime(
              transaction.date.year,
              transaction.date.month,
              transaction.date.day,
            );

            bool matchesStart =
                startDate == null ||
                transactionDate.isAtSameMomentAs(
                  DateTime(startDate.year, startDate.month, startDate.day),
                ) ||
                transactionDate.isAfter(
                  DateTime(startDate.year, startDate.month, startDate.day),
                );
            bool matchesEnd =
                endDate == null ||
                transactionDate.isAtSameMomentAs(
                  DateTime(endDate.year, endDate.month, endDate.day),
                ) ||
                transactionDate.isBefore(
                  DateTime(endDate.year, endDate.month, endDate.day),
                );
            return matchesStart && matchesEnd;
          }).toList();
    }

    // Filtro por categoria (agora String)
    if (categoryId != null && categoryId.isNotEmpty) {
      // Verifica se não é nulo e não é vazio (para "todas as categorias")
      currentFiltered =
          currentFiltered.where((transaction) {
            return transaction.categoryId == categoryId;
          }).toList();
    }

    // Filtro por tipo de transação (receita/despesa)
    if (type != null) {
      currentFiltered =
          currentFiltered.where((transaction) {
            return transaction.type == type;
          }).toList();
    }

    _filteredTransactions = currentFiltered;
    print(
      'DEBUG: Filtros aplicados. Transações filtradas: ${_filteredTransactions.length}',
    );
    notifyListeners();
  }

  // Métodos de filtro individuais (opcional, pode ser substituído por applyFilters)
  void applyDateFilter(DateTime? startDate, DateTime? endDate) {
    applyFilters(startDate: startDate, endDate: endDate);
  }

  void applyCategoryFilter(String? categoryId) {
    // MUDOU PARA STRING
    applyFilters(categoryId: categoryId);
  }

  // Calcula o balanço total das transações filtradas
  double getTotalBalance() {
    return _filteredTransactions.fold(0.0, (sum, transaction) {
      if (transaction.type == TransactionType.income) {
        return sum + transaction.amount;
      } else {
        return sum - transaction.amount;
      }
    });
  }

  /// Calcula o valor gasto para um orçamento específico.
  /// Recebe o `budget` e a lista de `allCategories` (se precisar de informações da categoria).
  double calculateSpentAmountForBudget(
    BudgetModel budget,
    List<CategoryModel> allCategories,
  ) {
    double spent = 0.0;
    // Opcional: Se precisar acessar propriedades da CategoryModel associada ao orçamento,
    // você poderia encontrar a categoria aqui:
    // final budgetCategory = allCategories.firstWhereOrNull((cat) => cat.id == budget.categoryId);

    // Filtra todas as transações (não apenas as filtradas) para o cálculo do orçamento
    for (var transaction in _allTransactions) {
      // Condições para incluir a transação no cálculo do gasto do orçamento:
      // 1. É uma despesa.
      // 2. Pertence à categoria do orçamento OU o orçamento é "geral" (categoryId vazio).
      // 3. A transação está dentro do período de início e fim do orçamento.
      if (transaction.type == TransactionType.expense &&
          (budget.categoryId.isEmpty ||
              transaction.categoryId == budget.categoryId) &&
          !transaction.date.isBefore(
            DateTime(
              budget.startDate.year,
              budget.startDate.month,
              budget.startDate.day,
            ),
          ) && // Considera o dia de início
          !transaction.date.isAfter(
            DateTime(
              budget.endDate.year,
              budget.endDate.month,
              budget.endDate.day,
            ).add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
          )) // Considera o dia de fim (até o final do dia)
      {
        spent += transaction.amount;
      }
    }
    return spent;
  }
}
