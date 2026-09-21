import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:varus/dao/varus_dao.dart';
import 'package:varus/service/varus_service.dart';
import 'package:varus/page/filling_page.dart';
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
              final isHotp = varus.isHotp;
              final code = TotpUtils.generate(
                secret: varus.secret,
                period: period,
                digits: varus.effectiveDigits,
                algorithm: varus.effectiveAlgorithm,
                counter: isHotp ? varus.effectiveCounter : counter,
              );
              final displayCode = code == null
                  ? null
                  : '${code.substring(0, code.length ~/ 2)} ${code.substring(code.length ~/ 2)}';
              return Theme(
                data: Theme.of(context).copyWith(
                  splashFactory: InkSparkle.splashFactory,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      leading: CircleAvatar(child: _iconFor(varus)),
                      title: Text(varus.name),
                      subtitle: Text(varus.description),
                      trailing: code == null
                          ? const Text('无效密钥',
                              style: TextStyle(color: Colors.red))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  displayCode!,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                if (isHotp)
                                  const Text(
                                    'HOTP',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                              ],
                            ),
                      onTap: () => _onEntryTap(varus, code),
                      onLongPress: () => _showEntryMenu(varus),
                    ),
                    if (!isHotp && code != null)
                      LinearProgressIndicator(
                        value: remaining / period,
                        minHeight: 3,
                        backgroundColor: Colors.black12,
                      ),
                  ],
                ),
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

  static const List<IconData> _entryIcons = [
    Icons.security,
    Icons.shield,
    Icons.key,
    Icons.vpn_key,
    Icons.lock,
    Icons.lock_outline,
    Icons.fingerprint,
    Icons.verified_user,
    Icons.account_circle,
    Icons.account_balance,
    Icons.alternate_email,
    Icons.email,
    Icons.smartphone,
    Icons.laptop,
    Icons.public,
    Icons.badge,
    Icons.credit_card,
    Icons.cloud,
    Icons.star,
    Icons.favorite,
  ];

  Icon _iconFor(Varus varus) {
    final key = '${varus.id ?? 0}|${varus.name}';
    var hash = 0;
    for (final unit in key.codeUnits) {
      hash = (hash * 31 + unit) % 0x7fffffff;
    }
    return Icon(_entryIcons[hash % _entryIcons.length], color: Colors.white);
  }

  Future<void> _onEntryTap(Varus varus, String? code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) {
      return;
    }
    if (code == null) {
      toast('密钥无效，无法生成验证码');
      return;
    }
    var codeToCopy = code;
    if (varus.isHotp) {
      varus.counter = varus.effectiveCounter + 1;
      await VarusService.instance.updateVarus(varus);
      final nextCode = TotpUtils.generate(
        secret: varus.secret,
        digits: varus.effectiveDigits,
        algorithm: varus.effectiveAlgorithm,
        counter: varus.effectiveCounter,
      );
      if (nextCode != null) {
        codeToCopy = nextCode;
      }
      vs = await VarusService.instance.queryAllVarus();
      _streamController.sink.add(vs);
    }
    await Clipboard.setData(ClipboardData(text: codeToCopy));
    toast('验证码已复制');
  }

  Future<void> _showEntryMenu(Varus varus) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('编辑条目'),
              onTap: () => Navigator.pop(sheetContext, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除条目',
                  style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(sheetContext, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    if (action == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FillingPage(existing: varus)),
      );
    } else if (action == 'delete') {
      await _confirmDelete(varus);
    }
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
