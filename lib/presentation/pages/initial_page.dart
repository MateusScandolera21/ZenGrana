import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar a data
import 'package:hive_flutter/hive_flutter.dart'; // Importe Hive para ValueListenableBuilder

import '../../features/goals/presentation/pages/goals_list_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/transaction/presentation/pages/transaction_list_page.dart';
import '../../features/category/presentation/pages/category_list_page.dart';
import '../../features/budget/presentation/pages/budget_list_page.dart';

// Importe o serviço e o modelo de atividades recentes
import '../../core/services/recent_activity_service.dart';
import '../../core/models/recent_activity.dart'; // Certifique-se de que o caminho está correto

class InitialPage extends StatefulWidget {
  const InitialPage({super.key}); // Adicionado const constructor key

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  // A instância do serviço de atividades recentes não é estritamente necessária
  // se você estiver acessando apenas os membros estáticos (boxName, maxActivities)
  // e métodos estáticos (init) da classe.
  // final RecentActivityService _activityService = RecentActivityService();

  @override
  void initState() {
    super.initState();
    // NOTA IMPORTANTE: RecentActivityService.init() DEVE ser chamado no main.dart
    // antes de runApp() para garantir que a box esteja aberta para todo o aplicativo.
    // Não precisamos inicializar ou abrir a box aqui novamente.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER PERSONALIZADO (RETO, SEM ONDAS) ---
            Container(
              height: 200,
              color: Colors.green.shade900,
              width: double.infinity,
              child: const Padding(
                padding: EdgeInsets.only(left: 24.0, bottom: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_outline,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Bem-vindo ao Zen Grana!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Seu controle financeiro descomplicado.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            // --- FIM DO HEADER PERSONALIZADO ---

            // --- SEÇÃO DE CARDS REDONDOS EM UMA LINHA COM SCROLL HORIZONTAL ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ações Rápidas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCircularCard(
                            context,
                            icon: Icons.track_changes,
                            label: 'Metas',
                            color: Colors.orange.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GoalsListPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildCircularCard(
                            context,
                            icon: Icons.pie_chart,
                            label: 'Orçamento',
                            color: Colors.green.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BudgetListPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildCircularCard(
                            context,
                            icon: Icons.receipt_long,
                            label: 'Transação',
                            color: Colors.red.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionListPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildCircularCard(
                            context,
                            icon: Icons.category,
                            label: 'Categorias',
                            color: Colors.purple.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryListPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildCircularCard(
                            context,
                            icon: Icons.settings,
                            label: 'Configurações',
                            color: Colors.grey.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SettingsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- SEÇÃO DE ÚLTIMAS MOVIMENTAÇÕES ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Últimas Movimentações',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Usando ValueListenableBuilder para reatividade com Hive
                  ValueListenableBuilder(
                    // Acessando a box com o nome público 'boxName'
                    valueListenable:
                        Hive.box<RecentActivity>(
                          RecentActivityService.boxName,
                        ).listenable(),
                    builder: (context, Box<RecentActivity> box, _) {
                      // Obter e ordenar as atividades mais recentes
                      final List<RecentActivity> activities =
                          box.values.toList()..sort(
                            (a, b) => b.timestamp.compareTo(a.timestamp),
                          );

                      // Usando o limite de atividades 'maxActivities' da classe RecentActivityService
                      final List<RecentActivity> recentActivitiesToShow =
                          activities
                              .take(RecentActivityService.maxActivities)
                              .toList();

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            recentActivitiesToShow.isEmpty
                                ? const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Center(
                                    child: Text(
                                      'Nenhuma movimentação recente ainda.\nComece a registrar suas finanças!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Evita scroll aninhado
                                  itemCount: recentActivitiesToShow.length,
                                  itemBuilder: (context, index) {
                                    final activity =
                                        recentActivitiesToShow[index];
                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: _getActivityIcon(
                                            activity.type,
                                          ),
                                          title: Text(activity.description),
                                          subtitle: Text(
                                            '${activity.type} - ${DateFormat('dd/MM/yyyy HH:mm').format(activity.timestamp)}',
                                          ),
                                          // Você pode adicionar um onTap para levar para a tela relevante
                                          // onTap: () { /* Navegar para a tela da movimentação */ },
                                        ),
                                        if (index <
                                            recentActivitiesToShow.length - 1)
                                          const Divider(
                                            height: 0,
                                            indent: 16,
                                            endIndent: 16,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Widget Auxiliar para Criar os Cards Redondos ---
  Widget _buildCircularCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, size: 35, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // --- Função Auxiliar para obter ícones de atividade ---
  Icon _getActivityIcon(String type) {
    switch (type) {
      case 'Meta':
        return const Icon(Icons.track_changes, color: Colors.orange);
      case 'Transação':
        return const Icon(Icons.receipt_long, color: Colors.red);
      case 'Categoria':
        return const Icon(Icons.category, color: Colors.purple);
      case 'Orçamento':
        return const Icon(Icons.pie_chart, color: Colors.green);
      default:
        return const Icon(Icons.info_outline, color: Colors.grey);
    }
  }
}
