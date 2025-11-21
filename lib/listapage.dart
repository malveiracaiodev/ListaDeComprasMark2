import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'listaprovider.dart';
import 'pagina_base.dart';

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

  // Pilha para desfazer ações (add, edit, delete)
  final List<_Acao> _historicoAcoes = [];

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
            List<Map<String, dynamic>>.from(lista['itens'] ?? []);
        indexEdicao = index;
      }
    }
  }

  @override
  void dispose() {
    mercadoCtrl.dispose();
    produtoCtrl.dispose();
    marcaCtrl.dispose();
    quantidadeCtrl.dispose();
    valorCtrl.dispose();
    super.dispose();
  }

  InputDecoration campoEstilizado(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.cyan),
      prefixIcon: Icon(icon, color: Colors.cyan),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyan),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyan, width: 2),
      ),
    );
  }

  Widget campoTexto(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? tipo,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      style: const TextStyle(color: Colors.cyan),
      decoration: campoEstilizado(label, icon),
    );
  }

  void _mostrarSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void adicionarItem() {
    final produto = produtoCtrl.text.trim();
    final marca = marcaCtrl.text.trim();
    final valorTexto = valorCtrl.text.replaceAll(',', '.');
    final valor = double.tryParse(valorTexto) ?? 0;
    final quantidade = int.tryParse(quantidadeCtrl.text) ?? 1;

    if (produto.isEmpty) {
      _mostrarSnack('Informe o produto');
      return;
    }
    if (quantidade <= 0) {
      _mostrarSnack('Quantidade deve ser maior que 0');
      return;
    }
    if (valor < 0) {
      _mostrarSnack('Valor não pode ser negativo');
      return;
    }

    final provider = Provider.of<ListaProvider>(context, listen: false);
    final novoItem = {
      "produto": produto,
      "marca": marca,
      "valor": valor,
      "quantidade": quantidade,
    };

    setState(() {
      provider.adicionarItem(novoItem);
      _historicoAcoes.add(_Acao.adicao(novoItem));
    });

    produtoCtrl.clear();
    marcaCtrl.clear();
    valorCtrl.clear();
    quantidadeCtrl.clear();
  }

  void removerItem(int index) {
    final provider = Provider.of<ListaProvider>(context, listen: false);
    final itemRemovido =
        Map<String, dynamic>.from(provider.listaComprando[index]);
    setState(() {
      provider.removerItem(index);
      _historicoAcoes.add(_Acao.exclusao(itemRemovido, index));
    });
  }

  void editarItem(int index) {
    final provider = Provider.of<ListaProvider>(context, listen: false);
    final item = Map<String, dynamic>.from(provider.listaComprando[index]);

    produtoCtrl.text = item['produto'] ?? '';
    marcaCtrl.text = item['marca'] ?? '';
    valorCtrl.text = (item['valor'] ?? 0).toString();
    quantidadeCtrl.text = (item['quantidade'] ?? 1).toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Editar Item', style: TextStyle(color: Colors.cyan)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            campoTexto(produtoCtrl, 'Produto', Icons.shopping_cart),
            const SizedBox(height: 8),
            campoTexto(marcaCtrl, 'Marca (opcional)', Icons.local_offer),
            const SizedBox(height: 8),
            campoTexto(valorCtrl, 'Valor (opcional)', Icons.attach_money,
                tipo: TextInputType.number),
            const SizedBox(height: 8),
            campoTexto(quantidadeCtrl, 'Quantidade (opcional)', Icons.numbers,
                tipo: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.cyan)),
          ),
          ElevatedButton(
            style: estiloBotao(),
            onPressed: () {
              final novoProduto = produtoCtrl.text.trim();
              final novaMarca = marcaCtrl.text.trim();
              final novoValor =
                  double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0;
              final novaQtd = int.tryParse(quantidadeCtrl.text) ?? 1;

              if (novoProduto.isEmpty) {
                _mostrarSnack('Informe o produto');
                return;
              }
              if (novaQtd <= 0) {
                _mostrarSnack('Quantidade deve ser maior que 0');
                return;
              }
              if (novoValor < 0) {
                _mostrarSnack('Valor não pode ser negativo');
                return;
              }

              final novoItem = {
                "produto": novoProduto,
                "marca": novaMarca,
                "valor": novoValor,
                "quantidade": novaQtd,
              };

              setState(() {
                provider.editarItem(index, novoItem);
                _historicoAcoes.add(_Acao.edicao(
                    itemAntigo: item, itemNovo: novoItem, index: index));
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

  void desfazerUltimaAcao() {
    if (_historicoAcoes.isEmpty) {
      _mostrarSnack('Nada para desfazer');
      return;
    }
    final provider = Provider.of<ListaProvider>(context, listen: false);
    final acao = _historicoAcoes.removeLast();

    setState(() {
      if (acao.tipo == _TipoAcao.adicao) {
        // desfazer adição → remover último item igual
        final idx = provider.listaComprando.lastIndexWhere(
          (it) => mapEqualsShallow(it, acao.item),
        );
        if (idx != -1) provider.removerItem(idx);
      } else if (acao.tipo == _TipoAcao.exclusao) {
        // desfazer exclusão → inserir de volta na posição original, se possível
        final pos = (acao.index ?? provider.listaComprando.length);
        provider.inserirItem(pos, acao.item);
      } else if (acao.tipo == _TipoAcao.edicao) {
        // desfazer edição → restaurar item antigo
        if (acao.index != null) {
          provider.editarItem(acao.index!, acao.itemAntigo!);
        }
      }
    });

    _mostrarSnack('Última ação desfeita');
  }

  void salvarListaNoHistorico() async {
    final provider = Provider.of<ListaProvider>(context, listen: false);
    final listaCompleta = {
      "mercado": mercadoCtrl.text,
      "itens": provider.listaComprando,
      "total": provider.listaComprando.fold<double>(
        0,
        (sum, item) => sum + (item['valor'] ?? 0) * (item['quantidade'] ?? 1),
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
      _mostrarSnack('Lista atualizada no histórico');
    } else {
      listasJson.add(jsonLista);
      _mostrarSnack('Lista salva no histórico');
    }

    await prefs.setStringList('listas_salvas', listasJson);
    Navigator.pop(context, listaCompleta);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ListaProvider>(context);
    final total = provider.listaComprando.fold<double>(
      0,
      (sum, item) => sum + (item['valor'] ?? 0) * (item['quantidade'] ?? 1),
    );

    return PaginaBase(
      titulo: "Lista de Compras",
      conteudo: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Total acima dos itens
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Total: R\$ ${total.toStringAsFixed(2)}",
                style: const TextStyle(
                    color: Colors.cyan,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Campos
            campoTexto(mercadoCtrl, 'Supermercado (opcional)', Icons.store),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: campoTexto(produtoCtrl, 'Produto (obrigatório)',
                      Icons.shopping_cart),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: campoTexto(
                      marcaCtrl, 'Marca (opcional)', Icons.local_offer),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: campoTexto(
                      valorCtrl, 'Valor (opcional)', Icons.attach_money,
                      tipo: TextInputType.number),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: campoTexto(
                      quantidadeCtrl, 'Quantidade (opcional)', Icons.numbers,
                      tipo: TextInputType.number),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Ações superiores
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: estiloBotao(),
                    icon: const Icon(Icons.history, color: Colors.cyan),
                    label: const Text('Ver Histórico'),
                    onPressed: () => Navigator.pushNamed(context, '/historico'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: estiloBotao(),
                    icon: const Icon(Icons.add, color: Colors.cyan),
                    label: const Text('Adicionar'),
                    onPressed: adicionarItem,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botão desfazer
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: estiloBotao(),
                icon: const Icon(Icons.undo, color: Colors.cyan),
                label: const Text('Desfazer última ação'),
                onPressed: desfazerUltimaAcao,
              ),
            ),

            const SizedBox(height: 16),

            // Salvar histórico
            ElevatedButton.icon(
              style: estiloBotao(),
              icon: const Icon(Icons.save, color: Colors.cyan),
              label: const Text('Salvar no Histórico'),
              onPressed: provider.listaComprando.isEmpty
                  ? null
                  : salvarListaNoHistorico,
            ),

            const SizedBox(height: 16),

            // Lista de itens
            Expanded(
              child: ListView.builder(
                itemCount: provider.listaComprando.length,
                itemBuilder: (context, index) {
                  final item = provider.listaComprando[index];
                  final qtd = (item['quantidade'] ?? 1);
                  final val = (item['valor'] ?? 0).toDouble();
                  final valorTotalItem = val * qtd;

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(
                        "${item['produto']} (${qtd}x) - ${item['marca'] ?? ''}",
                        style: const TextStyle(color: Colors.cyan),
                      ),
                      subtitle: Text(
                        "R\$ ${valorTotalItem.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.cyan),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.cyan),
                            onPressed: () => editarItem(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
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

// ===== apoio para desfazer =====

enum _TipoAcao { adicao, exclusao, edicao }

class _Acao {
  final _TipoAcao tipo;
  final Map<String, dynamic> item;
  final Map<String, dynamic>? itemAntigo; // só para edição
  final int? index; // para exclusão/edição

  _Acao._(this.tipo, this.item, this.itemAntigo, this.index);

  factory _Acao.adicao(Map<String, dynamic> item) =>
      _Acao._(_TipoAcao.adicao, item, null, null);

  factory _Acao.exclusao(Map<String, dynamic> item, int index) =>
      _Acao._(_TipoAcao.exclusao, item, null, index);

  factory _Acao.edicao({
    required Map<String, dynamic> itemAntigo,
    required Map<String, dynamic> itemNovo,
    required int index,
  }) =>
      _Acao._(_TipoAcao.edicao, itemNovo, itemAntigo, index);
}

// comparação rasa de mapas
bool mapEqualsShallow(Map<String, dynamic> a, Map<String, dynamic> b) {
  if (a.length != b.length) return false;
  for (final k in a.keys) {
    if (!b.containsKey(k)) return false;
    if (a[k] != b[k]) return false;
  }
  return true;
}
