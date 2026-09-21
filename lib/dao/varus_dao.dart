import 'package:varus/utils/database_utils.dart';
import 'package:varus/utils/secret_crypto.dart';

class Varus {
  int? id;
  String name;
  String secret;
  String description;
  int? period;
  int? digits;
  String? algorithm;
  String? type;
  int? counter;

  Varus({
    this.id,
    required this.name,
    required this.secret,
    required this.description,
    this.period,
    this.digits,
    this.algorithm,
    this.type,
    this.counter,
  });

  int get effectivePeriod => period ?? 30;

  int get effectiveDigits => digits ?? 6;

  String get effectiveAlgorithm => algorithm ?? 'SHA1';

  String get effectiveType => type ?? 'totp';

  int get effectiveCounter => counter ?? 0;

  bool get isHotp => effectiveType == 'hotp';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'secret': secret,
      'description': description,
      'period': effectivePeriod,
      'digits': effectiveDigits,
      'algorithm': effectiveAlgorithm,
      'type': effectiveType,
      'counter': effectiveCounter,
    };
  }

  static Varus fromMap(Map<String, dynamic> map) {
    return Varus(
      id: map['id'],
      name: map['name'] ?? '',
      secret: SecretCrypto.decryptSecret(map['secret'] ?? ''),
      description: map['description'] ?? '',
      period: map['period'],
      digits: map['digits'],
      algorithm: map['algorithm'],
      type: map['type'],
      counter: map['counter'],
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
    final map = varus.toMap();
    map['secret'] = SecretCrypto.encryptSecret(varus.secret);
    return database.insert(tableName, map);
  }

  Future<int> updateVarus(Varus varus) async {
    var database = await DatabaseUtils.instance.database;
    final map = varus.toMap();
    map['secret'] = SecretCrypto.encryptSecret(varus.secret);
    return await database.update(tableName, map,
        where: 'id = ?', whereArgs: [varus.id]);
  }

  Future<int> deleteVarus(int id) async {
    var database = await DatabaseUtils.instance.database;
    return await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// 旧版本明文 secret 一次性加密回写（可重入）。
  Future<void> migratePlaintextSecrets() async {
    if (!SecretCrypto.isReady) {
      return;
    }
    var database = await DatabaseUtils.instance.database;
    final rows = await database.query(tableName);
    for (final row in rows) {
      final secret = row['secret'];
      if (secret is String && !SecretCrypto.isEncrypted(secret)) {
        await database.update(tableName,
            {'secret': SecretCrypto.encryptSecret(secret)},
            where: 'id = ?', whereArgs: [row['id']]);
      }
    }
  }
}
