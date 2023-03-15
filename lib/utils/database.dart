import 'package:sqflite/sqflite.dart';

class DatabaseUtils {
  static final DatabaseUtils instance = DatabaseUtils._instance();
  static Database? _db;

  DatabaseUtils._instance();

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db!;
  }

  Future<Database> _initDb() async {
    String dbPath = '${await getDatabasesPath()}/varus.sqlite';
    // print(dbPath);
    Database db = await openDatabase(dbPath, version: 1, onCreate: _createDb);
    return db;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE t_varus (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, value TEXT, description TEXT)',
    );
  }
}
