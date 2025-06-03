// lib/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/app_theme_mode.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = 'Carregando...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Consumer<SettingsViewModel>(
        // <--- Consumer envolve o corpo principal
        builder: (context, settingsViewModel, child) {
          // <--- settingsViewModel e child estão disponíveis aqui
          // Determina o valor do Switch com base no tema atual do ViewModel
          bool isDarkModeSelected;
          if (settingsViewModel.currentThemeMode == AppThemeMode.dark) {
            isDarkModeSelected = true;
          } else if (settingsViewModel.currentThemeMode == AppThemeMode.light) {
            isDarkModeSelected = false;
          } else {
            // Se for AppThemeMode.system, o switch reflete o brilho atual do sistema
            isDarkModeSelected =
                Theme.of(context).brightness == Brightness.dark;
          }

          return ListView(
            // <--- O ListView AGORA ESTÁ DENTRO DO BUILDER DO CONSUMER
            children: <Widget>[
              // Seção CONTA
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Conta e Sincronização',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Fazer login / Criar conta'),
                subtitle: const Text(
                  'Acesse seus dados de qualquer dispositivo',
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login/Cadastro em desenvolvimento'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                subtitle: const Text('Desconectar sua conta'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Funcionalidade de sair em desenvolvimento',
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              // Seção GERAL
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Geral',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Tema do aplicativo'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      settingsViewModel.currentThemeMode == AppThemeMode.light
                          ? 'Claro'
                          : settingsViewModel.currentThemeMode ==
                              AppThemeMode.dark
                          ? 'Escuro'
                          : 'Sistema',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Switch(
                      value: isDarkModeSelected,
                      onChanged: (bool value) {
                        if (settingsViewModel.currentThemeMode ==
                            AppThemeMode.system) {
                          settingsViewModel.setThemeMode(
                            value ? AppThemeMode.dark : AppThemeMode.light,
                          );
                        } else {
                          settingsViewModel.setThemeMode(
                            value ? AppThemeMode.dark : AppThemeMode.light,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Idioma'),
                subtitle: const Text('Português ( Brasil )'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Seleção de idioma em desenvolvimento'),
                    ),
                  );
                },
              ),
              const Divider(),

              // Seção DADOS E BACKUP
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Dados e Backup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Realizar backup'),
                subtitle: const Text(
                  'Salvar seus dados localmente ou em nuvem',
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Função de backup em desenvolvimento'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Restaurar backup'),
                subtitle: const Text('Carregar dados de um backup anterior'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Função de restauração em desenvolvimento'),
                    ),
                  );
                },
              ),
              const Divider(),

              // Seção SOBRE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Sobre',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Versão do Aplicativo'),
                trailing: Text(_appVersion),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Zen Grana',
                    applicationVersion: _appVersion,
                    applicationLegalese:
                        '© 2025 Mateus Scandolera. Todos os direitos reservados.',
                    children: const <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Text('Seu controle financeiro descomplicado.'),
                      ),
                    ],
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Politica de Privacidade'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Política de Privacidade em breve.'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Termos de Serviço'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Termos de Serviço em breve.'),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
