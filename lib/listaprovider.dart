import 'package:flutter/material.dart';

class ListaProvider extends ChangeNotifier {
  // Lista de itens preparados antes da compra
  final List<Map<String, dynamic>> _listaPreparada = [];

  // Lista atual de itens sendo comprados
  List<Map<String, dynamic>> _listaComprando = [];

  // Histórico de listas salvas (em formato JSON)
  final List<String> _historico = [];

  // Getters
  List<Map<String, dynamic>> get listaPreparada =>
      List.unmodifiable(_listaPreparada);
  List<Map<String, dynamic>> get listaComprando =>
      List.unmodifiable(_listaComprando);
  List<String> get historico => List.unmodifiable(_historico);

  // Setter com notificação
  set listaComprando(List<Map<String, dynamic>> novaLista) {
    _listaComprando = List<Map<String, dynamic>>.from(novaLista);
    notifyListeners();
  }

  // Adiciona uma nova lista ao histórico
  void adicionarAoHistorico(String listaJson) {
    _historico.add(listaJson);
    notifyListeners();
  }

  // Atualiza uma lista existente no histórico
  void atualizarHistorico(int index, String novaListaJson) {
    if (index >= 0 && index < _historico.length) {
      _historico[index] = novaListaJson;
      notifyListeners();
    }
  }

  // Limpa a lista atual
  void limparLista() {
    _listaComprando.clear();
    notifyListeners();
  }

  // Remove item da lista atual
  void removerItem(int index) {
    if (index >= 0 && index < _listaComprando.length) {
      _listaComprando.removeAt(index);
      notifyListeners();
    }
  }

  // Atualiza um item da lista atual
  void editarItem(int index, Map<String, dynamic> novoItem) {
    if (index >= 0 && index < _listaComprando.length) {
      _listaComprando[index] = novoItem;
      notifyListeners();
    }
  }

  // Adiciona um novo item à lista atual
  void adicionarItem(Map<String, dynamic> item) {
    _listaComprando.add(item);
    notifyListeners();
  }

  // Adiciona item à lista preparada
  void adicionarItemPreparado(Map<String, dynamic> item) {
    _listaPreparada.add(item);
    notifyListeners();
  }

  // Remove item da lista preparada
  void removerItemPreparado(int index) {
    if (index >= 0 && index < _listaPreparada.length) {
      _listaPreparada.removeAt(index);
      notifyListeners();
    }
  }

  // Move itens da lista preparada para a lista comprando
  void moverParaComprando() {
    _listaComprando.clear();
    _listaComprando.addAll(_listaPreparada.map((item) => {
          "produto": item['produto'],
          "marca": "",
          "valor": 0.0,
          "quantidade": item['quantidade'],
        }));
    _listaPreparada.clear();
    notifyListeners();
  }
}
