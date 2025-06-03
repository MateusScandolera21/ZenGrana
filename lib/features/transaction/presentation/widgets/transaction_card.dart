// lib/presentation/widgets/transaction_card.dart
import 'package:flutter/material.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/category_model.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;

  const TransactionCard({Key? key, required this.transaction, this.category})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    category != null
                        ? Color(category!.iconColorValue).withOpacity(0.15)
                        : Colors.grey.shade100,
              ),
              child: Icon(
                category != null
                    ? IconData(
                      category!.iconCodePoint,
                      fontFamily: 'MaterialIcons',
                    )
                    : Icons.category,
                color:
                    category != null
                        ? Color(category!.iconColorValue)
                        : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? 'Sem Categoria',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    transaction.description,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.type == TransactionType.expense
                      ? '- R\$ ${transaction.amount.toStringAsFixed(2)}'
                      : '+ R\$ ${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color:
                        transaction.type == TransactionType.expense
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(transaction.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
