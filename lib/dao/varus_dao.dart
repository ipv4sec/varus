import 'package:varus/utils/database_utils.dart';

class Varus {
  int? id;
  String name;
  String secret;
  String description;
  int? period;
  int? digits;
  String? algorithm;

  Varus({
    this.id,
    required this.name,
    required this.secret,
    required this.description,
    this.period,
    this.digits,
    this.algorithm,
  });

  int get effectivePeriod => period ?? 30;

  int get effectiveDigits => digits ?? 6;

  String get effectiveAlgorithm => algorithm ?? 'SHA1';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'secret': secret,
      'description': description,
      'period': effectivePeriod,
      'digits': effectiveDigits,
      'algorithm': effectiveAlgorithm,
    };
  }

  static Varus fromMap(Map<String, dynamic> map) {
    return Varus(
      id: map['id'],
      name: map['name'],
      secret: map['secret'],
      description: map['description'],
      period: map['period'],
      digits: map['digits'],
      algorithm: map['algorithm'],
    );
  }
}


class VarusDao {
  static final VarusDao instance = VarusDao._instance();
  var tableName = 't_varus';

  VarusDao._instance();

  Future<List<Varus>> queryAllVarus() async {
    var database = await DatabaseUtils.instance.database;
    final List<Map<String, dynamic>> ms = await database.query(tableName);
    final List<Varus> vs = [];
    for (var i = 0; i < ms.length; i++) {
      vs.add(Varus.fromMap(ms[i]));
    }
    return vs;
  }

  Future<int> createVarus(Varus varus) async {
    var database = await DatabaseUtils.instance.database;
    return database.insert(tableName, varus.toMap());
  }

  Future<int> deleteVarus(int id) async {
    var database = await DatabaseUtils.instance.database;
    return await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
