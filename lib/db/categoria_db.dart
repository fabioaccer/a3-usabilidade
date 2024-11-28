import 'package:sqflite/sqflite.dart';
import '../models/categoria.dart';
import 'db_helper.dart';

class CategoriaDb {
  final DBHelper _dbHelper = DBHelper();

  Future<void> criarCategoria(Categoria categoria) async {
    final db = await _dbHelper.database;
    print('Criando categoria: ${categoria.toMap()}'); // Debug
    await db.insert('categorias', categoria.toMap());
  }

  Future<List<Categoria>> listarCategorias(int usuarioId) async {
    final db = await _dbHelper.database;
    print('Buscando categorias para usuário: $usuarioId'); // Debug
    final res = await db.query(
      'categorias',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );
    print('Categorias encontradas: $res'); // Debug

    return res.isNotEmpty 
        ? res.map((c) => Categoria.fromMap(c)).toList()
        : [];
  }

  Future<void> editarCategoria(Categoria categoria) async {
    final db = await _dbHelper.database;
    await db.update('categorias', categoria.toMap(),
        where: 'id = ?', whereArgs: [categoria.id]);
  }

  Future<void> excluirCategoria(int id) async {
    final db = await _dbHelper.database;
    await db.delete('categorias', where: 'id = ?', whereArgs: [id]);
  }
}
