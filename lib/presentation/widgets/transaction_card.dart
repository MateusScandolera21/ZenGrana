// lib/presentation/widgets/transaction_card.dart
import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart'; // Certifique-se de importar TransactionModel
import '../../data/models/category_model.dart'; // Certifique-se de importar CategoryModel
import 'package:intl/intl.dart'; // Para formatar a data

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel?
  category; // Recebe a categoria para pegar nome e ícone/cor

  const TransactionCard({Key? key, required this.transaction, this.category})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Adiciona bordas arredondadas
      elevation: 2, // Adiciona uma leve sombra
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Círculo com o ícone da categoria
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Correção: A cor de fundo do círculo deve vir do category!.iconColorValue
                color:
                    category != null
                        ? Color(category!.iconColorValue).withOpacity(
                          0.15,
                        ) // Um pouco mais opaco
                        : Colors.grey.shade100, // Cor padrão mais clara
              ),
              child: Icon(
                // Correção: Recria o IconData a partir do codePoint
                category != null
                    ? IconData(
                      category!.iconCodePoint,
                      fontFamily: 'MaterialIcons',
                    )
                    : Icons.category,
                // Correção: A cor do ícone deve vir do category!.iconColorValue
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
                    category?.name ?? 'Sem Categoria', // Nome da categoria
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    transaction.description, // Descrição da transação
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  // Correção: Usa transaction.type para verificar se é despesa ou entrada
                  transaction.type ==
                          TransactionType
                              .expense // Agora 'type' é o campo no TransactionModel
                      ? '- R\$ ${transaction.amount.toStringAsFixed(2)}'
                      : '+ R\$ ${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    // Correção: Cores baseadas no tipo de transação
                    color:
                        transaction.type == TransactionType.expense
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                  ),
                ),
                Text(
                  // Formata a data para dd/MM/yyyy
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
