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
    String path = join(await getDatabasesPath(), 'listvo.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Backup dos dados
      final tarefas = await db.query('tarefas');
      
      // Recria a tabela com a nova estrutura
      await db.execute('DROP TABLE IF EXISTS tarefas');
      await db.execute('''
        CREATE TABLE tarefas(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT,
          descricao TEXT,
          data TEXT,
          hora TEXT,
          realizada BOOLEAN,
          usuarioId INTEGER,
          categoriaId INTEGER NULL,
          FOREIGN KEY (usuarioId) REFERENCES usuarios(id),
          FOREIGN KEY (categoriaId) REFERENCES categorias(id)
        );
      ''');

      // Restaura os dados
      for (var tarefa in tarefas) {
        await db.insert('tarefas', tarefa);
      }
    }
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
        usuarioId INTEGER,
        cor TEXT,
        FOREIGN KEY (usuarioId) REFERENCES usuarios(id)
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
        categoriaId INTEGER NULL,
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
