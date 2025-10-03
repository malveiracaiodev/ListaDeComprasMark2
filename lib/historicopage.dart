import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

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

  void carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final listasJson = prefs.getStringList('listas_salvas') ?? [];

    final listasDecodificadas =
        listasJson.map((json) => jsonDecode(json)).toList();

    setState(() {
      historico = List<Map<String, dynamic>>.from(listasDecodificadas);
    });
  }

  void excluirLista(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final listasJson = prefs.getStringList('listas_salvas') ?? [];

    listasJson.removeAt(index);
    await prefs.setStringList('listas_salvas', listasJson);

    setState(() {
      historico.removeAt(index);
    });
  }

  void editarLista(Map<String, dynamic> listaOriginal, int index) async {
    final resultado = await Navigator.pushNamed(
      context,
      '/lista',
      arguments: {
        'lista': listaOriginal,
        'index': index,
      },
    );

    if (resultado != null && resultado is Map<String, dynamic>) {
      final prefs = await SharedPreferences.getInstance();
      final listasJson = prefs.getStringList('listas_salvas') ?? [];

      listasJson[index] = jsonEncode(resultado);
      await prefs.setStringList('listas_salvas', listasJson);

      setState(() {
        historico[index] = resultado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Listas')),
      body: historico.isEmpty
          ? Center(
              child: Text(
                'Nenhuma lista salva',
                style: bodyStyle,
              ),
            )
          : ListView.builder(
              itemCount: historico.length,
              itemBuilder: (context, index) {
                final lista = historico[index];
                return Card(
                  color: Theme.of(context).cardColor,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => editarLista(lista, index),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lista['mercado'] ?? 'Supermercado',
                            style: titleStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Total: R\$ ${lista['total'].toStringAsFixed(2)}",
                            style: bodyStyle,
                          ),
                          if (lista['data'] != null)
                            Text(
                              "Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(lista['data']))}",
                              style: bodyStyle,
                            ),
                          const SizedBox(height: 8),
                          Text("Itens:",
                              style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.bold)),
                          ...List<Widget>.from(
                              (lista['itens'] as List).map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "- ${item['produto']} (${item['quantidade']}x) ${item['marca']} - R\$ ${(item['valor'] * item['quantidade']).toStringAsFixed(2)}",
                                style: bodyStyle,
                              ),
                            );
                          })),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => excluirLista(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
