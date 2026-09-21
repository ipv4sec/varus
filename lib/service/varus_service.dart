import 'package:varus/dao/varus_dao.dart';
import 'package:varus/utils/secret_crypto.dart';

class VarusService {
  static final VarusService instance = VarusService._instance();
  static bool _ready = false;

  VarusService._instance();

  /// 首次数据访问前初始化加密密钥并迁移旧明文 secret（幂等）。
  Future<void> ensureReady() async {
    if (_ready) {
      return;
    }
    await SecretCrypto.init();
    await VarusDao.instance.migratePlaintextSecrets();
    _ready = true;
  }

  Future<List<Varus>> queryAllVarus() async {
    await ensureReady();
    return VarusDao.instance.queryAllVarus();
  }

  Future<int> createVarus(Varus varus) async {
    await ensureReady();
    return await VarusDao.instance.createVarus(varus);
  }

  Future<int> updateVarus(Varus varus) async {
    await ensureReady();
    return await VarusDao.instance.updateVarus(varus);
  }

  Future<bool> deleteVarus(int id) async {
    await ensureReady();
    return 1 == await VarusDao.instance.deleteVarus(id);
  }
}
