import 'package:sqflite/sqflite.dart';

class DatabaseUtils {
  static final DatabaseUtils instance = DatabaseUtils._instance();
  static Database? _database;

  DatabaseUtils._instance();

  Future<Database> get database async {
    return _database ?? await _init();
  }

  Future<Database> _init() async {
    String dbPath = '${await getDatabasesPath()}/varus.sqlite';
    return await openDatabase(dbPath, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE t_varus (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, value TEXT, description TEXT)',
    );
  }
}
