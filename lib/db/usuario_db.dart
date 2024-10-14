import 'package:app_a3/models/usuario.dart';
import './db_helper.dart';

class UsuarioDb {
  final DBHelper _dbHelper = DBHelper();

  Future<int> criarUsuario(Usuario usuario) async {
    final db = await _dbHelper.database;
    try {
      return await db.insert('usuarios', usuario.toMap());
    } catch (e) {
      return -1;
    }
  }

  Future<Usuario?> listarUsuario(String email, String senha) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    return res.isNotEmpty ? Usuario.fromMap(res.first) : null;
  }

  Future<Usuario?> listarUsuarioPorId(int id) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    return res.isNotEmpty ? Usuario.fromMap(res.first) : null;
  }

  Future<Usuario?> listarUsuarioPorEmail(String email) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    return res.isNotEmpty ? Usuario.fromMap(res.first) : null;
  }
}
