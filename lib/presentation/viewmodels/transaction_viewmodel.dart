import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/transaction_model.dart';

class TransactionViewModel extends ChangeNotifier {
  late Box<TransactionModel> _box;

  TransactionViewModel() {
    _box = Hive.box<TransactionModel>('transactions');
  }

  List<TransactionModel> get transactions => _box.values.toList();

  void addTransaction(TransactionModel transaction) async {
    await _box.add(transaction);
    notifyListeners();
  }

  void deleteTransaction(int index) async {
    await _box.deleteAt(index);
    notifyListeners();
  }
}
