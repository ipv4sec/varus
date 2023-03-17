import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:varus/dao/varus_dao.dart';
import 'package:varus/service/varus_service.dart';
import 'package:varus/utils/toast_utils.dart';

import 'package:varus/widgets/customized_appbar.dart';

class AppendPage extends StatefulWidget {
  const AppendPage({Key? key}) : super(key: key);

  @override
  State<AppendPage> createState() => _AppendPageState();
}

class _AppendPageState extends State<AppendPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomizedAppBar(),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.read_more_sharp),
                labelText: "title",
              ),
            ),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.water_drop_outlined),
                labelText: "secret",
              ),
            ),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.add_chart_sharp),
                labelText: "description",
              ),
            ),
            // ElevatedButton(child: Text('扫描二维码'), onPressed: (){}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // VarusDao.instance.createVarus(Varus(name: "name", value: "value", description: "description"));
          // var vs = await VarusService.instance.queryAllVarus();
          // print(vs.toString());
          var varus =
              Varus(name: "name", secret: "secret", description: "description");
          // var id =
          await VarusService.instance.createVarus(varus);
          // varus.id = id;
          // vs.add(varus);
          toast("保存成功");
          Navigator.pushNamed(context, "/");
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.save),
        label: const Text("Store"),
      ),
    );
  }
}
