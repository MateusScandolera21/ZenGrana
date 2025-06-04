// lib/features/transaction/presentation/viewmodels/transaction_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/budget_model.dart';
import '../../../../core/services/recent_activity_service.dart'; // NOVO: Importe o serviço de atividades recentes
import 'package:collection/collection.dart'; // Para firstWhereOrNull, se não tiver

class TransactionViewModel extends ChangeNotifier {
  late Box<TransactionModel> _transactionBox; // Declarada como late
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];

  final RecentActivityService _activityService =
      RecentActivityService(); // Instância do serviço

  // Future para controlar a inicialização da Box
  Future<void>? _initFuture;

  TransactionViewModel() {
    print('DEBUG: TransactionViewModel - Construtor chamado.');
    _initFuture = _init(); // Inicia a inicialização e armazena o Future
  }

  List<TransactionModel> get filteredTransactions => _filteredTransactions;
  List<TransactionModel> get allTransactions => _allTransactions;

  Future<void> _init() async {
    print('DEBUG: TransactionViewModel - _init() iniciado.');
    try {
      _transactionBox = await Hive.openBox<TransactionModel>('transactions');
      print('DEBUG: TransactionViewModel - Box "transactions" aberta.');

      // Adicionar o listener AQUI, depois que a box for inicializada
      _transactionBox.listenable().addListener(_loadTransactions);

      _loadTransactions(); // Carrega as transações inicialmente
      print(
        'DEBUG: TransactionViewModel - Transações carregadas inicialmente.',
      );
    } catch (e) {
      print('ERRO: TransactionViewModel - Falha no _init(): $e');
    }
  }

  void _loadTransactions() {
    _allTransactions = _transactionBox.values.toList();
    _filteredTransactions = List.from(
      _allTransactions,
    ); // Re-aplica filtros se houver
    print(
      'DEBUG: _loadTransactions chamado. Transações: ${_allTransactions.length}',
    );
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _initFuture; // Garante que a box esteja pronta
    await _transactionBox.put(transaction.id, transaction);
    print(
      'DEBUG: Transação adicionada (ID: ${transaction.id}): ${transaction.description}',
    );
    // Registra a atividade
    _activityService.addActivity(
      type: 'Transação',
      description:
          'Nova ${transaction.type == TransactionType.income ? 'entrada' : 'saída'}: ${transaction.description} de R\$${transaction.amount.toStringAsFixed(2)}',
    );
    // _loadTransactions será chamado pelo listener da box
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _initFuture; // Garante que a box esteja pronta
    await _transactionBox.put(transaction.id, transaction);
    print(
      'DEBUG: Transação atualizada (ID: ${transaction.id}): ${transaction.description}',
    );
    // Registra a atividade
    _activityService.addActivity(
      type: 'Transação',
      description:
          'Transação atualizada: ${transaction.description} de R\$${transaction.amount.toStringAsFixed(2)}',
    );
    // _loadTransactions será chamado pelo listener da box
  }

  Future<void> deleteTransaction(String id) async {
    await _initFuture; // Garante que a box esteja pronta
    final transactionToDelete = _transactionBox.get(
      id,
    ); // Pega a transação antes de deletar
    await _transactionBox.delete(id);
    print('DEBUG: Transação deletada (ID: $id)');
    if (transactionToDelete != null) {
      _activityService.addActivity(
        type: 'Transação',
        description: 'Transação excluída: ${transactionToDelete.description}',
      );
    }
    // _loadTransactions será chamado pelo listener da box
  }

  void applyFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    TransactionType? type,
  }) {
    List<TransactionModel> currentFiltered = List.from(_allTransactions);

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

    if (categoryId != null && categoryId.isNotEmpty) {
      currentFiltered =
          currentFiltered.where((transaction) {
            return transaction.categoryId == categoryId;
          }).toList();
    }

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

  // Métodos de filtro individuais agora chamam o método unificado
  void applyDateFilter(DateTime? startDate, DateTime? endDate) {
    applyFilters(startDate: startDate, endDate: endDate);
  }

  void applyCategoryFilter(String? categoryId) {
    applyFilters(categoryId: categoryId);
  }

  // Você pode adicionar um método para aplicar filtro por tipo se quiser um controle mais granular na UI
  void applyTypeFilter(TransactionType? type) {
    applyFilters(type: type);
  }

  double getTotalBalance() {
    return _filteredTransactions.fold(0.0, (sum, transaction) {
      if (transaction.type == TransactionType.income) {
        return sum + transaction.amount;
      } else {
        return sum - transaction.amount;
      }
    });
  }

  double calculateSpentAmountForBudget(
    BudgetModel budget,
    List<CategoryModel> allCategories,
  ) {
    double spent = 0.0;
    for (var transaction in _allTransactions) {
      // Usa _allTransactions para o cálculo completo
      final bool isCategoryMatch =
          budget.categoryId.isEmpty ||
          transaction.categoryId == budget.categoryId;

      if (transaction.type == TransactionType.expense &&
          isCategoryMatch &&
          !transaction.date.isBefore(
            DateTime(
              budget.startDate.year,
              budget.startDate.month,
              budget.startDate.day,
            ),
          ) &&
          !transaction.date.isAfter(
            DateTime(
              budget.endDate.year,
              budget.endDate.month,
              budget.endDate.day,
            ).add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
          )) {
        spent += transaction.amount;
      }
    }
    return spent;
  }

  @override
  void dispose() {
    print('DEBUG: TransactionViewModel - dispose() chamado.');
    // Só remova o listener se _transactionBox foi realmente inicializada
    if (_transactionBox.isOpen) {
      _transactionBox.listenable().removeListener(_loadTransactions);
    }
    super.dispose();
  }
}
