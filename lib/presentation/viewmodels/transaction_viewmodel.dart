import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/transaction_model.dart';

class TransactionViewModel extends ChangeNotifier {
  final Box<TransactionModel> box = Hive.box<TransactionModel>('transactions');

  List<TransactionModel> get transactions => box.values.toList();

  void addTransaction(TransactionModel transaction) {
    box.add(transaction);
    notifyListeners();
  }

  void deleteTransaction(int index) {
    box.deleteAt(index);
    notifyListeners();
  }

}