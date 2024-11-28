import 'package:listvo/models/lembrete.dart';
import './db_helper.dart';

class LembreteDb {
  final DBHelper _dbHelper = DBHelper();

  Future<int> criarLembrete(Lembrete lembrete) async {
    final db = await _dbHelper.database;
    return await db.insert('lembretes', lembrete.toMap());
  }

  Future<List<Lembrete>> listarLembretes(int usuarioId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'lembretes',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );
    return res.isNotEmpty ? res.map((c) => Lembrete.fromMap(c)).toList() : [];
  }

  Future<int> editarLembrete(Lembrete todo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'lembretes',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> excluirLembrete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('lembretes', where: 'id = ?', whereArgs: [id]);
  }
}
