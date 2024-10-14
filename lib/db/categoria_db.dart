import 'package:app_a3/models/categoria.dart';
import './db_helper.dart';

class CategoriaDb {
  final DBHelper _dbHelper = DBHelper();

  Future<int> criarCategoria(Categoria categoria) async {
    final db = await _dbHelper.database;
    return await db.insert('categorias', categoria.toMap());
  }

  Future<List<Categoria>> listarCategorias(int usuarioId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'categorias',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );
    return res.isNotEmpty ? res.map((c) => Categoria.fromMap(c)).toList() : [];
  }

  Future<int> editarCategoria(Categoria categoria) async {
    final db = await _dbHelper.database;
    return await db.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  Future<int> excluirCategoria(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('categorias', where: 'id = ?', whereArgs: [id]);
  }
}
