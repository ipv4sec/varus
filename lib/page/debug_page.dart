import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';


import 'package:varus/service/varus_service.dart';
import 'package:varus/widgets/customized_appbar.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  var _stream = StreamController();

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
    var _debug = jsonEncode(ms);
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
      ));
  }

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }
}
