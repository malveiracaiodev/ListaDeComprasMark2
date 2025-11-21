import 'package:flutter/material.dart';

class ListaProvider extends ChangeNotifier {
  // Lista atual de itens sendo comprados
  List<Map<String, dynamic>> _listaComprando = [];

  // Histórico em memória (opcional — você já persiste via SharedPreferences)
  final List<String> _historico = [];

  // Getters (imutáveis)
  List<Map<String, dynamic>> get listaComprando =>
      List.unmodifiable(_listaComprando);
  List<String> get historico => List.unmodifiable(_historico);

  // Setter com notificação (para carregar lista reaberta)
  set listaComprando(List<Map<String, dynamic>> novaLista) {
    _listaComprando = List<Map<String, dynamic>>.from(novaLista);
    notifyListeners();
  }

  // Total calculado
  double get total {
    return _listaComprando.fold<double>(
      0,
      (sum, item) => sum + (item['valor'] ?? 0) * (item['quantidade'] ?? 1),
    );
  }

  // Limpa a lista atual
  void limparLista() {
    _listaComprando.clear();
    notifyListeners();
  }

  // Adiciona novo item
  void adicionarItem(Map<String, dynamic> item) {
    _listaComprando.add(item);
    notifyListeners();
  }

  // Insere item em posição específica (suporta desfazer exclusão)
  void inserirItem(int index, Map<String, dynamic> item) {
    if (index < 0 || index > _listaComprando.length) {
      _listaComprando.add(item);
    } else {
      _listaComprando.insert(index, item);
    }
    notifyListeners();
  }

  // Remove item
  void removerItem(int index) {
    if (index >= 0 && index < _listaComprando.length) {
      _listaComprando.removeAt(index);
      notifyListeners();
    }
  }

  // Edita item
  void editarItem(int index, Map<String, dynamic> novoItem) {
    if (index >= 0 && index < _listaComprando.length) {
      _listaComprando[index] = novoItem;
      notifyListeners();
    }
  }

  // Histórico em memória (opcional)
  void adicionarAoHistorico(String listaJson) {
    _historico.add(listaJson);
    notifyListeners();
  }

  void atualizarHistorico(int index, String novaListaJson) {
    if (index >= 0 && index < _historico.length) {
      _historico[index] = novaListaJson;
      notifyListeners();
    }
  }
}
