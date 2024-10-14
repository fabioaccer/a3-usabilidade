import 'package:app_a3/models/tarefa.dart';
import './db_helper.dart';

class TarefaDb {
  final DBHelper _dbHelper = DBHelper();

  Future<int> criarTarefa(Tarefa tarefa) async {
    final db = await _dbHelper.database;
    return await db.insert('tarefas', tarefa.toMap());
  }

  Future<List<Tarefa>> listarTarefas(int usuarioId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'tarefas',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );
    return res.isNotEmpty ? res.map((c) => Tarefa.fromMap(c)).toList() : [];
  }

  Future<int> editarTarefa(Tarefa todo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tarefas',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> excluirTarefa(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }
}
