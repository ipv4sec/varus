import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:varus/dao/varus_dao.dart';
import 'package:varus/service/varus_service.dart';
import 'package:varus/utils/secret_crypto.dart';
import 'package:varus/utils/theme_controller.dart';
import 'package:varus/utils/toast_utils.dart';
import 'package:varus/widgets/customized_appbar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _lockKey = 'app_lock_enabled';

  var _stream = StreamController();
  var _debug = "";
  bool _lockEnabled = true;

  @override
  void initState() {
    super.initState();
    _init();
    ThemeController.instance.addListener(_onThemeChanged);
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) {
        return;
      }
      setState(() {
        _lockEnabled = prefs.getBool(_lockKey) ?? true;
      });
    });
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _init() async {
    var ms = [];
    var vs = await VarusService.instance.queryAllVarus();
    for (var i = 0; i < vs.length; i++) {
      final m = vs[i].toMap();
      m['secret'] = _maskSecret(m['secret'] as String);
      ms.add(m);
    }
    _debug = jsonEncode(ms);
    _stream.sink.add(_debug);
  }

  String _maskSecret(String secret) {
    if (secret.length <= 4) {
      return '****';
    }
    return '${secret.substring(0, 4)}****';
  }

  Future<String?> _promptPassword(String title) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(hintText: '密码'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    final vs = await VarusService.instance.queryAllVarus();
    if (vs.isEmpty) {
      toast("没有数据");
      return;
    }
    final password = await _promptPassword("设置导出密码");
    if (password == null || password.isEmpty) {
      return;
    }
    final plaintext = jsonEncode(vs.map((v) => v.toMap()).toList());
    final backup = SecretCrypto.encryptBackup(plaintext, password);
    final bytes =
        Uint8List.fromList(utf8.encode(jsonEncode(backup)));
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp =
        '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}';
    try {
      final path = await FilePicker.platform.saveFile(
        fileName: 'varus-backup-$stamp.json',
        bytes: bytes,
      );
      if (path == null) {
        toast("已取消导出");
        return;
      }
      final file = io.File(path);
      if (!file.existsSync() || file.lengthSync() == 0) {
        await file.writeAsBytes(bytes);
      }
      toast("导出成功");
    } catch (e) {
      debugPrint('export error: $e');
      toast("导出失败");
    }
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final filePath = result?.files.single.path;
    if (filePath == null) {
      return;
    }
    try {
      final content = io.File(filePath).readAsStringSync();
      final dynamic decoded = jsonDecode(content);
      List<dynamic> entries;
      if (decoded is Map && decoded['format'] == 'varus-backup') {
        final password = await _promptPassword("输入备份密码");
        if (password == null || password.isEmpty) {
          return;
        }
        final plaintext = SecretCrypto.decryptBackup(
            Map<String, dynamic>.from(decoded), password);
        if (plaintext == null) {
          toast("密码错误或文件损坏");
          return;
        }
        entries = jsonDecode(plaintext) as List<dynamic>;
      } else if (decoded is List) {
        entries = decoded;
      } else {
        toast("无法识别的文件格式");
        return;
      }
      final existing = await VarusService.instance.queryAllVarus();
      final keys =
          existing.map((v) => '${v.name}|${v.secret}').toSet();
      var imported = 0;
      var skipped = 0;
      for (final e in entries) {
        final varus = Varus.fromMap(Map<String, dynamic>.from(e as Map));
        if (varus.name.isEmpty || varus.secret.isEmpty) {
          skipped++;
          continue;
        }
        final key = '${varus.name}|${varus.secret}';
        if (keys.contains(key)) {
          skipped++;
          continue;
        }
        varus.id = null;
        await VarusService.instance.createVarus(varus);
        keys.add(key);
        imported++;
      }
      await _init();
      toast("导入 $imported 条，跳过 $skipped 条");
    } catch (e) {
      debugPrint('import error: $e');
      toast("导入失败");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomizedAppBar(),
      body: StreamBuilder(
        stream: _stream.stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text("应用锁"),
                subtitle: const Text("打开应用时需要验证指纹或锁屏密码"),
                value: _lockEnabled,
                onChanged: (value) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool(_lockKey, value);
                  setState(() {
                    _lockEnabled = value;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: const Text("外观模式"),
                subtitle: Text(_modeLabel(ThemeController.instance.mode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showModeSheet,
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text("主题配色"),
                subtitle: Text(ThemeController.instance.scheme.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showSchemeDialog,
              ),
              if (snapshot.data != null)
                Html(data: '<pre>${snapshot.data}</pre>'),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "1",
            onPressed: _exportData,
            label: Text("导出数据"),
            icon: Icon(Icons.import_export),
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            heroTag: "2",
            onPressed: _importData,
            label: Text("导入数据"),
            icon: Icon(Icons.label_important_sharp),
          ),
        ],
      ),
    );
  }

  String _modeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return "跟随系统";
      case ThemeMode.light:
        return "浅色";
      case ThemeMode.dark:
        return "深色";
    }
  }

  Future<void> _showModeSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<ThemeMode>(
          groupValue: ThemeController.instance.mode,
          onChanged: (mode) {
            if (mode != null) {
              ThemeController.instance.setMode(mode);
            }
            Navigator.pop(sheetContext);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in ThemeMode.values)
                RadioListTile<ThemeMode>(
                  value: mode,
                  title: Text(_modeLabel(mode)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSchemeDialog() async {
    final controller = ThemeController.instance;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("主题配色"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.schemes.length,
            itemBuilder: (context, index) {
              final scheme = controller.schemes[index];
              final selected = scheme.name == controller.scheme.name;
              return ListTile(
                dense: true,
                title: Text(scheme.name),
                subtitle: _schemeDots(scheme),
                trailing:
                    selected ? const Icon(Icons.check) : null,
                onTap: () {
                  controller.setScheme(scheme);
                  Navigator.pop(dialogContext);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _schemeDots(FlexSchemeData scheme) {
    final colors = [
      scheme.light.primary,
      scheme.light.primaryContainer,
      scheme.light.secondary,
      scheme.light.secondaryContainer,
    ];
    return Row(
      children: [
        for (final color in colors)
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
      ],
    );
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_onThemeChanged);
    _stream.close();
    super.dispose();
  }
}
