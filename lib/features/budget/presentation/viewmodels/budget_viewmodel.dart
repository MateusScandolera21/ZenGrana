// lib/features/budget/presentation/viewmodels/budget_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../data/models/budget_model.dart';
import '../../../../data/models/transaction_model.dart'; // Para cálculo de valor gasto
import '../../../../core/services/recent_activity_service.dart'; // Importe o serviço de atividades recentes

class BudgetViewModel extends ChangeNotifier {
  late Box<BudgetModel> _budgetBox;
  List<BudgetModel> _budgets = [];

  final RecentActivityService _activityService = RecentActivityService();

  List<BudgetModel> get budgets => _budgets;

  Future<void>? _initFuture;

  BudgetViewModel() {
    print('DEBUG: BudgetViewModel - Construtor chamado.');
    _initFuture = _init();
  }

  Future<void> _init() async {
    print('DEBUG: BudgetViewModel - _init() iniciado.');
    try {
      _budgetBox = await Hive.openBox<BudgetModel>('budgets');
      print('DEBUG: BudgetViewModel - Box "budgets" aberta.');

      _budgetBox.listenable().addListener(_loadBudgets);

      _loadBudgets();
      print('DEBUG: BudgetViewModel - Orçamentos carregados inicialmente.');
    } catch (e) {
      print('ERRO: BudgetViewModel - Falha no _init(): $e');
    }
  }

  void _loadBudgets() {
    _budgets = _budgetBox.values.toList();
    print(
      'DEBUG: BudgetViewModel - _loadBudgets chamado. Orçamentos: ${_budgets.length}',
    );
    notifyListeners();
  }

  Future<void> addBudget(BudgetModel budget) async {
    await _initFuture;
    await _budgetBox.put(budget.id, budget);
    print(
      'DEBUG: BudgetViewModel - Orçamento adicionado (ID: ${budget.id}): ${budget.name}',
    );
    _activityService.addActivity(
      type: 'Orçamento',
      description: 'Novo orçamento "${budget.name}" criado.',
    );
  }

  Future<void> updateBudget(BudgetModel budget) async {
    await _initFuture;
    await _budgetBox.put(budget.id, budget);
    print(
      'DEBUG: BudgetViewModel - Orçamento atualizado (ID: ${budget.id}): ${budget.name}',
    );
    _activityService.addActivity(
      type: 'Orçamento',
      description: 'Orçamento "${budget.name}" atualizado.',
    );
  }

  Future<void> deleteBudget(String id) async {
    await _initFuture;
    final budgetToDelete = _budgetBox.get(id);
    await _budgetBox.delete(id);
    print('DEBUG: BudgetViewModel - Orçamento deletado (ID: $id)');

    if (budgetToDelete != null) {
      _activityService.addActivity(
        type: 'Orçamento',
        description: 'Orçamento "${budgetToDelete.name}" excluído.',
      );
    }
  }

  // --- ALTERAÇÃO AQUI: Torne o tipo de retorno nullable (BudgetModel?) ---
  BudgetModel? getBudgetById(String id) {
    // Como a lista _budgets é reativa e atualizada pelo listener,
    // buscar nela é síncrono e seguro após a inicialização.
    // Retorna null se não encontrar.
    return _budgets.firstWhereOrNull(
      // Use firstWhereOrNull para evitar a exceção
      (budget) => budget.id == id,
    );
    // Ou, se você não tem firstWhereOrNull, pode fazer manualmente:
    /*
    try {
      return _budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
    */
  }

  double calculateSpentAmountForBudget(
    BudgetModel budget,
    List<TransactionModel> allTransactions,
  ) {
    double spent = 0.0;
    for (var transaction in allTransactions) {
      final bool isCategoryMatch =
          budget.categoryId.isEmpty ||
          transaction.categoryId == budget.categoryId;

      if (isCategoryMatch &&
          !transaction.date.isBefore(budget.startDate) &&
          !transaction.date.isAfter(budget.endDate) &&
          transaction.type == TransactionType.expense) {
        spent += transaction.amount;
      }
    }
    return spent;
  }

  @override
  void dispose() {
    print('DEBUG: BudgetViewModel - dispose() chamado.');
    if (_budgetBox.isOpen) {
      _budgetBox.listenable().removeListener(_loadBudgets);
    }
    super.dispose();
  }
}

// Se você não tiver um pacote como 'collection' que oferece .firstWhereOrNull,
// você pode adicionar uma extensão simples para List se desejar:
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
