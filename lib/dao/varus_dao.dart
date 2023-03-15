import 'package:varus/utils/database.dart';

class Varus {
  int? id;
  String name;
  String value;
  String description;

  Varus({this.id, required this.name, required this.value, required this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'description': description,
    };
  }
  static Varus fromMap(Map<String, dynamic> map) {
    return Varus(
      id: map['id'],
      name: map['name'],
      value: map['value'],
      description: map['description'],
    );
  }
}


class VarusDao {
  static final VarusDao instance = VarusDao._instance();

  VarusDao._instance();

  Future<List<Varus>> queryAllVarus() async {
    var client = await DatabaseUtils.instance.db;
    final List<Map<String, dynamic>> results = await client.query('t_varus');
    final List<Varus> vs = [];
    results.forEach((map) {
      vs.add(Varus.fromMap(map));
    });
    return vs;
  }

  Future<int> createVarus(Varus varus) async {
    var client = await DatabaseUtils.instance.db;
    return client.insert(
      't_varus',
      varus.toMap(),
    );
  }

  Future<int> deleteVarus(Varus varus) async {
    var client = await DatabaseUtils.instance.db;
    int affected = await client.delete('t_varus', where: 'id = ?', whereArgs: [varus.id]);
    return affected;
  }

  // Future<int> updateVarus(Varus varus) async {
  //   var client = await DatabaseUtils.instance.db;
  //   int affected = await client.update('t_varus', varus.toMap(), where: 'id = ?', whereArgs: [varus.id]);
  //   return affected;
  // }
}
