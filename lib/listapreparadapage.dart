import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lista_de_compras/listaprovider.dart';

class ListaPreparadaPage extends StatefulWidget {
  const ListaPreparadaPage({super.key});

  @override
  State<ListaPreparadaPage> createState() => _ListaPreparadaPageState();
}

InputDecoration campoEstilizado(
    BuildContext context, String label, IconData icon) {
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

class _ListaPreparadaPageState extends State<ListaPreparadaPage> {
  final TextEditingController produtoCtrl = TextEditingController();
  final TextEditingController quantidadeCtrl = TextEditingController();

  void adicionarItem(BuildContext context) {
    final produto = produtoCtrl.text.trim();
    final quantidade = int.tryParse(quantidadeCtrl.text) ?? 1;

    if (produto.isEmpty || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos corretamente')),
      );
      return;
    }

    final provider = Provider.of<ListaProvider>(context, listen: false);
    provider.adicionarItemPreparado({
      "produto": produto,
      "quantidade": quantidade,
    });

    produtoCtrl.clear();
    quantidadeCtrl.clear();
  }

  void removerItem(BuildContext context, int index) {
    final provider = Provider.of<ListaProvider>(context, listen: false);
    provider.removerItemPreparado(index);
  }

  void irParaModoComprando(BuildContext context) {
    final provider = Provider.of<ListaProvider>(context, listen: false);

    if (provider.listaPreparada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione itens antes de continuar')),
      );
      return;
    }

    provider.moverParaComprando();

    Navigator.pushNamed(
      context,
      '/comprando',
      arguments: {
        'index': null,
        'lista': {
          'mercado': '',
          'itens': provider.listaComprando,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final provider = Provider.of<ListaProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Lista Preparada')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: produtoCtrl,
                    decoration:
                        campoEstilizado(context, 'Produto', Icons.shopping_bag),
                    style: textStyle,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: quantidadeCtrl,
                    decoration: campoEstilizado(context, 'Qtd', Icons.numbers),
                    keyboardType: TextInputType.number,
                    style: textStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Modo Comprando'),
                    onPressed: () => irParaModoComprando(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => adicionarItem(context),
                    child: const Text('Adicionar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: provider.listaPreparada.length,
                itemBuilder: (context, index) {
                  final item = provider.listaPreparada[index];
                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(Icons.checklist,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(
                        "${item['produto']} (${item['quantidade']}x)",
                        style: textStyle,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removerItem(context, index),
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
