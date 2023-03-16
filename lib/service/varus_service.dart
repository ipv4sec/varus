import 'package:varus/dao/varus_dao.dart';

class VarusService {
  static final VarusService instance = VarusService._instance();

  VarusService._instance();

  Future<List<Varus>> queryAllVarus() {
    return VarusDao.instance.queryAllVarus();
  }

  Future<int> createVarus(Varus varus) async {
    return await VarusDao.instance.createVarus(varus);
  }

  Future<bool> deleteVarus(int id) async {
    return 1 == await VarusDao.instance.deleteVarus(id);
  }
}
