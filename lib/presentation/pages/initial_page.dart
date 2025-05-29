import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import 'transaction_page.dart';
import '../pages/goals_page.dart';
import '../pages/budget_page.dart';
import '../pages/category_register_page.dart';
import '../pages/config_page.dart';

class InitialPage extends StatefulWidget {
  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    // Estas variáveis podem ser movidas ou removidas se não forem mais usadas diretamente na tela principal
    // final viewModel = Provider.of<TransactionViewModel>(context);
    // final all = viewModel.transactions;

    return Scaffold(
      body: SingleChildScrollView(
        // Scroll vertical principal da página
        child: Column(
          children: [
            // --- HEADER PERSONALIZADO (RETO, SEM ONDAS) ---
            Container(
              height: 200,
              color: Colors.blue.shade900,
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
                        color: Colors.blue,
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
                    // <--- ENVOLVA O SingleChildScrollView em um SizedBox para limitar a altura
                    height:
                        120, // Altura que sua linha de cards ocupará.
                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal, // <--- SCROLL HORIZONTAL
                      child: Row(
                        // <--- USAMOS UMA ROW AGORA
                        children: [
                          // Card para Cadastrar Metas
                          _buildCircularCard(
                            context,
                            icon: Icons.track_changes,
                            label: 'Metas',
                            color: Colors.orange.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => GoalsPage()),
                              );
                            },
                          ),
                          const SizedBox(
                            width: 16,
                          ), // Espaçamento entre os cards
                          // Card para Cadastrar Orçamento
                          _buildCircularCard(
                            context,
                            icon: Icons.pie_chart,
                            label: 'Orçamento',
                            color: Colors.green.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => BudgetPage()),
                              );
                            },
                          ),
                          const SizedBox(
                            width: 16,
                          ), // Espaçamento entre os cards
                          // Card para Cadastrar Transação
                          _buildCircularCard(
                            context,
                            icon: Icons.receipt_long,
                            label: 'Transação',
                            color: Colors.red.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegisterPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            width: 16,
                          ), // Espaçamento entre os cards
                          // Card para Cadastrar Categoria
                          _buildCircularCard(
                            context,
                            icon: Icons.category,
                            label: 'Categorias',
                            color: Colors.purple.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryRegisterPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            width: 16,
                          ), // Espaçamento final, se houver mais cards
                          // Card de configuração
                          _buildCircularCard(
                            context,
                            icon: Icons.settings,
                            label: 'Configurações',
                            color: Colors.grey.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ConfigPage(),
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
            // --- OUTRO CONTEÚDO DA PÁGINA INICIAL AQUI ---
            // Adicionar mais widgets aqui, como gráficos, resumos, etc.
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
            child: Icon(
              icon,
              size: 35,
              color: color,
            ),
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
}
