import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:varus/dao/varus_dao.dart';
import 'package:varus/service/varus_service.dart';
import 'package:varus/utils/toast_utils.dart';
import 'package:varus/utils/totp_utils.dart';

import 'package:varus/widgets/customized_appbar.dart';
import 'package:varus/widgets/customized_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Varus> vs = [];
  var _streamController = StreamController<List<Varus>>();
  late Timer _ticker;
  int _nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        });
      }
    });
    _init();
  }

  Future<void> _init() async {
    vs = await VarusService.instance.queryAllVarus();
    _streamController.sink.add(vs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomizedDrawer(),
      appBar: CustomizedAppBar(),
      body: StreamBuilder<List<Varus>>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Text("Loading");
          }
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (BuildContext context, int index) => Divider(
              height: 0.1,
              color: Color(0xFFF9FBE7),
            ),
            itemBuilder: (BuildContext context, int index) {
              final varus = snapshot.data![index];
              final period = varus.effectivePeriod;
              final counter = _nowSeconds ~/ period;
              final remaining = period - (_nowSeconds % period);
              final code = TotpUtils.generate(
                secret: varus.secret,
                period: period,
                digits: varus.effectiveDigits,
                algorithm: varus.effectiveAlgorithm,
                counter: counter,
              );
              return ListTile(
                leading: CircleAvatar(
                    child: Icon(
                  Icons.account_tree,
                  color: Colors.white,
                )),
                title: Text("Name: ${varus.name}"),
                subtitle: Text("Description: ${varus.description}"),
                trailing: code == null
                    ? const Text('无效密钥',
                        style: TextStyle(color: Colors.red))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${code.substring(0, code.length ~/ 2)} ${code.substring(code.length ~/ 2)}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 96,
                            child: LinearProgressIndicator(
                              value: remaining / period,
                              minHeight: 3,
                              backgroundColor: Colors.black12,
                            ),
                          ),
                        ],
                      ),
                onTap: () async {
                  if (code == null) {
                    toast('密钥无效，无法生成验证码');
                    return;
                  }
                  await Clipboard.setData(ClipboardData(text: code));
                  toast('验证码已复制');
                },
                onLongPress: () => _confirmDelete(varus),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, "/scanning");
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text("添加条目"),
      ),
    );
  }

  Future<void> _confirmDelete(Varus varus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除条目'),
        content: Text('确定删除 "${varus.name}" 吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await VarusService.instance.deleteVarus(varus.id!);
    vs = await VarusService.instance.queryAllVarus();
    _streamController.sink.add(vs);
  }

  @override
  void dispose() {
    _ticker.cancel();
    _streamController.close();
    super.dispose();
  }
}
