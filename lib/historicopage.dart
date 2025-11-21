import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'listapage.dart';
import 'listaprovider.dart';
import 'package:provider/provider.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  List<Map<String, dynamic>> historico = [];

  @override
  void initState() {
    super.initState();
    carregarHistorico();
  }

  Future<void> carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final listasJson = prefs.getStringList('listas_salvas') ?? [];
    final listasDecodificadas = listasJson
        .map((s) {
          try {
            return jsonDecode(s) as Map<String, dynamic>;
          } catch (_) {
            return <String, dynamic>{};
          }
        })
        .where((m) => m.isNotEmpty)
        .toList();

    setState(() {
      historico = List<Map<String, dynamic>>.from(listasDecodificadas);
    });
  }

  Future<void> excluirLista(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final listasJson = prefs.getStringList('listas_salvas') ?? [];

    if (index >= 0 && index < listasJson.length) {
      listasJson.removeAt(index);
      await prefs.setStringList('listas_salvas', listasJson);
      setState(() {
        historico.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista excluída com sucesso')),
      );
    }
  }

  void reabrirLista(Map<String, dynamic> listaOriginal, int index) {
    // Usa push com MaterialPageRoute e envia argumentos via settings
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const ListaPage(),
        settings:
            RouteSettings(arguments: {'lista': listaOriginal, 'index': index}),
      ),
    ).then((returned) {
      // Se o usuário salvou/atualizou a lista, recarrega histórico
      carregarHistorico();
      // Se quiser também atualizar provider com a lista reaberta:
      if (returned != null && returned is Map<String, dynamic>) {
        final provider = Provider.of<ListaProvider>(context, listen: false);
        provider.listaComprando =
            List<Map<String, dynamic>>.from(returned['itens'] ?? []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Listas')),
      body: historico.isEmpty
          ? Center(child: Text('Nenhuma lista salva', style: bodyStyle))
          : ListView.builder(
              itemCount: historico.length,
              itemBuilder: (context, index) {
                final lista = historico[index];
                final itens = (lista['itens'] as List?) ?? [];
                final total = (lista['total'] as num?)?.toDouble() ??
                    itens.fold<double>(
                        0,
                        (sum, it) =>
                            sum +
                            ((it['valor'] as num? ?? 0) *
                                    (it['quantidade'] as num? ?? 1))
                                .toDouble());
                return Card(
                  color: Theme.of(context).cardColor,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lista['mercado'] ?? 'Supermercado',
                            style: titleStyle),
                        const SizedBox(height: 4),
                        Text("Total: R\$ ${total.toStringAsFixed(2)}",
                            style: bodyStyle),
                        if (lista['data'] != null)
                          Text(
                            "Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(lista['data']))}",
                            style: bodyStyle,
                          ),
                        const SizedBox(height: 8),
                        Text("Itens:",
                            style: bodyStyle?.copyWith(
                                fontWeight: FontWeight.bold)),
                        ...itens.map<Widget>((item) {
                          final valorItem = ((item['valor'] as num? ?? 0) *
                                  (item['quantidade'] as num? ?? 1))
                              .toDouble();
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              "- ${item['produto']} (${item['quantidade']}x) ${item['marca'] ?? ''} - R\$ ${valorItem.toStringAsFixed(2)}",
                              style: bodyStyle,
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart),
                              tooltip: 'Reabrir lista',
                              onPressed: () => reabrirLista(lista, index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Excluir lista',
                              onPressed: () => excluirLista(index),
                            ),
                          ],
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
