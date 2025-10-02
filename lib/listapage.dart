import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

bool carregouArgumentos = false;

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

  List<Map<String, dynamic>> itens = [];
  double total = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!carregouArgumentos) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is List<Map<String, dynamic>>) {
        for (var item in args) {
          itens.add({
            "produto": item['produto'],
            "marca": '',
            "valor": 0.0,
            "quantidade": item['quantidade'],
          });
        }
      }
      carregouArgumentos = true;
    }
  }

  void adicionarItem() {
    final produto = produtoCtrl.text.trim();
    final marca = marcaCtrl.text.trim();
    final valorTexto = valorCtrl.text.replaceAll(',', '.');
    final valor = double.tryParse(valorTexto) ?? 0;
    final quantidade = int.tryParse(quantidadeCtrl.text) ?? 1;

    if (produto.isEmpty || valor <= 0) return;

    setState(() {
      itens.add({
        "produto": produto,
        "marca": marca,
        "valor": valor,
        "quantidade": quantidade,
      });
      total += valor * quantidade;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item "$produto" adicionado')),
    );

    produtoCtrl.clear();
    marcaCtrl.clear();
    valorCtrl.clear();
    quantidadeCtrl.clear();
  }

  void removerItem(int index) {
    final item = itens[index];
    setState(() {
      total -= item['valor'] * item['quantidade'];
      itens.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item "${item['produto']}" removido')),
    );
  }

  void editarItem(int index) {
    final item = itens[index];

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
            TextField(
              controller: produtoCtrl,
              decoration: campoEstilizado('Produto', Icons.shopping_cart),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: marcaCtrl,
              decoration:
                  campoEstilizado('Marca (opcional)', Icons.local_offer),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: valorCtrl,
              decoration: campoEstilizado('Valor', Icons.attach_money),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: quantidadeCtrl,
              decoration: campoEstilizado('Quantidade', Icons.numbers),
              keyboardType: TextInputType.number,
            ),
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

              if (novoProduto.isEmpty || novoValor <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Preencha os campos obrigatórios corretamente')),
                );
                return;
              }

              setState(() {
                total -= item['valor'] * item['quantidade'];
                itens[index] = {
                  "produto": novoProduto,
                  "marca": novaMarca,
                  "valor": novoValor,
                  "quantidade": novaQtd,
                };
                total += novoValor * novaQtd;
              });

              Navigator.pop(context);
              produtoCtrl.clear();
              marcaCtrl.clear();
              valorCtrl.clear();
              quantidadeCtrl.clear();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  InputDecoration campoEstilizado(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: 'Digite $label...',
      prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
          ),
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }

  Future<void> salvarListaNoHistorico() async {
    final prefs = await SharedPreferences.getInstance();

    final listaCompleta = {
      "mercado": mercadoCtrl.text,
      "itens": itens,
      "total": total,
      "data": DateTime.now().toIso8601String(),
    };

    final listasJson = prefs.getStringList('listas_salvas') ?? [];
    listasJson.add(jsonEncode(listaCompleta));
    await prefs.setStringList('listas_salvas', listasJson);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lista salva no histórico')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('Modo Comprando')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: mercadoCtrl,
              decoration: campoEstilizado('Supermercado', Icons.store),
              style: textStyle,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: produtoCtrl,
                    decoration: campoEstilizado('Produto', Icons.shopping_cart),
                    style: textStyle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: marcaCtrl,
                    decoration:
                        campoEstilizado('Marca (opcional)', Icons.local_offer),
                    style: textStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: valorCtrl,
                    decoration: campoEstilizado('Valor', Icons.attach_money),
                    keyboardType: TextInputType.number,
                    style: textStyle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: quantidadeCtrl,
                    decoration: campoEstilizado('Quantidade', Icons.numbers),
                    keyboardType: TextInputType.number,
                    style: textStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('Ver Histórico'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/historico');
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                  onPressed: adicionarItem,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 30, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_money,
                    color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 6),
                Text(
                  "Total: R\$ ${total.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Salvar no Histórico'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: itens.isEmpty ? null : salvarListaNoHistorico,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: itens.length,
                itemBuilder: (context, index) {
                  final item = itens[index];
                  return Card(
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(Icons.shopping_bag,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(
                        "${item['produto']} (${item['quantidade']}x) - ${item['marca']}",
                        style: textStyle,
                      ),
                      subtitle: Text(
                        "R\$ ${(item['valor'] * item['quantidade']).toStringAsFixed(2)}",
                        style: textStyle,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: Theme.of(context).colorScheme.secondary),
                            onPressed: () => editarItem(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removerItem(index),
                          ),
                        ],
                      ),
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
