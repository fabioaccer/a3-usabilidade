import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  _initDB() async {
    String path = join(await getDatabasesPath(), 'notys.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        senha TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE categorias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        usuarioId INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE tarefas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT,
        descricao TEXT,
        data TEXT,
        hora TEXT,
        realizada BOOLEAN,
        usuarioId INTEGER,
        categoriaId INTEGER,
        FOREIGN KEY (usuarioId) REFERENCES usuarios(id),
        FOREIGN KEY (categoriaId) REFERENCES categorias(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE lembretes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT,
        descricao TEXT,
        data TEXT,
        hora TEXT,
        usuarioId INTEGER,
        tarefaId INTEGER NULL,
        FOREIGN KEY (usuarioId) REFERENCES usuarios(id),
        FOREIGN KEY (tarefaId) REFERENCES tarefas(id)
      );
    ''');
  }
}
