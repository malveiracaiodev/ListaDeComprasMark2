import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
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
      final provider = Provider.of<ListaProvider>(context, listen: false);
      final lista = args['lista'] as Map<String, dynamic>;
      indexEdicao = args['index'] as int?;

      mercadoCtrl.text = lista['mercado'] ?? '';
      provider.listaComprando = List<Map<String, dynamic>>.from(lista['itens']);
    }
  }

  void adicionarItem() {
    final produto = produtoCtrl.text.trim();
    final marca = marcaCtrl.text.trim();
    final valorTexto = valorCtrl.text.replaceAll(',', '.');
    final valor = double.tryParse(valorTexto) ?? 0;
    final quantidade = int.tryParse(quantidadeCtrl.text) ?? 1;

    if (produto.isEmpty || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Preencha os campos obrigatórios corretamente')),
      );
      return;
    }

    final provider = Provider.of<ListaProvider>(context, listen: false);
    provider.listaComprando.add({
      "produto": produto,
      "marca": marca,
      "valor": valor,
      "quantidade": quantidade,
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
    final provider = Provider.of<ListaProvider>(context, listen: false);
    provider.listaComprando.removeAt(index);
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
            const SizedBox(height: 8),
            campoTexto(marcaCtrl, 'Marca (opcional)', Icons.local_offer),
            const SizedBox(height: 8),
            campoTexto(valorCtrl, 'Valor', Icons.attach_money,
                tipo: TextInputType.number),
            const SizedBox(height: 8),
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

              if (novoProduto.isEmpty || novoValor <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Preencha os campos obrigatórios corretamente')),
                );
                return;
              }

              provider.listaComprando[index] = {
                "produto": novoProduto,
                "marca": novaMarca,
                "valor": novoValor,
                "quantidade": novaQtd,
              };

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

  void salvarListaNoHistorico() {
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

    try {
      provider.adicionarAoHistorico(jsonLista);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista salva no histórico')),
      );
      Navigator.pop(context, listaCompleta);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar lista: $e')),
      );
    }
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
    final textStyle = Theme.of(context).textTheme.bodyMedium;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: mercadoCtrl,
              decoration: campoEstilizado('Supermercado', Icons.store),
              style: textStyle,
            ),
            if (indexEdicao != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.orangeAccent),
                    const SizedBox(width: 6),
                    Text(
                      'Editando lista salva',
                      style: textStyle?.copyWith(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: campoTexto(
                        produtoCtrl, 'Produto', Icons.shopping_cart)),
                const SizedBox(width: 8),
                Expanded(
                    child: campoTexto(
                        marcaCtrl, 'Marca (opcional)', Icons.local_offer)),
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
                        fontWeight: FontWeight.bold,
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
                foregroundColor: Colors.black,
              ),
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
                  return Card(
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        Icons.shopping_bag,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        "${item['produto']} (${item['quantidade']}x) - ${item['marca']}",
                        style: textStyle,
                      ),
                      subtitle: Text(
                        "R\$ ${valorTotalItem.toStringAsFixed(2)}",
                        style: textStyle,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
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
