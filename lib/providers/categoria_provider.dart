import 'package:flutter/material.dart';
import '../db/categoria_db.dart';
import '../models/categoria.dart';
import 'dart:math';

class CategoriaProvider with ChangeNotifier {
  final List<Categoria> _categorias = [];
  List<Categoria> get categorias => [..._categorias];
  final _categoriaDb = CategoriaDb();

  // Gera uma cor aleatória com brilho controlado
  String _gerarCorAleatoria() {
    final random = Random();
    final hue = random.nextDouble() * 360;
    final saturation = 0.3 + random.nextDouble() * 0.3;
    final value = 0.8 + random.nextDouble() * 0.2;
    
    final cor = HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();
    return '#${cor.value.toRadixString(16).padLeft(8, '0')}';
  }

  Future<void> listaCategorias(int usuarioId) async {
    print('Provider: Listando categorias para usuário $usuarioId'); // Debug
    _categorias.clear();
    _categorias.addAll(await _categoriaDb.listarCategorias(usuarioId));
    print('Provider: ${_categorias.length} categorias carregadas'); // Debug
    notifyListeners();
  }

  Future<void> criaCategoria(Categoria categoria) async {
    // Gera uma cor aleatória para a nova categoria
    categoria.cor = _gerarCorAleatoria();
    print('Provider: Criando categoria ${categoria.nome} com cor ${categoria.cor}'); // Debug
    await _categoriaDb.criarCategoria(categoria);
    // Recarrega a lista para obter o ID gerado
    await listaCategorias(categoria.usuarioId);
  }

  Future<void> editaCategoria(Categoria categoria) async {
    await _categoriaDb.editarCategoria(categoria);
    // Atualiza a categoria na lista local
    final index = _categorias.indexWhere((c) => c.id == categoria.id);
    if (index != -1) {
      _categorias[index] = categoria;
      notifyListeners();
    }
  }

  Future<void> excluiCategoria(int id) async {
    print('Provider: Excluindo categoria $id'); // Debug
    final usuarioId = _categorias.firstWhere((cat) => cat.id == id).usuarioId;
    await _categoriaDb.excluirCategoria(id);
    // Remove a categoria da lista local
    _categorias.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
