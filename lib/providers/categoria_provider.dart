import 'package:app_a3/db/categoria_db.dart';
import 'package:flutter/material.dart';
import '../models/categoria.dart';

class CategoriaProvider with ChangeNotifier {
  List<Categoria> _categorias = [];
  List<Categoria> get categorias => _categorias;

  Future<void> listaCategorias(int usuarioId) async {
    _categorias = await CategoriaDb().listarCategorias(usuarioId);
    notifyListeners();
  }

  Future<void> criaCategoria(Categoria categoria) async {
    await CategoriaDb().criarCategoria(categoria);
    notifyListeners();
  }

  Future<void> editaCategoria(Categoria categoria) async {
    await CategoriaDb().editarCategoria(categoria);
    notifyListeners();
  }

  Future<void> excluiCategoria(int id) async {
    await CategoriaDb().excluirCategoria(id);
    notifyListeners();
  }
}
