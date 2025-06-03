// lib/presentation/viewmodels/budget_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/transaction_model.dart'; // Para cálculo de valor gasto

class BudgetViewModel extends ChangeNotifier {
  late Box<BudgetModel> _budgetBox;
  List<BudgetModel> _budgets = [];

  // Lista pública de orçamentos (somente leitura)
  List<BudgetModel> get budgets => _budgets;

  BudgetViewModel() {
    print('DEBUG: BudgetViewModel - Construtor chamado.');
    _init();
  }

  // Inicializa o Hive Box para orçamentos
  Future<void> _init() async {
    print('DEBUG: BudgetViewModel - _init() iniciado.');
    try {
      // Abre a caixa 'budgets'. Certifique-se que o nome é único e consistente.
      _budgetBox = await Hive.openBox<BudgetModel>('budgets');
      print('DEBUG: BudgetViewModel - Box "budgets" aberta.');
      _loadBudgets(); // Carrega os orçamentos após abrir a caixa
      print('DEBUG: BudgetViewModel - Orçamentos carregados inicialmente.');
    } catch (e) {
      print('ERRO: BudgetViewModel - Falha no _init(): $e');
      // Trate o erro de inicialização aqui, talvez com um callback para a UI
    }
  }

  // Carrega todos os orçamentos do Hive para a lista interna
  void _loadBudgets() {
    _budgets = _budgetBox.values.toList();
    print(
      'DEBUG: BudgetViewModel - _loadBudgets chamado. Orçamentos: ${_budgets.length}',
    );
    notifyListeners(); // Notifica os ouvintes que a lista mudou
  }

  // Adiciona um novo orçamento
  Future<void> addBudget(BudgetModel budget) async {
    await _budgetBox.put(budget.id, budget); // Usa o ID do orçamento como chave
    print(
      'DEBUG: BudgetViewModel - Orçamento adicionado (ID: ${budget.id}): ${budget.name}',
    );
    _loadBudgets(); // Recarrega a lista para atualizar a UI
  }

  // Atualiza um orçamento existente
  Future<void> updateBudget(BudgetModel budget) async {
    await _budgetBox.put(budget.id, budget); // Atualiza usando o ID existente
    print(
      'DEBUG: BudgetViewModel - Orçamento atualizado (ID: ${budget.id}): ${budget.name}',
    );
    _loadBudgets(); // Recarrega a lista
  }

  // Deleta um orçamento pelo ID
  Future<void> deleteBudget(String id) async {
    await _budgetBox.delete(id);
    print('DEBUG: BudgetViewModel - Orçamento deletado (ID: $id)');
    _loadBudgets(); // Recarrega a lista
  }

  // Obtém um orçamento pelo ID
  BudgetModel? getBudgetById(String id) {
    return _budgets.firstWhere(
      (budget) => budget.id == id,
      orElse: () => throw Exception('Budget not found'),
    );
    // Ou para evitar o throw:
    // return _budgets.firstWhereOrNull((budget) => budget.id == id);
  }

  // Método para calcular o valor gasto em um orçamento específico
  // Este método precisará da lista de transações e da categoria associada
  // (será aprimorado em um passo futuro com o TransactionViewModel)
  double calculateSpentAmountForBudget(
    BudgetModel budget,
    List<TransactionModel> allTransactions,
  ) {
    double spent = 0.0;
    for (var transaction in allTransactions) {
      // Verifica se a transação pertence à categoria do orçamento
      // e está dentro do período do orçamento, e se é uma despesa.
      if (transaction.categoryId == budget.categoryId &&
          !transaction.date.isBefore(budget.startDate) &&
          !transaction.date.isAfter(budget.endDate) &&
          transaction.type == TransactionType.expense) {
        spent += transaction.amount;
      }
    }
    return spent;
  }
}
