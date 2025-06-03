// lib/src/modules/goals/presenter/pages/goals_list_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'goals_page.dart'; // Sua tela de cadastro/edição de metas
// Importe o CustomScaffold
import '../../../../core/shared/widgets/custom_scaffold.dart'; // Ajuste o caminho conforme sua estrutura de pastas

class GoalsListPage extends StatefulWidget {
  const GoalsListPage({super.key});

  @override
  State<GoalsListPage> createState() => _GoalsListPageState();
}

class _GoalsListPageState extends State<GoalsListPage> {
  final List<Map<String, dynamic>> _goals = [];
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Função para navegar para a tela de adicionar/editar e lidar com o resultado
  void _navigateToAddEditGoal({Map<String, dynamic>? goalToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => GoalsPage(goal: goalToEdit), // Passa a meta se for edição
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final existingIndex = _goals.indexWhere((g) => g['id'] == result['id']);
        if (existingIndex != -1) {
          // Edição: Substitui a meta existente
          _goals[existingIndex] = result;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meta atualizada com sucesso!')),
          );
        } else {
          // Adição: Adiciona a nova meta
          _goals.add(result);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meta adicionada com sucesso!')),
          );
        }
      });
    }
  }

  // Função para confirmar e excluir uma meta
  void _confirmAndDeleteGoal(int index, String goalName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir a meta "$goalName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _goals.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Meta "$goalName" excluída com sucesso!'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Minhas Metas',
      // Aqui você pode decidir onde quer o botão de adicionar:
      // Opção 1: Como um IconButton na AppBar (como você já tem)
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed:
              () => _navigateToAddEditGoal(), // Chama a função para adicionar
          tooltip: 'Adicionar nova meta',
        ),
      ],
      // Opção 2: Como um FloatingActionButton (se preferir)
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _navigateToAddEditGoal(), // Chama a função para adicionar
      //   tooltip: 'Adicionar nova meta',
      //   child: const Icon(Icons.add),
      // ),
      body:
          _goals.isEmpty
              ? const Center(
                child: Text(
                  'Nenhuma meta cadastrada ainda.\nToque no "+" para adicionar uma nova!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  double progress =
                      goal['currentAmount'] / goal['targetAmount'];
                  if (progress > 1.0) progress = 1.0;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal['name'],
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Meta: R\$ ${goal['targetAmount'].toStringAsFixed(2)}',
                          ),
                          Text(
                            'Atual: R\$ ${goal['currentAmount'].toStringAsFixed(2)}',
                          ),
                          Text(
                            'Faltam: R\$ ${(goal['targetAmount'] - goal['currentAmount']).toStringAsFixed(2)}',
                          ),
                          Text(
                            'Vencimento: ${_dateFormat.format(goal['dueDate'])}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            color:
                                goal['isCompleted']
                                    ? Colors.green
                                    : Theme.of(context).primaryColor,
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}% Completo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  goal['isCompleted']
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color:
                                      goal['isCompleted'] ? Colors.green : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    goal['isCompleted'] = !goal['isCompleted'];
                                    if (goal['isCompleted']) {
                                      goal['currentAmount'] =
                                          goal['targetAmount'];
                                      goal['completionDate'] = DateTime.now();
                                    } else {
                                      goal['completionDate'] = null;
                                    }
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        goal['isCompleted']
                                            ? 'Meta "${goal['name']}" marcada como concluída!'
                                            : 'Meta "${goal['name']}" desmarcada como concluída!',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed:
                                    () => _navigateToAddEditGoal(
                                      goalToEdit: goal,
                                    ), // Chama a função para editar
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed:
                                    () => _confirmAndDeleteGoal(
                                      index,
                                      goal['name'],
                                    ),
                              ),
                            ],
                          ),
                          if (goal['isCompleted'] &&
                              goal['completionDate'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Concluída em: ${_dateFormat.format(goal['completionDate'])}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
