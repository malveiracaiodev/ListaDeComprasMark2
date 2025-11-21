import 'package:flutter/material.dart';
import 'pagina_base.dart';
import 'listapage.dart';
import 'historicopage.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _abrirSite() async {
    final Uri url = Uri.parse("https://malveiracaiodev.github.io/index.html");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Não foi possível abrir o site");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaginaBase(
      titulo: "Menu Principal",
      conteudo: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Conteúdo principal
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Bem-vindo à sua organização de compras 🛒',
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          style: estiloBotao(),
                          icon: const Icon(Icons.list, color: Colors.cyan),
                          label: const Text('Lista de Compras'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ListaPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: estiloBotao(),
                          icon: const Icon(Icons.history, color: Colors.cyan),
                          label: const Text('Últimas Compras'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HistoricoPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: estiloBotao(),
                          icon: const Icon(Icons.web, color: Colors.cyan),
                          label: const Text('Meu Site'),
                          onPressed: _abrirSite,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Logotipo fixo na parte de baixo
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    'assets/meu_logotipo.png',
                    height: 100,
                    fit: BoxFit.contain,
                    semanticLabel: 'Logotipo do aplicativo',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
