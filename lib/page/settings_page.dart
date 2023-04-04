import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path_provider/path_provider.dart';
import 'package:varus/service/varus_service.dart';
import 'package:varus/utils/toast_utils.dart';
import 'package:varus/widgets/customized_appbar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _stream = StreamController();
  var _debug = "";

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    var ms = [];
    var vs = await VarusService.instance.queryAllVarus();
    // print(vs);
    for (var i = 0; i < vs.length; i++) {
      ms.add(vs[i].toMap());
    }
    _debug = jsonEncode(ms);
    _stream.sink.add(_debug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomizedAppBar(),
      body: StreamBuilder(
        stream: _stream.stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data == null) {
            return Text("Loading");
          }
          return Html(data: '''<pre>${snapshot.data}</pre>''');
        }
      ),
    floatingActionButton: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: "1",
          onPressed: () async {
            if (_debug.length ==0) {
              toast("没有数据");
              return;
            }
            var directory = "/storage/emulated/0/Download/";
            if (io.Platform.isIOS) {
              var d = await getDownloadsDirectory();
              directory = d!.path;
            }
            print(directory);

            io.File file = new io.File('$directory/exports.json');
            file.writeAsString(_debug);
            toast("导出成功");

          }, label: Text("导出数据"), icon: Icon(Icons.import_export),),
        SizedBox(height: 10,),
        FloatingActionButton.extended(
          heroTag: "2",
          onPressed: () {

          }, label: Text("导入数据"), icon: Icon(Icons.label_important_sharp),),
      ],
    ),
    );
  }

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }
}
