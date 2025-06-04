// lib/src/modules/goals/presenter/pages/goals_list_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'goals_page.dart';
import '../../../../core/shared/widgets/custom_scaffold.dart';
import '../../../../core/services/recent_activity_service.dart';
import '../../../../data/models/goals_model.dart';

class GoalsListPage extends StatefulWidget {
  const GoalsListPage({super.key});

  @override
  State<GoalsListPage> createState() => _GoalsListPageState();
}

class _GoalsListPageState extends State<GoalsListPage> {
  List<GoalsModel> _goals = [];
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  late Box<GoalsModel> _goalsBox;
  bool _isLoading = true;

  // RE-ADICIONADO: Instância do serviço de atividades recentes
  final RecentActivityService _activityService = RecentActivityService();

  @override
  void initState() {
    super.initState();
    _initHiveAndLoadGoals();
  }

  Future<void> _initHiveAndLoadGoals() async {
    _goalsBox = await Hive.openBox<GoalsModel>('goals');
    _goals = _goalsBox.values.toList();

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToAddEditGoal({GoalsModel? goalToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GoalsPage(goal: goalToEdit)),
    );

    if (result != null && result is GoalsModel) {
      setState(() {
        final existingIndex = _goals.indexWhere((g) => g.id == result.id);
        if (existingIndex != -1) {
          result.save();
          _goals[existingIndex] = result;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meta atualizada com sucesso!')),
          );
          // CORRIGIDO: Chame na instância do serviço
          _activityService.addActivity(
            type: 'Meta',
            description: 'Meta "${result.name}" atualizada.',
          );
        } else {
          _goalsBox.put(result.id, result);
          _goals.add(result);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meta adicionada com sucesso!')),
          );
          // CORRIGIDO: Chame na instância do serviço
          _activityService.addActivity(
            type: 'Meta',
            description: 'Meta "${result.name}" adicionada.',
          );
        }
      });
    }
  }

  void _confirmAndDeleteGoal(String goalId, String goalName) {
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
              onPressed: () async {
                await _goalsBox.delete(goalId);
                setState(() {
                  _goals.removeWhere((goal) => goal.id == goalId);
                  // CORRIGIDO: Chame na instância do serviço
                  _activityService.addActivity(
                    type: 'Meta',
                    description: 'Meta "$goalName" excluída.',
                  );
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
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _navigateToAddEditGoal(),
          tooltip: 'Adicionar nova meta',
        ),
      ],
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ValueListenableBuilder(
                valueListenable: _goalsBox.listenable(),
                builder: (context, Box<GoalsModel> box, _) {
                  _goals = box.values.toList();

                  if (_goals.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma meta cadastrada ainda.\nToque no "+" para adicionar uma nova!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      double progress = goal.currentAmount / goal.targetAmount;
                      if (progress > 1.0) progress = 1.0;

                      final String dueDateFormatted = _dateFormat.format(
                        goal.dueDate,
                      );
                      final String? completionDateFormatted =
                          goal.completionDate != null
                              ? _dateFormat.format(goal.completionDate!)
                              : null;

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
                                goal.name,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Meta: R\$ ${goal.targetAmount.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Atual: R\$ ${goal.currentAmount.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Faltam: R\$ ${(goal.targetAmount - goal.currentAmount).toStringAsFixed(2)}',
                              ),
                              Text(
                                'Vencimento: $dueDateFormatted',
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
                                    goal.isCompleted
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
                                      goal.isCompleted
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color:
                                          goal.isCompleted
                                              ? Colors.green
                                              : null,
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        goal.isCompleted = !goal.isCompleted;
                                        if (goal.isCompleted) {
                                          goal.currentAmount =
                                              goal.targetAmount;
                                          goal.completionDate = DateTime.now();
                                        } else {
                                          goal.completionDate = null;
                                        }
                                      });
                                      await goal.save();

                                      // CORRIGIDO: Chame na instância do serviço
                                      _activityService.addActivity(
                                        type: 'Meta',
                                        description:
                                            goal.isCompleted
                                                ? 'Meta "${goal.name}" concluída!'
                                                : 'Meta "${goal.name}" desmarcada como concluída.',
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            goal.isCompleted
                                                ? 'Meta "${goal.name}" marcada como concluída!'
                                                : 'Meta "${goal.name}" desmarcada como concluída!',
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
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed:
                                        () => _confirmAndDeleteGoal(
                                          goal.id,
                                          goal.name,
                                        ),
                                  ),
                                ],
                              ),
                              if (goal.isCompleted &&
                                  completionDateFormatted != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Concluída em: $completionDateFormatted',
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
                  );
                },
              ),
    );
  }
}
