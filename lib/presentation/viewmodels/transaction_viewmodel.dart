import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart'; // Opcional, se precisar de categorias aqui

class TransactionViewModel extends ChangeNotifier {
  List<TransactionModel> _allTransactions =
      []; // Todas as transações carregadas
  List<TransactionModel> _filteredTransactions =
      []; // Transações após a aplicação de filtros

  TransactionViewModel() {
    _loadTransactions();
  }

  List<TransactionModel> get filteredTransactions => _filteredTransactions;

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
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.put(
      transaction.id,
      transaction,
    ); // <--- Usando put com ID String como chave
    print(
      'DEBUG: Transação adicionada (ID: ${transaction.id}): ${transaction.description}',
    );
    await _loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    // Agora que usamos o ID (String) como chave no .put(), a atualização é mais simples
    await box.put(transaction.id, transaction);
    print(
      'DEBUG: Transação atualizada (ID: ${transaction.id}): ${transaction.description}',
    );
    await _loadTransactions();
  }

  // MUDANÇA AQUI: ID AGORA É STRING
  Future<void> deleteTransaction(String id) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.delete(id); // <--- Deleta diretamente pela chave (ID String)
    print('DEBUG: Transação deletada (ID: $id)');
    await _loadTransactions();
  }

  void applyDateFilter(DateTime? startDate, DateTime? endDate) {
    List<TransactionModel> tempFiltered = List.from(_allTransactions);

    if (startDate != null) {
      tempFiltered =
          tempFiltered.where((transaction) {
            final transactionDate = DateTime(
              transaction.date.year,
              transaction.date.month,
              transaction.date.day,
            );
            final startOfDay = DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
            );
            return transactionDate.isAtSameMomentAs(startOfDay) ||
                transactionDate.isAfter(startOfDay);
          }).toList();
    }

    if (endDate != null) {
      tempFiltered =
          tempFiltered.where((transaction) {
            final transactionDate = DateTime(
              transaction.date.year,
              transaction.date.month,
              transaction.date.day,
            );
            final endOfDay = DateTime(endDate.year, endDate.month, endDate.day);
            return transactionDate.isAtSameMomentAs(endOfDay) ||
                transactionDate.isBefore(endOfDay);
          }).toList();
    }

    _filteredTransactions = tempFiltered;
    print(
      'DEBUG: Filtro de data aplicado. Transações filtradas: ${_filteredTransactions.length}',
    );
    notifyListeners();
  }

  void applyCategoryFilter(int? categoryId) {
    if (categoryId == null) {
      _filteredTransactions = List.from(_allTransactions);
    } else {
      _filteredTransactions =
          _allTransactions.where((transaction) {
            return transaction.categoryId == categoryId;
          }).toList();
    }
    print(
      'DEBUG: Filtro de categoria aplicado (ID: $categoryId). Transações filtradas: ${_filteredTransactions.length}',
    );
    notifyListeners();
  }

  void applyFilters({DateTime? startDate, DateTime? endDate, int? categoryId}) {
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

    if (categoryId != null) {
      currentFiltered =
          currentFiltered.where((transaction) {
            return transaction.categoryId == categoryId;
          }).toList();
    }

    _filteredTransactions = currentFiltered;
    print(
      'DEBUG: Todos os filtros aplicados. Transações filtradas: ${_filteredTransactions.length}',
    );
    notifyListeners();
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
}
