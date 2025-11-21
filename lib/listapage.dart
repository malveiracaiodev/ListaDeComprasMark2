import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lista_de_compras/listaprovider.dart';

class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  final TextEditingController mercadoCtrl = TextEditingController();
  final TextEditingController produtoCtrl = TextEditingController();
  final TextEditingController marcaCtrl = TextEditingController();
  final TextEditingController quantidadeCtrl = TextEditingController();
  final TextEditingController valorCtrl = TextEditingController();

  int? indexEdicao;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final lista = args['lista'] as Map<String, dynamic>?;
      final index = args['index'] as int?;
      if (lista != null) {
        mercadoCtrl.text = lista['mercado'] ?? '';
        Provider.of<ListaProvider>(context, listen: false).listaComprando =
            List<Map<String, dynamic>>.from(lista['itens']);
        indexEdicao = index;
      }
    }
  }

  void adicionarItem() {
    final produto = produtoCtrl.text.trim();
    final marca = marcaCtrl.text.trim();
    final valorTexto = valorCtrl.text.replaceAll(',', '.');
    final valor = double.tryParse(valorTexto) ?? 0;
    final quantidade = int.tryParse(quantidadeCtrl.text) ?? 1;

    if (produto.isEmpty || valor <= 0 || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos corretamente')),
      );
      return;
    }

    final provider = Provider.of<ListaProvider>(context, listen: false);
    setState(() {
      provider.adicionarItem({
        "produto": produto,
        "marca": marca,
        "valor": valor,
        "quantidade": quantidade,
      });
    });

    produtoCtrl.clear();
    marcaCtrl.clear();
    valorCtrl.clear();
    quantidadeCtrl.clear();
  }

  void removerItem(int index) {
    final provider = Provider.of<ListaProvider>(context, listen: false);
    setState(() {
      provider.removerItem(index);
    });
  }

  void editarItem(int index) {
    final provider = Provider.of<ListaProvider>(context, listen: false);
    final item = provider.listaComprando[index];

    produtoCtrl.text = item['produto'];
    marcaCtrl.text = item['marca'];
    valorCtrl.text = item['valor'].toString();
    quantidadeCtrl.text = item['quantidade'].toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            campoTexto(produtoCtrl, 'Produto', Icons.shopping_cart),
            campoTexto(marcaCtrl, 'Marca (opcional)', Icons.local_offer),
            campoTexto(valorCtrl, 'Valor', Icons.attach_money,
                tipo: TextInputType.number),
            campoTexto(quantidadeCtrl, 'Quantidade', Icons.numbers,
                tipo: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final novoProduto = produtoCtrl.text.trim();
              final novaMarca = marcaCtrl.text.trim();
              final novoValor =
                  double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0;
              final novaQtd = int.tryParse(quantidadeCtrl.text) ?? 1;

              if (novoProduto.isEmpty || novoValor <= 0 || novaQtd <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Preencha os campos corretamente')),
                );
                return;
              }

              setState(() {
                provider.editarItem(index, {
                  "produto": novoProduto,
                  "marca": novaMarca,
                  "valor": novoValor,
                  "quantidade": novaQtd,
                });
              });

              produtoCtrl.clear();
              marcaCtrl.clear();
              valorCtrl.clear();
              quantidadeCtrl.clear();
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void salvarListaNoHistorico() async {
    final provider = Provider.of<ListaProvider>(context, listen: false);
    final listaCompleta = {
      "mercado": mercadoCtrl.text,
      "itens": provider.listaComprando,
      "total": provider.listaComprando.fold<double>(
        0,
        (sum, item) => sum + item['valor'] * item['quantidade'],
      ),
      "data": DateTime.now().toIso8601String(),
    };

    final jsonLista = jsonEncode(listaCompleta);
    final prefs = await SharedPreferences.getInstance();
    final listasJson = prefs.getStringList('listas_salvas') ?? [];

    if (indexEdicao != null &&
        indexEdicao! >= 0 &&
        indexEdicao! < listasJson.length) {
      listasJson[indexEdicao!] = jsonLista;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista atualizada no histórico')),
      );
    } else {
      listasJson.add(jsonLista);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista salva no histórico')),
      );
    }

    await prefs.setStringList('listas_salvas', listasJson);
    Navigator.pop(context, listaCompleta);
  }

  InputDecoration campoEstilizado(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget campoTexto(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? tipo}) {
    return TextField(
      controller: controller,
      decoration: campoEstilizado(label, icon),
      keyboardType: tipo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ListaProvider>(context);
    final total = provider.listaComprando.fold<double>(
      0,
      (sum, item) => sum + item['valor'] * item['quantidade'],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Modo Comprando')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            campoTexto(mercadoCtrl, 'Supermercado', Icons.store),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: campoTexto(
                        produtoCtrl, 'Produto', Icons.shopping_cart)),
                const SizedBox(width: 8),
                Expanded(
                    child: campoTexto(marcaCtrl, 'Marca', Icons.local_offer)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: campoTexto(valorCtrl, 'Valor', Icons.attach_money,
                        tipo: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(
                    child: campoTexto(
                        quantidadeCtrl, 'Quantidade', Icons.numbers,
                        tipo: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('Ver Histórico'),
                  onPressed: () => Navigator.pushNamed(context, '/historico'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                  onPressed: adicionarItem,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("Total: R\$ ${total.toStringAsFixed(2)}"),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Salvar no Histórico'),
              onPressed: provider.listaComprando.isEmpty
                  ? null
                  : salvarListaNoHistorico,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: provider.listaComprando.length,
                itemBuilder: (context, index) {
                  final item = provider.listaComprando[index];
                  final valorTotalItem = item['valor'] * item['quantidade'];
                  return ListTile(
                    title: Text(
                        "${item['produto']} (${item['quantidade']}x) - ${item['marca']}"),
                    subtitle: Text("R\$ ${valorTotalItem.toStringAsFixed(2)}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editarItem(index)),
                        IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removerItem(index)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
