import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../pages/register_page.dart';

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
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    t.isIncome ? Colors.green[100] : Colors.red[100],
                child: Icon(
                  t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: t.isIncome ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                t.description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${t.date.day}/${t.date.month}/${t.date.year}'),
              trailing: Text(
                'R\$ ${t.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: t.isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onLongPress: () => viewModel.deleteTransaction(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
