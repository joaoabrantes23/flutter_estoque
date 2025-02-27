import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/produto_models.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'estoque.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            quantidade INTEGER,
            preco REAL
          )
        ''');
      },
    );
  }

  Future<int> inserirProduto(ProdutoModel produto) async {
    final db = await database;
    return await db.insert('produtos', produto.toMap());
  }

  Future<List<ProdutoModel>> listarProdutos() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('produtos');
    return List.generate(maps.length, (i) => ProdutoModel.fromMap(maps[i]));
  }

  Future<int> atualizarProduto(ProdutoModel produto) async {
    final db = await database;
    return await db.update(
      'produtos',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  Future<int> deletarProduto(int id) async {
    final db = await database;
    return await db.delete('produtos', where: 'id = ?', whereArgs: [id]);
  }
}
