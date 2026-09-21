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
    return await openDatabase(dbPath, version: 2,
        onCreate: _createDb, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE t_varus ADD COLUMN period INTEGER DEFAULT 30');
      await db.execute('ALTER TABLE t_varus ADD COLUMN digits INTEGER DEFAULT 6');
      await db.execute("ALTER TABLE t_varus ADD COLUMN algorithm TEXT DEFAULT 'SHA1'");
    }
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE t_varus (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, secret TEXT, description TEXT, period INTEGER DEFAULT 30, digits INTEGER DEFAULT 6, algorithm TEXT DEFAULT \'SHA1\')',
    );
  }
}
