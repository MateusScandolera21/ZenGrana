import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TransactionViewModel>(context);
    final transactions = viewModel.transactions;

    return Scaffold(
      appBar: AppBar(title: Text("Controle Financeiro")),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final t = transactions[index];
          return ListTile(
            title: Text(t.description),
            subtitle: Text(t.date.toString()),
            trailing: Text("R\$ ${t.amount.toStringAsFixed(2)}"),
            onLongPress: () => viewModel.deleteTransaction(index),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newTransaction = TransactionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            description: "Exemplo",
            amount: 100.0,
            date: DateTime.now(),
          );
          viewModel.addTransaction(newTransaction);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}