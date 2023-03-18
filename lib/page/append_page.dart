import 'package:flutter/material.dart';
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

  var _titleTextEditingController = TextEditingController();
  var _secretTextEditingController = TextEditingController();
  var _descriptionTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomizedAppBar(),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: _titleTextEditingController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.read_more_sharp),
                labelText: "title",
              ),
            ),
            TextField(
              controller: _secretTextEditingController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.water_drop_outlined),
                labelText: "secret",
              ),
            ),
            TextField(
              controller: _descriptionTextEditingController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.add_chart_sharp),
                labelText: "description",
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var varus =
              Varus(
                  name: _titleTextEditingController.text,
                  secret: _secretTextEditingController.text,
                  description: _descriptionTextEditingController.text);
          await VarusService.instance.createVarus(varus);
          toast("保存成功");
          Navigator.pushNamed(context, "/");
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.save_alt_outlined),
        label: const Text("保存条目"),
      ),
    );
  }
}
