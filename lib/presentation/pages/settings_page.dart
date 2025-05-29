import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  // Carrega versão do aplicativo
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Descomentar quando tiver o SettingsViewModel:
    // final settingsViewModel = Provider.of<SettingsViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: <Widget>[
          // Seção CONTA (para funcionalidades futuras de Login/Sincronização)
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
            subtitle: const Text('Acesse seus dados de qualquer dispositivo'),
            onTap: () {
              // TODO: Navegar para a tela de login/cadastro futuro
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
              // TODO: Implementar lógica de logout ( futuro )
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade de sair em desenvolvimento'),
                ),
              );
            },
          ),
          const Divider(), // Separador visual
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
            trailing: Switch(
              // Isso é um switch de exemplo; não vai mudar o tema ainda
              // O valor real viria do SettingsViewModel
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (bool value) {
                // TODO: Chamar método no SettingsViewModel para mudar o tema ( futuro )
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Mudar tema para ${value ? "Escuro" : "Claro"} ( Em breve )!',
                    ),
                  ),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: const Text('Português ( Brasil )'), // Valor de exemplo
            onTap: () {
              // TODO: Navegar para a tela de seleção de idioma ( futuro, beeeeeeem futuro )
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Seleção de idioma em desenvolvimento')),
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
            subtitle: const Text('Salvar seus dados localmente ou em nuvem'),
            onTap: () {
              // TODO: Implementar função de backup ( futuro )
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
              // TODO: Implementar função de restauração ( futuro )
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
              // Exibir um simples AboutDialog ou navegar para uma página "Sobre" mais completa
              showAboutDialog(
                context: context,
                applicationName: 'Zen Grana',
                applicationVersion: _appVersion,
                applicationLegalese:
                    '© 2025 Mateus Scandolera. Todos os direitos reservados.',
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: const Text('Seu controle financeiro descomplicado.'),
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Politica de Privacidade'),
            onTap: () {
              // TODO: Abrir URL da política de privacidade (ex: usando url_launcher)
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
              // TODO: Abrir URL dos termos de serviço (ex: usando url_launcher)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Termos de Serviço em breve.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
